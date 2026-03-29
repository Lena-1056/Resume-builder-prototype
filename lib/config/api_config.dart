// API configuration for the ATS Resume Builder.
class ApiConfig {
  // Change this to your backend URL
  static const String baseUrl = 'http://localhost:8000/api';

  static const String generateResume = '$baseUrl/generate-resume';
  static const String downloadPdf = '$baseUrl/download-pdf';
  static const String sendEmail = '$baseUrl/send-email';
  static const String skills = '$baseUrl/skills';
  static const String saveDetails = '$baseUrl/save-details';
  static const String savedDetails = '$baseUrl/saved-details';
  static const String deleteDetails = '$baseUrl/delete-details';
  static const String atsScore = '$baseUrl/ats-score';
  static const String optimizeResume = '$baseUrl/optimize-resume';

  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 60);
}
