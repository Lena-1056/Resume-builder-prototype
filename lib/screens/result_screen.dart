// Result screen — shows generated resume, download/email options.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/resume_provider.dart';
import '../services/api_service.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResumeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Resume'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: _buildBody(context, provider, theme),
    );
  }

  Widget _buildBody(
      BuildContext context, ResumeProvider provider, ThemeData theme) {
    switch (provider.state) {
      case AppState.loading:
        return _buildLoading(theme);
      case AppState.error:
        return _buildError(context, provider, theme);
      case AppState.success:
        return _buildSuccess(context, provider, theme);
      default:
        return _buildLoading(theme);
    }
  }

  Widget _buildLoading(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Generating your resume...',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our AI is optimizing your resume for ATS systems.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
      BuildContext context, ResumeProvider provider, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Generation Failed',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                await provider.generateResume();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(
      BuildContext context, ResumeProvider provider, ThemeData theme) {
    final response = provider.response!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isWide ? 800 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade400,
                      Colors.green.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resume Generated Successfully!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            response.message,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      context,
                      icon: Icons.download,
                      label: 'Download PDF',
                      color: theme.colorScheme.primary,
                      onPressed: () => _downloadPdf(context, response.pdfFilename),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton(
                      context,
                      icon: Icons.email_outlined,
                      label: 'Email Resume',
                      color: Colors.orange,
                      onPressed: () => _sendEmail(context, provider),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: provider.isAtsAnalyzing
                      ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                      : _actionButton(
                          context,
                          icon: Icons.speed,
                          label: 'ATS Score',
                          color: Colors.purple,
                          onPressed: () async {
                            await provider.calculateAtsScore();
                          },
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ATS Score Card (Step 1: Score only)
              if (provider.atsScoreResponse != null && provider.atsResponse == null)
                _buildAtsScoreCard(context, theme, provider),

              // ATS Optimization Card (Step 2: After optimization)
              if (provider.atsResponse != null)
                _buildAtsOptimizationCard(theme, provider),

              if (provider.atsScoreResponse != null || provider.atsResponse != null)
                const SizedBox(height: 24),

              // Skills Analysis
              _buildSkillsAnalysis(theme, response),
              const SizedBox(height: 24),

              // HTML Preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.preview, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Resume Preview',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    SelectableText(
                      _stripHtml(response.htmlResume),
                      style: const TextStyle(fontSize: 13, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // New resume button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    provider.resetAll();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Resume'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Step 1: Score-only card with optional "Optimize Resume" button
  Widget _buildAtsScoreCard(BuildContext context, ThemeData theme, ResumeProvider provider) {
    final scoreResponse = provider.atsScoreResponse!;
    final score = scoreResponse.initialScore;
    final needsOptimization = score < 85;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: needsOptimization ? Colors.orange.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: needsOptimization ? Colors.orange.shade200 : Colors.green.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed,
                  color: needsOptimization ? Colors.orange.shade700 : Colors.green.shade700),
              const SizedBox(width: 8),
              Text('ATS Score',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: needsOptimization ? Colors.orange.shade900 : Colors.green.shade900,
                  )),
            ],
          ),
          const Divider(height: 24),
          Center(child: _scoreCircle(score, 'Your Score', needsOptimization ? Colors.orange : Colors.green)),
          const SizedBox(height: 16),
          // Suggestions
          ...scoreResponse.suggestions.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  needsOptimization ? Icons.info_outline : Icons.check_circle_outline,
                  size: 16,
                  color: needsOptimization ? Colors.orange.shade700 : Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(s, style: TextStyle(
                  color: needsOptimization ? Colors.orange.shade900 : Colors.green.shade900,
                  fontSize: 13,
                ))),
              ],
            ),
          )),
          // Show "Optimize" button if score < 85%
          if (needsOptimization) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: provider.isOptimizing
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ))
                : FilledButton.icon(
                    onPressed: () async {
                      await provider.optimizeResume();
                      // Regenerate the resume with optimized data
                      if (provider.atsResponse?.optimizedData != null) {
                        await provider.generateResume();
                      }
                    },
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Optimize Resume'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  /// Step 2: Optimization result card with before/after scores
  Widget _buildAtsOptimizationCard(ThemeData theme, ResumeProvider provider) {
    final atsResponse = provider.atsResponse!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_fix_high, color: Colors.purple.shade700),
              const SizedBox(width: 8),
              Text('ATS Optimization Results',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: Colors.purple.shade900)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _scoreCircle(atsResponse.initialScore, 'Before', Colors.orange),
              const Icon(Icons.arrow_forward, color: Colors.grey, size: 30),
              if (atsResponse.improvedScore != null)
                _scoreCircle(atsResponse.improvedScore!, 'After', Colors.green),
            ],
          ),
          if (atsResponse.suggestions.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...atsResponse.suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                  Expanded(child: Text(s, style: TextStyle(color: Colors.purple.shade900, fontSize: 13))),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _scoreCircle(int score, String label, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 8,
                backgroundColor: color.withValues(alpha: 0.2),
                color: color,
              ),
            ),
            Text(
              '$score%',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Widget _buildSkillsAnalysis(ThemeData theme, response) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('ATS Skill Analysis',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),

          // Keywords
          if (response.keywords.isNotEmpty) ...[
            const Text('JD Keywords',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: (response.keywords as List<String>).map((kw) {
                return Chip(
                  label: Text(kw, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.blue.shade50,
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Matched skills
          if (response.matchedSkills.isNotEmpty) ...[
            const Text('✅ Matched Skills',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: (response.matchedSkills as List<String>).map((s) {
                return Chip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.green.shade50,
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Missing skills
          if (response.missingSkills.isNotEmpty) ...[
            const Text('⚠️ Consider Adding',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: (response.missingSkills as List<String>).map((s) {
                return Chip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.orange.shade50,
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _downloadPdf(BuildContext context, String? filename) async {
    if (filename == null) return;
    final url = ApiService.getPdfDownloadUrl(filename);
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open PDF: $e')),
        );
      }
    }
  }

  void _sendEmail(BuildContext context, ResumeProvider provider) async {
    final success = await provider.sendEmail();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Email sent to ${provider.resumeData.email}!'
              : 'Failed to send email: ${provider.errorMessage}'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// Simple HTML tag stripper for text preview.
  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true), '')
        .replaceAll(RegExp(r'<[^>]+>'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}
