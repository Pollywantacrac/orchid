import 'package:orchid/api/preferences/user_preferences.dart';
import 'package:orchid/util/js_config.dart';
import 'orchid_user_config.dart';

class OrchidUserConfigImpl implements OrchidUserConfig {
  JSConfig getUserConfigJS() {
    try {
      return JSConfig(UserPreferences().userConfig.get());
    } catch (err) {
      print("Error parsing user entered configuration as JS: $err");
    }
    return JSConfig("");
  }
}
