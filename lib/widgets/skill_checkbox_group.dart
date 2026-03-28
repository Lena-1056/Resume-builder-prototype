// Skill checkbox group widget — role-based skill selection.
import 'package:flutter/material.dart';

class SkillCheckboxGroup extends StatelessWidget {
  final String category;
  final List<String> skills;
  final List<String> selectedSkills;
  final Function(String) onToggle;

  const SkillCheckboxGroup({
    super.key,
    required this.category,
    required this.skills,
    required this.selectedSkills,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount =
        skills.where((s) => selectedSkills.contains(s)).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 16),
          leading: _getCategoryIcon(category, theme),
          title: Row(
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              if (selectedCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$selectedCount',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) {
                final isSelected = selectedSkills.contains(skill);
                return FilterChip(
                  label: Text(
                    skill,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => onToggle(skill),
                  selectedColor: theme.colorScheme.primary,
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String category, ThemeData theme) {
    IconData icon;
    Color color;

    switch (category) {
      case 'Frontend':
        icon = Icons.web;
        color = Colors.blue;
        break;
      case 'Backend':
        icon = Icons.dns;
        color = Colors.green;
        break;
      case 'DevOps':
        icon = Icons.cloud;
        color = Colors.orange;
        break;
      case 'Data & AI':
        icon = Icons.psychology;
        color = Colors.purple;
        break;
      case 'Mobile':
        icon = Icons.phone_android;
        color = Colors.teal;
        break;
      default:
        icon = Icons.build;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
