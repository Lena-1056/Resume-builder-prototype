// Step 3: Skills selection UI with role-based grouping.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resume_provider.dart';
import '../../widgets/skill_checkbox_group.dart';

class SkillsStep extends StatelessWidget {
  const SkillsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResumeProvider>(context);
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
                child: Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Your Skills',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Choose skills that match your expertise. These will be matched against the job description.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Selected count badge
          if (provider.resumeData.skills.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${provider.resumeData.skills.length} skills selected',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Skill categories
          ...provider.availableSkills.entries.map((entry) {
            return SkillCheckboxGroup(
              category: entry.key,
              skills: entry.value,
              selectedSkills: provider.resumeData.skills,
              onToggle: provider.toggleSkill,
            );
          }),

          // Custom skill input
          const SizedBox(height: 16),
          _CustomSkillInput(provider: provider),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _CustomSkillInput extends StatefulWidget {
  final ResumeProvider provider;

  const _CustomSkillInput({required this.provider});

  @override
  State<_CustomSkillInput> createState() => _CustomSkillInputState();
}

class _CustomSkillInputState extends State<_CustomSkillInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addCustomSkill() {
    final skill = _controller.text.trim();
    if (skill.isNotEmpty &&
        !widget.provider.resumeData.skills.contains(skill)) {
      widget.provider.toggleSkill(skill);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Custom Skill',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Type a skill not listed above...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addCustomSkill(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addCustomSkill,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
