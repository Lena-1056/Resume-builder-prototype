// State management provider for the resume builder.
import 'package:flutter/material.dart';
import '../models/resume_data.dart';
import '../models/skill_data.dart';
import '../services/api_service.dart';

enum AppState { idle, loading, success, error }

class ResumeProvider extends ChangeNotifier {
  // Form data
  final ResumeData _resumeData = ResumeData();
  ResumeData get resumeData => _resumeData;

  // Skills from API
  Map<String, List<String>> _availableSkills = SkillData.skillsByCategory;
  Map<String, List<String>> get availableSkills => _availableSkills;

  ResumeProvider() {
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    try {
      final skills = await ApiService.fetchSkills();
      if (skills.isNotEmpty) {
        _availableSkills = skills;
        notifyListeners();
      }
    } catch (_) {
      // Fallback to local
    }
  }

  // Step management
  int _currentStep = 0;
  int get currentStep => _currentStep;
  static const int totalSteps = 5;

  // UI state
  AppState _state = AppState.idle;
  AppState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Response data
  ResumeResponse? _response;
  ResumeResponse? get response => _response;

  // Form Reset Trigger
  int formKeyCounter = 0;

  // Saved profiles
  List<SavedProfile> _savedProfiles = [];
  List<SavedProfile> get savedProfiles => _savedProfiles;

  // ATS Analysis status
  bool _isAtsAnalyzing = false;
  bool get isAtsAnalyzing => _isAtsAnalyzing;

  bool _isOptimizing = false;
  bool get isOptimizing => _isOptimizing;

  AtsScoreResponse? _atsScoreResponse;
  AtsScoreResponse? get atsScoreResponse => _atsScoreResponse;

  AtsAnalysisResponse? _atsResponse;
  AtsAnalysisResponse? get atsResponse => _atsResponse;

  // ─── Step Navigation ───────────────────────────────────────────────────

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      notifyListeners();
    }
  }

  // ─── Skills Management ─────────────────────────────────────────────────

  void toggleSkill(String skill) {
    if (_resumeData.skills.contains(skill)) {
      _resumeData.skills.remove(skill);
    } else {
      _resumeData.skills.add(skill);
    }
    notifyListeners();
  }

  bool isSkillSelected(String skill) => _resumeData.skills.contains(skill);

  // ─── Dynamic List Management ───────────────────────────────────────────

  void addEducation() {
    _resumeData.education.add(Education());
    notifyListeners();
  }

  void removeEducation(int index) {
    if (_resumeData.education.length > 1) {
      _resumeData.education.removeAt(index);
      notifyListeners();
    }
  }

  void addProject() {
    _resumeData.projects.add(Project());
    notifyListeners();
  }

  void removeProject(int index) {
    if (_resumeData.projects.length > 1) {
      _resumeData.projects.removeAt(index);
      notifyListeners();
    }
  }

  void addInternship() {
    _resumeData.internships.add(Internship());
    notifyListeners();
  }

  void removeInternship(int index) {
    if (_resumeData.internships.length > 1) {
      _resumeData.internships.removeAt(index);
      notifyListeners();
    }
  }

  void addCertification() {
    _resumeData.certifications.add(Certification());
    notifyListeners();
  }

  void removeCertification(int index) {
    if (_resumeData.certifications.length > 1) {
      _resumeData.certifications.removeAt(index);
      notifyListeners();
    }
  }

  void addActivity() {
    _resumeData.extraActivities.add(ExtraActivity());
    notifyListeners();
  }

  void removeActivity(int index) {
    if (_resumeData.extraActivities.length > 1) {
      _resumeData.extraActivities.removeAt(index);
      notifyListeners();
    }
  }

  // ─── API Calls ─────────────────────────────────────────────────────────

  Future<void> generateResume() async {
    _state = AppState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _response = await ApiService.generateResume(_resumeData);
      _state = AppState.success;
    } catch (e) {
      _state = AppState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  Future<bool> sendEmail() async {
    if (_response?.pdfFilename == null) return false;

    try {
      return await ApiService.sendEmail(
        email: _resumeData.email,
        name: _resumeData.name,
        pdfFilename: _response!.pdfFilename!,
        atsScore: _atsResponse?.improvedScore ?? _atsScoreResponse?.initialScore,
        optimized: _atsResponse?.improvedScore != null,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> saveCurrentProfile() async {
    if (_resumeData.email.isEmpty) {
      _errorMessage = 'Please provide an email to save your profile.';
      notifyListeners();
      return;
    }
    try {
      await ApiService.saveDetails(_resumeData.email, _resumeData);
      _errorMessage = 'Profile saved successfully!'; // Hack to show success
      await fetchSavedProfiles(_resumeData.email); // Auto-update the sidebar list
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void loadSavedProfile(SavedProfile profile) {
    _resumeData.email = profile.userId;
    _resumeData.name = profile.name;
    _resumeData.summary = profile.summary;
    _resumeData.education = profile.education.isNotEmpty ? profile.education : [Education()];
    _resumeData.skills = profile.skills;
    _resumeData.internships = profile.experience.isNotEmpty ? profile.experience : [Internship()];
    _resumeData.projects = profile.projects.isNotEmpty ? profile.projects : [Project()];
    _resumeData.certifications = profile.certifications.isNotEmpty ? profile.certifications : [Certification()];
    _resumeData.extraActivities = profile.extraActivities.isNotEmpty ? profile.extraActivities : [ExtraActivity()];
    
    // Switch to step 0 and trigger form rebuild
    _currentStep = 0;
    formKeyCounter++;
    notifyListeners();
  }

  Future<void> fetchSavedProfiles(String email) async {
    try {
      _savedProfiles = await ApiService.getSavedDetails(email);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  /// Step 1: Calculate ATS score only (no optimization)
  Future<void> calculateAtsScore() async {
    if (_resumeData.jobDescription.isEmpty) {
      _errorMessage = 'Please provide a job description to analyze ATS score.';
      notifyListeners();
      return;
    }

    _isAtsAnalyzing = true;
    _errorMessage = '';
    // Reset optimization state when recalculating
    _atsResponse = null;
    notifyListeners();

    try {
      _atsScoreResponse = await ApiService.getAtsScore(_resumeData);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isAtsAnalyzing = false;
      notifyListeners();
    }
  }

  /// Step 2: Optimize resume for better ATS score
  Future<void> optimizeResume() async {
    if (_resumeData.jobDescription.isEmpty) {
      _errorMessage = 'Please provide a job description to optimize.';
      notifyListeners();
      return;
    }

    _isOptimizing = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _atsResponse = await ApiService.optimizeResume(_resumeData);
      
      // If optimized data was returned, update our internal data
      if (_atsResponse?.optimizedData != null) {
        final opt = _atsResponse!.optimizedData!;
        _resumeData.summary = opt.summary;
        if (opt.internships.isNotEmpty) _resumeData.internships = opt.internships;
        if (opt.projects.isNotEmpty) _resumeData.projects = opt.projects;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isOptimizing = false;
      notifyListeners();
    }
  }

  // ─── Reset ─────────────────────────────────────────────────────────────

  void resetAll() {
    _currentStep = 0;
    _state = AppState.idle;
    _errorMessage = '';
    _response = null;
    _atsScoreResponse = null;
    _atsResponse = null;
    // Reset resume data fields
    _resumeData.name = '';
    _resumeData.email = '';
    _resumeData.phone = '';
    _resumeData.github = null;
    _resumeData.linkedin = null;
    _resumeData.portfolio = null;
    _resumeData.education = [Education()];
    _resumeData.projects = [Project()];
    _resumeData.internships = [Internship()];
    _resumeData.certifications = [Certification()];
    _resumeData.extraActivities = [ExtraActivity()];
    _resumeData.skills = [];
    _resumeData.jobDescription = '';
    
    formKeyCounter++;
    notifyListeners();
  }
}
