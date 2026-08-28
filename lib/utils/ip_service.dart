import 'package:http/http.dart' as http;

class IPService {
  static Future<String> getExternalIP() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org'));
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      print('Error getting IP: $e');
    }
    return 'Unknown';
  }
}
