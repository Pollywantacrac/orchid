import 'package:orchid/api/configuration/orchid_user_config/orchid_user_config.dart';

class OrchidContractV1 {
  // Lottery contract address (all chains, singleton deployment).
  static var _lotteryContractAddressV1 = '0x6dB8381b2B41b74E17F5D4eB82E8d5b04ddA0a82';

  // TODO: TESTING Ganache
  // static var _lotteryContractAddressV1 = '0x30CE69f1d7b5b281559bA97e7f8B0Bc6F78440A3';

  static String get lotteryContractAddressV1 {
    return OrchidUserConfig()
        .getUserConfigJS()
        .evalStringDefault("lottery", _lotteryContractAddressV1);
  }

  /// Indicates that one or more of the contract addresses have been overridden
  static bool get contractOverridden {
    return lotteryContractAddressV1 != _lotteryContractAddressV1;
  }

  // The earliest block from which we look for events on chain for this contract.
  // TODO:
  static int startBlock = 0;

  static String createEventHashV1 =
      // Create(address,address,address)
      '0xb224da6575b2c2ffd42454faedb236f7dbe5f92a0c96bb99c0273dbe98464c7e';

  static String readMethodHash = '5185c7d7';
  static String moveMethodHash = '987ff31c';

  static int gasCostToRedeemTicket = 100000;
  static int lotteryMoveMaxGas = 175000;
  static int createAccountMaxGas = lotteryMoveMaxGas;

  // static lottery_pull_amount_max_gas: number = 150000;
  // static lottery_pull_all_max_gas: number = 150000;
  // static lottery_lock_max_gas: number = 50000;
  // static lottery_warn_max_gas: number = 50000;
  // static lottery_move_max_gas: number = 175000;

  // Total max gas used by an add funds operation.
  // static add_funds_total_max_gas: number = OrchidContractV1.lottery_move_max_gas;
  // static stake_funds_total_max_gas: number = OrchidContractV1.add_funds_total_max_gas;

}
