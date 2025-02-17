import 'package:orchid/api/orchid_eth/token_type.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orchid/api/orchid_log_api.dart';
import 'package:orchid/util/cacheable.dart';

/// Token Exchange rates
class OrchidPricing {
  static OrchidPricing _shared = OrchidPricing._init();

  Cache<TokenType, double> cache = Cache(duration: Duration(seconds: 30), name: "pricing");

  OrchidPricing._init();

  factory OrchidPricing() {
    return _shared;
  }

  /// Return the price (USD/Token): tokens * Rate = USD
  Future<double> tokenToUsdRate(TokenType tokenType) async {
    return cache.get(
        key: tokenType,
        producer: (tokenType) {
          return tokenType.exchangeRateSource.tokenToUsdRate(tokenType);
        });
  }

  Future<double> usdToTokenRate(TokenType tokenType) async {
    var rate = await tokenToUsdRate(tokenType);
    if (rate == 0) {
      throw Exception("invalid rate: $rate");
    }
    return 1.0 / rate;
  }
}

abstract class ExchangeRateSource {
  final String symbolOverride;

  const ExchangeRateSource({this.symbolOverride});

  /// Return the price (USD/Token): tokens * Rate = USD
  Future<double> tokenToUsdRate(TokenType tokenType);

  Future<double> _invert(double rate) async {
    if (rate == 0) {
      throw Exception("invalid rate: $rate");
    }
    return 1.0 / rate;
  }
}

class BinanceExchangeRateSource extends ExchangeRateSource {
  /// Reverse the default <TOKEN>USDT pair ordering to USDT<TOKEN> and invert
  /// the rate consistent with that. e.g. for DAI we must use 1/USDTDAI and
  /// not DAIUSDT since DAIUSDT was delisted.
  final bool inverted;

  const BinanceExchangeRateSource(
      {this.inverted = false, String symbolOverride})
      : super(symbolOverride: symbolOverride); // Binance exchange rates

  // https://api.binance.com/api/v3/avgPrice?symbol=ETHUSDT
  String _url(TokenType tokenType) {
    var symbol = symbolOverride ?? tokenType.symbol.toUpperCase();
    var pair = inverted ? 'USDT$symbol' : '${symbol}USDT';
    return 'https://api.binance.com/api/v3/avgPrice?symbol=$pair';
  }

  /// Return the rate USD/Token: Tokens * Rate = USD
  Future<double> tokenToUsdRate(TokenType tokenType) async {
    var rate = await _getPrice(tokenType);
    return inverted ? _invert(rate) : rate;
  }

  Future<double> _getPrice(TokenType tokenType) async {
    log("pricing: Binance fetching rate for: $tokenType");
    try {
      var response = await http.get(_url(tokenType),
          headers: {'Referer': 'https://account.orchid.com'});
      if (response.statusCode != 200) {
        throw Exception("Error status code: ${response.statusCode}");
      }
      var body = json.decode(response.body);
      return double.parse(body['price']);
    } catch (err) {
      log("Error fetching pricing: $err");
      throw err;
    }
  }
}
