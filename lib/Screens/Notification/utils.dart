import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class Utils {
  static Future<String> downloadFile(String url, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);

    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}