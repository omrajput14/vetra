import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Help & Support', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── National helpline ─────────────────────────────────────────────
          ListTile(
            tileColor: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            leading: const Icon(Icons.call, color: AppColors.primary),
            title: Text(
              'Kisan Call Centre (Toll-Free)',
              style: AppTypography.cardTitle.copyWith(fontSize: 16),
            ),
            subtitle: Text(
              '1800-180-1551  ·  24 × 7',
              style: AppTypography.captionMetadata,
            ),
          ),
          const SizedBox(height: 8),

          // ── State vet helpdesk ────────────────────────────────────────────
          ListTile(
            tileColor: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            leading:
                const Icon(Icons.business, color: AppColors.primary),
            title: Text(
              'State Veterinary Helpdesk',
              style: AppTypography.cardTitle.copyWith(fontSize: 16),
            ),
            subtitle: Text(
              'Contact your district animal husbandry office for local assistance.',
              style: AppTypography.captionMetadata,
            ),
          ),
          const SizedBox(height: 8),

          // ── App support email ─────────────────────────────────────────────
          ListTile(
            tileColor: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            leading:
                const Icon(Icons.email_outlined, color: AppColors.primary),
            title: Text(
              'App Support',
              style: AppTypography.cardTitle.copyWith(fontSize: 16),
            ),
            subtitle: Text(
              'support@pashusathi.in',
              style: AppTypography.captionMetadata,
            ),
          ),
          const SizedBox(height: 24),

          // ── FAQ section ────────────────────────────────────────────────────
          Text('Frequently Asked Questions',
              style: AppTypography.cardTitle.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          const _FaqItem(
            question: 'How do I register an animal?',
            answer:
                'Go to My Animals → tap the + button → fill in the tag number, species, and breed details.',
          ),
          const SizedBox(height: 8),
          const _FaqItem(
            question: 'What happens when I report a disease offline?',
            answer:
                'The report is saved locally and automatically submitted to the surveillance server when connectivity is restored.',
          ),
          const SizedBox(height: 8),
          const _FaqItem(
            question: 'Who can see my farm data?',
            answer:
                'Only authorised veterinary officers and government health officials can access your data. See Privacy Policy for full details.',
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question,
              style:
                  AppTypography.cardTitle.copyWith(fontSize: 14)),
          const SizedBox(height: 6),
          Text(answer, style: AppTypography.captionMetadata),
        ],
      ),
    );
  }
}
