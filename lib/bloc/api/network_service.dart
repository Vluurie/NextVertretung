import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  static Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      try {
        final result = await http.get(Uri.parse('https://www.google.com'));
        if (result.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      } catch (_) {
        return false;
      }
    }
  }
}
