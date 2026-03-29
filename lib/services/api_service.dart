// API service for backend communication.
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/resume_data.dart';

class ApiService {
  /// Generate resume by sending form data to backend.
  static Future<ResumeResponse> generateResume(ResumeData data) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.generateResume),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data.toJson()),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ResumeResponse.fromJson(jsonData);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to generate resume');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to reach the server');
    }
  }

  /// Send email with generated PDF.
  static Future<bool> sendEmail({
    required String email,
    required String name,
    required String pdfFilename,
    int? atsScore,
    bool? optimized,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'recipient_email': email,
        'recipient_name': name,
        'pdf_filename': pdfFilename,
      };
      if (atsScore != null) body['ats_score'] = atsScore;
      if (optimized != null) body['optimized'] = optimized;

      final response = await http
          .post(
            Uri.parse(ApiConfig.sendEmail),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.requestTimeout);

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to send email: $e');
    }
  }

  /// Get PDF download URL.
  static String getPdfDownloadUrl(String filename) {
    return '${ApiConfig.downloadPdf}/$filename';
  }

  /// Fetch skills from backend (with local fallback).
  static Future<Map<String, List<String>>> fetchSkills() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.skills))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data.map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        );
      }
    } catch (_) {
      // Fallback to local data
    }
    return {};
  }

  /// Save profile details
  static Future<void> saveDetails(String email, ResumeData data) async {
    final body = data.toJson();
    body['user_id'] = email;
    // Map internals back
    body['experience'] = body['internships'];
    
    final response = await http.post(
      Uri.parse(ApiConfig.saveDetails),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to save details');
    }
  }

  /// Get saved details
  static Future<List<SavedProfile>> getSavedDetails(String email) async {
    final url = '${ApiConfig.savedDetails}/$email';
    final response = await http.get(Uri.parse(url)).timeout(ApiConfig.requestTimeout);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => SavedProfile.fromJson(e)).toList();
    }
    return [];
  }

  /// Delete saved profile
  static Future<void> deleteDetails(int id) async {
    final url = '${ApiConfig.deleteDetails}/$id';
    await http.delete(Uri.parse(url)).timeout(ApiConfig.requestTimeout);
  }

  /// Get ATS score only (no optimization)
  static Future<AtsScoreResponse> getAtsScore(ResumeData data) async {
    final response = await http.post(
      Uri.parse(ApiConfig.atsScore),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data.toJson()),
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return AtsScoreResponse.fromJson(jsonData);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to calculate ATS score');
    }
  }

  /// Optimize resume for better ATS score
  static Future<AtsAnalysisResponse> optimizeResume(ResumeData data) async {
    final response = await http.post(
      Uri.parse(ApiConfig.optimizeResume),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data.toJson()),
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return AtsAnalysisResponse.fromJson(jsonData);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to optimize resume');
    }
  }
}
