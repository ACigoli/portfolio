import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const _baseUrl = 'https://alexportfolio.up.railway.app/api';
  static const _tokenKey = 'admin_token';

  // ── Token ─────────────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ── Auth ──────────────────────────────────────────────
  static Future<String> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: await _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      await saveToken(data['token']);
      return data['token'];
    }
    throw Exception(data['error'] ?? 'Erro ao fazer login');
  }

  // ── About ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> getAbout() async {
    final res = await http.get(Uri.parse('$_baseUrl/about'));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateAbout(Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/about'),
      headers: await _headers(auth: true),
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error']);
  }

  // ── Projects ──────────────────────────────────────────
  static Future<List<dynamic>> getProjects() async {
    final res = await http.get(Uri.parse('$_baseUrl/projects'));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createProject(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/projects'),
      headers: await _headers(auth: true),
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error']);
  }

  static Future<Map<String, dynamic>> updateProject(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/projects/$id'),
      headers: await _headers(auth: true),
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error']);
  }

  static Future<void> deleteProject(int id) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/projects/$id'),
      headers: await _headers(auth: true),
    );
    if (res.statusCode != 200) throw Exception(jsonDecode(res.body)['error']);
  }

  // ── Skills ────────────────────────────────────────────
  static Future<List<dynamic>> getSkills() async {
    final res = await http.get(Uri.parse('$_baseUrl/skills'));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createSkill(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/skills'),
      headers: await _headers(auth: true),
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error']);
  }

  static Future<Map<String, dynamic>> updateSkill(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/skills/$id'),
      headers: await _headers(auth: true),
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error']);
  }

  static Future<void> deleteSkill(int id) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/skills/$id'),
      headers: await _headers(auth: true),
    );
    if (res.statusCode != 200) throw Exception(jsonDecode(res.body)['error']);
  }

  // ── Experience ────────────────────────────────────────
  static Future<List<dynamic>> getExperience() async {
    final res = await http.get(Uri.parse('$_baseUrl/experience'));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createExperience(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/experience'),
      headers: await _headers(auth: true),
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error']);
  }

  static Future<Map<String, dynamic>> updateExperience(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/experience/$id'),
      headers: await _headers(auth: true),
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error']);
  }

  static Future<void> deleteExperience(int id) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/experience/$id'),
      headers: await _headers(auth: true),
    );
    if (res.statusCode != 200) throw Exception(jsonDecode(res.body)['error']);
  }

  // ── Services ──────────────────────────────────────────
  static Future<List<dynamic>> getServices() async {
    final res = await http.get(Uri.parse('$_baseUrl/services'));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createService(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/services'),
      headers: await _headers(auth: true),
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error']);
  }

  static Future<Map<String, dynamic>> updateService(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/services/$id'),
      headers: await _headers(auth: true),
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error']);
  }

  static Future<void> deleteService(int id) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/services/$id'),
      headers: await _headers(auth: true),
    );
    if (res.statusCode != 200) throw Exception(jsonDecode(res.body)['error']);
  }

  // ── Education ─────────────────────────────────────────
  static Future<List<dynamic>> getEducation() async {
    final res = await http.get(Uri.parse('$_baseUrl/education'));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createEducation(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/education'),
      headers: await _headers(auth: true),
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error']);
  }

  static Future<Map<String, dynamic>> updateEducation(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/education/$id'),
      headers: await _headers(auth: true),
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error']);
  }

  static Future<void> deleteEducation(int id) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/education/$id'),
      headers: await _headers(auth: true),
    );
    if (res.statusCode != 200) throw Exception(jsonDecode(res.body)['error']);
  }

  // ── Contact (public) ──────────────────────────────────
  static Future<void> sendMessage(String name, String email, String message) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/contact'),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'email': email, 'message': message}),
    );
    if (res.statusCode != 201) throw Exception(jsonDecode(res.body)['error']);
  }

  // ── Messages ──────────────────────────────────────────
  static Future<List<dynamic>> getMessages() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/contact'),
      headers: await _headers(auth: true),
    );
    return jsonDecode(res.body);
  }

  static Future<void> markMessageRead(int id) async {
    await http.patch(
      Uri.parse('$_baseUrl/contact/$id/read'),
      headers: await _headers(auth: true),
    );
  }

  static Future<void> deleteMessage(int id) async {
    await http.delete(
      Uri.parse('$_baseUrl/contact/$id'),
      headers: await _headers(auth: true),
    );
  }
}
