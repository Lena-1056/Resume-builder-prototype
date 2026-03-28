// Step 2: Education, Projects, Internships, Certifications, Activities.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resume_provider.dart';

class EducationStep extends StatelessWidget {
  const EducationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResumeProvider>(context);
    final data = provider.resumeData;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          _sectionHeader(
            theme,
            icon: Icons.school_outlined,
            title: 'Education & Background',
            subtitle: 'Add your academic and professional background',
          ),
          const SizedBox(height: 24),

          // ─── Education ────────────────────────────────────────────
          _buildSectionTitle(theme, 'Education', Icons.school),
          ...List.generate(data.education.length, (i) {
            final edu = data.education[i];
            return _buildCard(
              theme: theme,
              index: i,
              total: data.education.length,
              onRemove: () => provider.removeEducation(i),
              children: [
                _field('Degree *', 'B.Tech in Computer Science', edu.degree,
                    (v) => edu.degree = v),
                _field('Institution *', 'IIT Bombay', edu.institution,
                    (v) => edu.institution = v),
                _field('Year *', '2020 - 2024', edu.year, (v) => edu.year = v),
                _field('GPA', '8.5/10', edu.gpa ?? '', (v) => edu.gpa = v),
              ],
            );
          }),
          _addButton('Add Education', () => provider.addEducation()),
          const SizedBox(height: 28),

          // ─── Projects ─────────────────────────────────────────────
          _buildSectionTitle(theme, 'Projects', Icons.folder_outlined),
          ...List.generate(data.projects.length, (i) {
            final proj = data.projects[i];
            return _buildCard(
              theme: theme,
              index: i,
              total: data.projects.length,
              onRemove: () => provider.removeProject(i),
              children: [
                _field('Project Title *', 'E-Commerce Platform', proj.title,
                    (v) => proj.title = v),
                _field(
                    'Description *',
                    'Built a full-stack platform with React...',
                    proj.description,
                    (v) => proj.description = v,
                    maxLines: 3),
                _field(
                    'Technologies',
                    'React, Node.js, MongoDB (comma-separated)',
                    proj.technologies.join(', '),
                    (v) => proj.technologies =
                        v.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList()),
                _field(
                    'Link',
                    'https://github.com/user/project',
                    proj.link ?? '',
                    (v) => proj.link = v.isEmpty ? null : v),
              ],
            );
          }),
          _addButton('Add Project', () => provider.addProject()),
          const SizedBox(height: 28),

          // ─── Internships / Experience ─────────────────────────────
          _buildSectionTitle(theme, 'Experience / Internships', Icons.work_outlined),
          ...List.generate(data.internships.length, (i) {
            final intern = data.internships[i];
            return _buildCard(
              theme: theme,
              index: i,
              total: data.internships.length,
              onRemove: () => provider.removeInternship(i),
              children: [
                _field('Role *', 'Software Engineering Intern', intern.role,
                    (v) => intern.role = v),
                _field('Company *', 'Google', intern.company,
                    (v) => intern.company = v),
                _field('Duration *', 'May 2023 - Aug 2023', intern.duration,
                    (v) => intern.duration = v),
                _field(
                    'Description *',
                    'Developed microservices that processed 10K requests/min',
                    intern.description,
                    (v) => intern.description = v,
                    maxLines: 3),
              ],
            );
          }),
          _addButton('Add Experience', () => provider.addInternship()),
          const SizedBox(height: 28),

          // ─── Certifications ───────────────────────────────────────
          _buildSectionTitle(theme, 'Certifications', Icons.verified_outlined),
          ...List.generate(data.certifications.length, (i) {
            final cert = data.certifications[i];
            return _buildCard(
              theme: theme,
              index: i,
              total: data.certifications.length,
              onRemove: () => provider.removeCertification(i),
              children: [
                _field('Certification Name', 'AWS Solutions Architect',
                    cert.name, (v) => cert.name = v),
                _field('Issuer', 'Amazon Web Services', cert.issuer,
                    (v) => cert.issuer = v),
                _field('Year', '2023', cert.year ?? '', (v) => cert.year = v),
              ],
            );
          }),
          _addButton('Add Certification', () => provider.addCertification()),
          const SizedBox(height: 28),

          // ─── Extra Activities ─────────────────────────────────────
          _buildSectionTitle(
              theme, 'Activities & Achievements', Icons.emoji_events_outlined),
          ...List.generate(data.extraActivities.length, (i) {
            final act = data.extraActivities[i];
            return _buildCard(
              theme: theme,
              index: i,
              total: data.extraActivities.length,
              onRemove: () => provider.removeActivity(i),
              children: [
                _field('Title', 'Open Source Contributor', act.title,
                    (v) => act.title = v),
                _field(
                    'Description',
                    'Contributed to 5+ open-source projects',
                    act.description,
                    (v) => act.description = v,
                    maxLines: 2),
              ],
            );
          }),
          _addButton('Add Activity', () => provider.addActivity()),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionHeader(ThemeData theme,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(subtitle,
                  style:
                      theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildCard({
    required ThemeData theme,
    required int index,
    required int total,
    required VoidCallback onRemove,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (total > 1)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 18),
                color: Colors.red.shade400,
                tooltip: 'Remove',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ...children,
        ],
      ),
    );
  }

  Widget _field(String label, String hint, String initialValue,
      ValueChanged<String> onChanged,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          isDense: true,
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _addButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(style: BorderStyle.solid),
          ),
        ),
      ),
    );
  }
}
