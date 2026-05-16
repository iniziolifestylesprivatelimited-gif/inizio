import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final String baseUrl = ApiConstants.baseUrl;

  Future<Map<String, dynamic>> registerUser(
    String name, String email,String phone, String gstNumber, File? gstDocument) async {
  try {
    var uri = Uri.parse('$baseUrl/auth/register');
    var request = http.MultipartRequest('POST', uri);

    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['phone'] = phone;
    request.fields['gstNumber'] = gstNumber;

    if (gstDocument != null) {
      final mimeStr = lookupMimeType(gstDocument.path) ?? 'application/octet-stream';
      final mimeParts = mimeStr.split('/');
      final file = await http.MultipartFile.fromPath(
        'gstDocument',
        gstDocument.path,
        contentType: MediaType(mimeParts[0], mimeParts[1]),
      );
      request.files.add(file);
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        'message': 'Failed to upload. Status: ${response.statusCode}, Body: ${response.body}'
      };
    }
  } catch (e) {
    return {'message': 'Exception: $e'};
  }
}


  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  Future<List<dynamic>> fetchNotifications(String token) async {
  final res = await http.get(
    Uri.parse('$baseUrl/notifications'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (res.statusCode == 200) return jsonDecode(res.body) as List;
  throw Exception('Failed to load notifications');
}

Future<void> markNotificationRead(String id, String token) async {
  await http.put(
    Uri.parse('$baseUrl/notifications/$id/read'),
    headers: {'Authorization': 'Bearer $token'},
  );
}


  Future<Map<String, dynamic>> forgotPassword(String email) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return jsonDecode(response.body);
  } catch (e) {
    return {'message': 'Exception: $e'};
  }
}

}
