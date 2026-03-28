// Data model for resume input and response.

class Education {
  String degree;
  String institution;
  String year;
  String? gpa;

  Education({
    this.degree = '',
    this.institution = '',
    this.year = '',
    this.gpa,
  });

  Map<String, dynamic> toJson() => {
        'degree': degree,
        'institution': institution,
        'year': year,
        'gpa': gpa,
      };
}

class Project {
  String title;
  String description;
  List<String> technologies;
  String? link;

  Project({
    this.title = '',
    this.description = '',
    this.technologies = const [],
    this.link,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'technologies': technologies,
        'link': link,
      };
}

class Internship {
  String role;
  String company;
  String duration;
  String description;

  Internship({
    this.role = '',
    this.company = '',
    this.duration = '',
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'company': company,
        'duration': duration,
        'description': description,
      };
}

class Certification {
  String name;
  String issuer;
  String? year;
  String? link;

  Certification({
    this.name = '',
    this.issuer = '',
    this.year,
    this.link,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'issuer': issuer,
        'year': year,
        'link': link,
      };
}

class ExtraActivity {
  String title;
  String description;

  ExtraActivity({
    this.title = '',
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
      };
}

class ResumeData {
  // Personal Info
  String name;
  String email;
  String phone;
  String? github;
  String? linkedin;
  String? portfolio;

  // Sections
  List<Education> education;
  List<Project> projects;
  List<Internship> internships;
  List<Certification> certifications;
  List<ExtraActivity> extraActivities;

  // Skills & JD
  List<String> skills;
  String jobDescription;

  ResumeData({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.github,
    this.linkedin,
    this.portfolio,
    List<Education>? education,
    List<Project>? projects,
    List<Internship>? internships,
    List<Certification>? certifications,
    List<ExtraActivity>? extraActivities,
    List<String>? skills,
    this.jobDescription = '',
  })  : education = education ?? [Education()],
        projects = projects ?? [Project()],
        internships = internships ?? [Internship()],
        certifications = certifications ?? [Certification()],
        extraActivities = extraActivities ?? [ExtraActivity()],
        skills = skills ?? [];

  Map<String, dynamic> toJson() {
    // Filter out items where required fields are empty
    final filledEducation =
        education.where((e) => e.degree.trim().isNotEmpty && e.institution.trim().isNotEmpty).toList();
    final filledProjects =
        projects.where((p) => p.title.trim().isNotEmpty).toList();
    final filledInternships =
        internships.where((i) => i.role.trim().isNotEmpty && i.company.trim().isNotEmpty).toList();
    final filledCertifications =
        certifications.where((c) => c.name.trim().isNotEmpty && c.issuer.trim().isNotEmpty).toList();
    final filledActivities =
        extraActivities.where((a) => a.title.trim().isNotEmpty).toList();

    return {
      'name': name,
      'email': email,
      'phone': phone,
      'github': (github?.trim().isNotEmpty ?? false) ? github : null,
      'linkedin': (linkedin?.trim().isNotEmpty ?? false) ? linkedin : null,
      'portfolio': (portfolio?.trim().isNotEmpty ?? false) ? portfolio : null,
      'education': filledEducation.map((e) => e.toJson()).toList(),
      'projects': filledProjects.map((p) => p.toJson()).toList(),
      'internships': filledInternships.map((i) => i.toJson()).toList(),
      'certifications': filledCertifications.map((c) => c.toJson()).toList(),
      'extra_activities': filledActivities.map((a) => a.toJson()).toList(),
      'skills': skills,
      'job_description': jobDescription,
    };
  }
}

class ResumeResponse {
  final String htmlResume;
  final String? pdfFilename;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final List<String> keywords;
  final String message;

  ResumeResponse({
    required this.htmlResume,
    this.pdfFilename,
    this.matchedSkills = const [],
    this.missingSkills = const [],
    this.keywords = const [],
    this.message = '',
  });

  factory ResumeResponse.fromJson(Map<String, dynamic> json) {
    return ResumeResponse(
      htmlResume: json['html_resume'] ?? '',
      pdfFilename: json['pdf_filename'],
      matchedSkills: List<String>.from(json['matched_skills'] ?? []),
      missingSkills: List<String>.from(json['missing_skills'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
      message: json['message'] ?? '',
    );
  }
}

class SavedProfile {
  final int id;
  final String userId;
  final String createdAt;
  final List<Education> education;
  final List<String> skills;
  final List<Internship> experience;
  final List<Project> projects;
  final List<Certification> certifications;
  final List<ExtraActivity> extraActivities;

  SavedProfile({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.education = const [],
    this.skills = const [],
    this.experience = const [],
    this.projects = const [],
    this.certifications = const [],
    this.extraActivities = const [],
  });

  factory SavedProfile.fromJson(Map<String, dynamic> json) {
    return SavedProfile(
      id: json['id'],
      userId: json['user_id'],
      createdAt: json['created_at'],
      education: (json['education'] as List?)?.map((e) => Education(
        degree: e['degree'] ?? '',
        institution: e['institution'] ?? '',
        year: e['year'] ?? '',
        gpa: e['gpa'],
      )).toList() ?? [],
      skills: List<String>.from(json['skills'] ?? []),
      experience: (json['experience'] as List?)?.map((e) => Internship(
        role: e['role'] ?? '',
        company: e['company'] ?? '',
        duration: e['duration'] ?? '',
        description: e['description'] ?? '',
      )).toList() ?? [],
      projects: (json['projects'] as List?)?.map((e) => Project(
        title: e['title'] ?? '',
        description: e['description'] ?? '',
        technologies: List<String>.from(e['technologies'] ?? []),
        link: e['link'],
      )).toList() ?? [],
      certifications: (json['certifications'] as List?)?.map((e) => Certification(
        name: e['name'] ?? '',
        issuer: e['issuer'] ?? '',
        year: e['year'],
        link: e['link'],
      )).toList() ?? [],
      extraActivities: (json['extra_activities'] as List?)?.map((e) => ExtraActivity(
        title: e['title'] ?? '',
        description: e['description'] ?? '',
      )).toList() ?? [],
    );
  }
}

class AtsAnalysisResponse {
  final int initialScore;
  final int? improvedScore;
  final ResumeData? optimizedData;
  final List<String> suggestions;

  AtsAnalysisResponse({
    required this.initialScore,
    this.improvedScore,
    this.optimizedData,
    this.suggestions = const [],
  });

  factory AtsAnalysisResponse.fromJson(Map<String, dynamic> json) {
    ResumeData? parsedData;
    if (json['optimized_data'] != null) {
      final bData = json['optimized_data'];
      parsedData = ResumeData(
        name: bData['name'] ?? '',
        email: bData['email'] ?? '',
        phone: bData['phone'] ?? '',
        github: bData['github'],
        linkedin: bData['linkedin'],
        portfolio: bData['portfolio'],
        education: (bData['education'] as List?)?.map((e) => Education(
          degree: e['degree'] ?? '',
          institution: e['institution'] ?? '',
          year: e['year'] ?? '',
          gpa: e['gpa'],
        )).toList(),
        skills: List<String>.from(bData['skills'] ?? []),
        internships: (bData['internships'] as List?)?.map((e) => Internship(
          role: e['role'] ?? '',
          company: e['company'] ?? '',
          duration: e['duration'] ?? '',
          description: e['description'] ?? '',
        )).toList(),
        projects: (bData['projects'] as List?)?.map((e) => Project(
          title: e['title'] ?? '',
          description: e['description'] ?? '',
          technologies: List<String>.from(e['technologies'] ?? []),
          link: e['link'],
        )).toList(),
        certifications: (bData['certifications'] as List?)?.map((e) => Certification(
          name: e['name'] ?? '',
          issuer: e['issuer'] ?? '',
          year: e['year'],
          link: e['link'],
        )).toList(),
        extraActivities: (bData['extra_activities'] as List?)?.map((e) => ExtraActivity(
          title: e['title'] ?? '',
          description: e['description'] ?? '',
        )).toList(),
        jobDescription: bData['job_description'] ?? '',
      );
    }
    return AtsAnalysisResponse(
      initialScore: json['initial_score'] ?? 0,
      improvedScore: json['improved_score'],
      optimizedData: parsedData,
      suggestions: List<String>.from(json['suggestions'] ?? []),
    );
  }
}
