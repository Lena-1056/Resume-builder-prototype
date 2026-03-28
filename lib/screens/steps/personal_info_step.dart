// Step 1: Personal Information input form.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resume_provider.dart';

class PersonalInfoStep extends StatelessWidget {
  const PersonalInfoStep({super.key});

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_outline,
                    color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Personal Information',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Basic details for your resume header',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Required fields
          _buildTextField(
            label: 'Full Name *',
            hint: 'e.g., John Doe',
            icon: Icons.badge_outlined,
            initialValue: data.name,
            onChanged: (v) => data.name = v,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            label: 'Email Address *',
            hint: 'e.g., john@example.com',
            icon: Icons.email_outlined,
            initialValue: data.email,
            onChanged: (v) => data.email = v,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            label: 'Phone Number *',
            hint: 'e.g., +1-234-567-8900',
            icon: Icons.phone_outlined,
            initialValue: data.phone,
            onChanged: (v) => data.phone = v,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 28),

          // Optional fields divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('Optional Links',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12)),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 16),

          _buildTextField(
            label: 'GitHub',
            hint: 'https://github.com/username',
            icon: Icons.code,
            initialValue: data.github ?? '',
            onChanged: (v) => data.github = v.isEmpty ? null : v,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            label: 'LinkedIn',
            hint: 'https://linkedin.com/in/username',
            icon: Icons.link,
            initialValue: data.linkedin ?? '',
            onChanged: (v) => data.linkedin = v.isEmpty ? null : v,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            label: 'Portfolio Website',
            hint: 'https://yourportfolio.com',
            icon: Icons.language,
            initialValue: data.portfolio ?? '',
            onChanged: (v) => data.portfolio = v.isEmpty ? null : v,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required String initialValue,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
