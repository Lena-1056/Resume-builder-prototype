// Home screen — multi-step form with step indicator and navigation.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/resume_provider.dart';
import '../services/api_service.dart';
import '../widgets/step_indicator.dart';
import 'steps/personal_info_step.dart';
import 'steps/education_step.dart';
import 'steps/skills_step.dart';
import 'steps/job_description_step.dart';
import 'result_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> _stepLabels = [
    'Personal',
    'Background',
    'Skills',
    'Job Description',
    'Review',
  ];

  static const List<Widget> _steps = [
    PersonalInfoStep(),
    EducationStep(),
    SkillsStep(),
    JobDescriptionStep(),
    // Step 5 is the review — handled by JD step's summary
    JobDescriptionStep(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResumeProvider>(context);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    return Scaffold(
      drawer: _buildDrawer(context, provider),
      body: Builder(builder: (scaffoldContext) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.03),
              theme.colorScheme.secondary.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ─── App Bar ──────────────────────────────────────────
              _buildHeader(scaffoldContext, theme, provider),

              // ─── Step Indicator ───────────────────────────────────
              Container(
                constraints: BoxConstraints(maxWidth: isWide ? 700 : double.infinity),
                child: StepIndicator(
                  currentStep: provider.currentStep,
                  totalSteps: ResumeProvider.totalSteps,
                  stepLabels: _stepLabels,
                  onStepTap: (step) {
                    if (step <= provider.currentStep) {
                      provider.goToStep(step);
                    }
                  },
                ),
              ),

              // Step label
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Step ${provider.currentStep + 1}: ${_stepLabels[provider.currentStep]}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // ─── Form Content ─────────────────────────────────────
              Expanded(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: isWide ? 700 : double.infinity),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey('${provider.currentStep}_${provider.formKeyCounter}'),
                        child: _steps[provider.currentStep],
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Navigation Buttons ───────────────────────────────
              _buildNavigationBar(context, provider, theme, isWide),
            ],
          ),
        ),
      );
    }),
  );
}

  Widget _buildHeader(BuildContext context, ThemeData theme, ResumeProvider provider) {
    final bool isNarrow = MediaQuery.of(context).size.width < 600;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isNarrow ? 8 : 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ATS Resume Builder',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Build your perfect resume',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isNarrow) ...[
            IconButton(
              onPressed: () async {
                await provider.saveCurrentProfile();
                if (provider.errorMessage.contains('success')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Details saved successfully!')),
                  );
                  Scaffold.of(context).openDrawer();
                } else if (provider.errorMessage.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(provider.errorMessage), backgroundColor: Colors.red),
                  );
                }
              },
              icon: const Icon(Icons.save, size: 22),
              color: theme.colorScheme.primary,
              tooltip: 'Save Details',
            ),
            IconButton(
              onPressed: () {
                provider.resetAll();
              },
              icon: const Icon(Icons.add_circle_outline, size: 22),
              color: theme.colorScheme.primary,
              tooltip: 'New Profile',
            ),
          ] else ...[
            TextButton.icon(
              onPressed: () async {
                await provider.saveCurrentProfile();
                if (provider.errorMessage.contains('success')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Details saved successfully!')),
                  );
                  Scaffold.of(context).openDrawer();
                } else if (provider.errorMessage.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(provider.errorMessage), backgroundColor: Colors.red),
                  );
                }
              },
              icon: const Icon(Icons.save, size: 18),
              label: const Text('Save Details'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                provider.resetAll();
              },
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('New Profile'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, ResumeProvider provider) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Saved Profiles', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    OutlinedButton.icon(
                      onPressed: () {
                        provider.resetAll();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.add, color: Colors.white, size: 16),
                      label: const Text('New', style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter email to load',
                    hintStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  ),
                  onSubmitted: (val) {
                    if (val.isNotEmpty) {
                      provider.fetchSavedProfiles(val);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.savedProfiles.isEmpty
                ? const Center(child: Text('No saved profiles found.'))
                : ListView.builder(
                    itemCount: provider.savedProfiles.length,
                    itemBuilder: (context, index) {
                      final profile = provider.savedProfiles[index];
                      return ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(profile.name.isNotEmpty ? profile.name : 'Profile ${profile.id}'),
                        subtitle: Text(profile.createdAt.split('T')[0]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            await ApiService.deleteDetails(profile.id);
                            provider.fetchSavedProfiles(profile.userId);
                          },
                        ),
                        onTap: () {
                          provider.loadSavedProfile(profile);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile loaded successfully!')),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(
      BuildContext context, ResumeProvider provider, ThemeData theme, bool isWide) {
    final isFirstStep = provider.currentStep == 0;
    final isLastStep = provider.currentStep == ResumeProvider.totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isWide ? 700 : double.infinity),
          child: Row(
            children: [
              if (!isFirstStep)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.previousStep,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              if (!isFirstStep) const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () {
                    if (isLastStep) {
                      _onSubmit(context, provider);
                    } else {
                      provider.nextStep();
                    }
                  },
                  icon: Icon(
                    isLastStep ? Icons.rocket_launch : Icons.arrow_forward,
                    size: 18,
                  ),
                  label: Text(isLastStep ? 'Generate Resume' : 'Continue'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit(BuildContext context, ResumeProvider provider) async {
    final data = provider.resumeData;

    // Basic validation
    if (data.name.isEmpty || data.email.isEmpty || data.phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required personal information.'),
          backgroundColor: Colors.red,
        ),
      );
      provider.goToStep(0);
      return;
    }

    if (data.jobDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a job description.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to result screen
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ResultScreen()),
    );

    // Generate resume
    await provider.generateResume();
  }
}
