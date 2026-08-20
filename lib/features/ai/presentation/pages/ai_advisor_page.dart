import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../animal/presentation/providers/animal_provider.dart';
import '../../data/models/ai_advisor_models.dart';
import '../providers/ai_advisor_provider.dart';

class AIAdvisorPage extends StatefulWidget {
  final String animalId;
  final String? sessionId;

  const AIAdvisorPage({
    super.key,
    required this.animalId,
    this.sessionId,
  });

  @override
  State<AIAdvisorPage> createState() => _AIAdvisorPageState();
}

class _AIAdvisorPageState extends State<AIAdvisorPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.sessionId != null && widget.sessionId!.isNotEmpty) {
        aiAdvisorNotifier.loadSession(widget.sessionId!);
      } else {
        aiAdvisorNotifier.startSession(widget.animalId);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage([String? prefilledText]) async {
    final text = prefilledText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    if (prefilledText == null) {
      _messageController.clear();
    }

    final success = await aiAdvisorNotifier.sendMessage(text);
    if (success) {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([aiAdvisorNotifier, animalNotifier]),
      builder: (context, _) {
        final animals = animalNotifier.animals;
        final animal = animals.isNotEmpty
            ? animals.firstWhere(
                (a) => a.id == widget.animalId,
                orElse: () => animals.first,
              )
            : null;

        final session = aiAdvisorNotifier.currentSession;
        final isLoading = aiAdvisorNotifier.isLoading;
        final isSending = aiAdvisorNotifier.isSending;
        final errorMessage = aiAdvisorNotifier.errorMessage;

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceCard,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => context.pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Veterinary Advisor',
                  style: AppTypography.screenTitle.copyWith(fontSize: 18),
                ),
                Text(
                  'Assistive Clinical Screening',
                  style: AppTypography.captionMetadata.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                onPressed: () => aiAdvisorNotifier.startSession(widget.animalId),
                tooltip: 'Start New Session',
              ),
            ],
          ),
          body: Column(
            children: [
              // 1. Animal Context Banner
              if (animal != null) _buildAnimalHeader(animal),

              // 2. Urgent Escalation Banner (if applicable)
              if (session != null &&
                  (session.status == AIAdvisorSessionStatus.urgentVeterinaryReview ||
                      session.riskLevel == AIAdvisorRiskLevel.critical))
                _buildEmergencyBanner(context, animal?.id ?? widget.animalId),

              // 3. Conversation & Assessment Stream
              Expanded(
                child: isLoading && session == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 16),
                            Text('Initializing Advisor Context...'),
                          ],
                        ),
                      )
                    : errorMessage != null && session == null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline,
                                      size: 48, color: AppColors.alertCritical),
                                  const SizedBox(height: 12),
                                  Text(errorMessage,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.bodyDefault.copyWith(fontSize: 14)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => aiAdvisorNotifier
                                        .startSession(widget.animalId),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary),
                                    child: const Text('Try Again',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _buildMessageList(session),
              ),

              // 4. Booking Consultation Action (if assessment is available)
              if (session?.assessment != null)
                _buildConsultationBar(context, animal?.id ?? widget.animalId),

              // 5. Input Field
              _buildInputArea(isSending),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimalHeader(dynamic animal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(
          bottom: BorderSide(color: AppColors.borderHairline),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.displayName ?? 'Animal',
                  style: AppTypography.cardTitle.copyWith(fontSize: 15),
                ),
                Text(
                  '${animal.species} • ${animal.breed ?? 'Unknown Breed'} • Tag: ${animal.tagNumber}',
                  style: AppTypography.captionMetadata,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Chip(
            label: Text('Live Context', style: TextStyle(fontSize: 11, color: Colors.white)),
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyBanner(BuildContext context, String animalId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.alertCritical.withValues(alpha: 0.12),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.alertCritical, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Urgent Clinical Concern',
                  style: AppTypography.cardTitle
                      .copyWith(color: AppColors.alertCritical, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'Reported symptoms warrant immediate on-site veterinary evaluation.',
                  style: AppTypography.captionMetadata
                      .copyWith(color: AppColors.textPrimary, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/appointment-booking', extra: animalId),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertCritical,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Book Vet', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(AIAdvisorSessionModel? session) {
    final messages = session?.messages ?? [];

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: messages.length + (session?.assessment != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < messages.length) {
          final msg = messages[index];
          return _buildMessageItem(msg);
        } else {
          return _buildAssessmentCard(session!.assessment!);
        }
      },
    );
  }

  Widget _buildMessageItem(AIAdvisorMessageModel msg) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.medical_services,
                      size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isUser ? const Radius.circular(0) : null,
                      bottomLeft: !isUser ? const Radius.circular(0) : null,
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: AppColors.borderHairline),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.cautionAmber,
                  child: Icon(Icons.person, size: 16, color: Colors.white),
                ),
              ],
            ],
          ),
          if (!isUser && msg.followUpQuestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: msg.followUpQuestions.map((q) {
                  return ActionChip(
                    label: Text(
                      q,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                    onPressed: () => _handleSendMessage(q),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(AIAdvisorAssessmentModel assessment) {
    final riskColor = _getRiskColor(assessment.riskLevel);

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: riskColor.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.assignment_outlined, color: riskColor, size: 22),
                  const SizedBox(width: 8),
                  Text('Preliminary Assessment',
                      style: AppTypography.cardTitle.copyWith(fontSize: 16)),
                ],
              ),
              Chip(
                label: Text(
                  assessment.riskLevel.toDisplayString(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
                backgroundColor: riskColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const Divider(height: 24),

          // Suspected Conditions
          Text('Suspected Conditions',
              style: AppTypography.captionMetadata
                  .copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...assessment.possibleConditions.map((cond) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderHairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          cond.condition,
                          style: AppTypography.bodyDefault
                              .copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'AI Confidence ${(cond.confidence * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (cond.reasoning.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      cond.reasoning,
                      style: AppTypography.captionMetadata
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            );
          }),

          // Owner-Reported Symptoms & Vitals
          if (assessment.userReportedSymptoms.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.fact_check_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('Owner-Reported Symptoms & Vitals',
                    style: AppTypography.captionMetadata
                        .copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 6),
            ...assessment.userReportedSymptoms.map((sym) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✓ ',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(sym,
                            style: AppTypography.bodyDefault
                                .copyWith(fontSize: 13)),
                      ),
                    ],
                  ),
                )),
          ],

          // AI Clinical Observations
          if (assessment.keyObservations.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.psychology_outlined, size: 16, color: AppColors.vetAccent),
                const SizedBox(width: 6),
                Text('AI Clinical Observations',
                    style: AppTypography.captionMetadata
                        .copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 6),
            ...assessment.keyObservations.map((obs) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(
                              color: AppColors.vetAccent,
                              fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(obs,
                            style: AppTypography.bodyDefault
                                .copyWith(fontSize: 13)),
                      ),
                    ],
                  ),
                )),
          ],

          // Recommended Next Step
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cautionAmber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppColors.cautionAmber.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: AppColors.cautionAmber),
                    const SizedBox(width: 6),
                    Text(
                      'Recommended Supportive Care',
                      style: AppTypography.captionMetadata.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.cautionAmber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  assessment.recommendedNextStep,
                  style:
                      AppTypography.bodyDefault.copyWith(fontSize: 13, height: 1.3),
                ),
              ],
            ),
          ),

          // Safety Disclaimer
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  assessment.disclaimer,
                  style: AppTypography.captionMetadata
                      .copyWith(fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationBar(BuildContext context, String animalId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(top: BorderSide(color: AppColors.borderHairline)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton.icon(
          onPressed: () => context.push('/appointment-booking', extra: animalId),
          icon: const Icon(Icons.calendar_month, color: Colors.white, size: 20),
          label: const Text(
            'Book Vet Consultation',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isSending) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(top: BorderSide(color: AppColors.borderHairline)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderHairline),
                ),
                child: TextField(
                  controller: _messageController,
                  enabled: !isSending,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSendMessage(),
                  decoration: const InputDecoration(
                    hintText: 'Describe symptoms or answer questions...',
                    hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: isSending ? null : () => _handleSendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(AIAdvisorRiskLevel level) {
    switch (level) {
      case AIAdvisorRiskLevel.critical:
      case AIAdvisorRiskLevel.severe:
        return AppColors.alertCritical;
      case AIAdvisorRiskLevel.moderate:
        return AppColors.cautionAmber;
      case AIAdvisorRiskLevel.mild:
        return AppColors.primary;
      case AIAdvisorRiskLevel.unknown:
        return AppColors.textSecondary;
    }
  }
}
