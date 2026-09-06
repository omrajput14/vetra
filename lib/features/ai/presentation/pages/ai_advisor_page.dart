import 'package:vetra/features/appointment/data/models/appointment_dto.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../animal/presentation/providers/animal_provider.dart';
import '../../data/models/ai_advisor_models.dart';
import '../providers/ai_advisor_provider.dart';
import '../providers/ai_scan_provider.dart';

class AIAdvisorPage extends ConsumerStatefulWidget {
  final String animalId;
  final String? sessionId;

  const AIAdvisorPage({
    super.key,
    required this.animalId,
    this.sessionId,
  });

  @override
  ConsumerState<AIAdvisorPage> createState() => _AIAdvisorPageState();
}

class _AIAdvisorPageState extends ConsumerState<AIAdvisorPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final SpeechService _speechService;
  late final TtsService _ttsService;
  StreamSubscription<TtsPlaybackState>? _ttsSubscription;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  VoiceState _voiceState = VoiceState.idle;
  TtsState _ttsState = TtsState.idle;
  String? _speakingMessageId;
  bool _autoSpeakNextResponse = false;

  @override
  void initState() {
    super.initState();
    _speechService = SpeechService.instance;
    _ttsService = TtsService.instance;

    _ttsSubscription = _ttsService.stateStream.listen((playback) {
      if (mounted) {
        setState(() {
          _ttsState = playback.state;
          _speakingMessageId = playback.messageId;
        });
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentLocale = ref.read(localeProvider);
      if (widget.sessionId != null && widget.sessionId!.isNotEmpty) {
        aiAdvisorNotifier.loadSession(widget.sessionId!);
      } else {
        final targetId = await _resolveActiveAnimalId();
        if (targetId != null && targetId.isNotEmpty) {
          animalNotifier.setSelectedAnimalId(targetId);
          aiAdvisorNotifier.startSession(
            targetId,
            preferredLanguage: currentLocale.languageCode,
          );
        } else {
          aiAdvisorNotifier.setErrorMessage('No active animal context');
        }
      }
    });
  }

  @override
  void dispose() {
    _ttsSubscription?.cancel();
    _ttsService.stop();
    _speechService.cancelListening();
    _pulseController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  Future<String?> _resolveActiveAnimalId() async {
    if (widget.animalId.trim().isNotEmpty) {
      return widget.animalId.trim();
    }
    if (animalNotifier.selectedAnimalId != null && animalNotifier.selectedAnimalId!.trim().isNotEmpty) {
      return animalNotifier.selectedAnimalId!.trim();
    }
    if (aiScanNotifier.selectedAnimalId != null && aiScanNotifier.selectedAnimalId!.trim().isNotEmpty) {
      return aiScanNotifier.selectedAnimalId!.trim();
    }
    // If the animal list is empty (e.g. user navigated directly to AI Advisor),
    // load from local cache first before giving up. This ensures AI Advisor
    // always uses the same authoritative local-first source as My Animals.
    if (animalNotifier.animals.isEmpty) {
      await animalNotifier.loadAnimals();
    }
    if (animalNotifier.animals.isNotEmpty) {
      return animalNotifier.animals.first.id;
    }
    return null;
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

  Future<void> _handleToggleVoiceInput() async {
    final l10n = AppLocalizations.of(context);
    final activeLocale = ref.read(localeProvider);

    // Stop any ongoing TTS speech first
    if (_ttsState == TtsState.playing) {
      await _ttsService.stop();
    }

    if (_voiceState == VoiceState.listening) {
      await _speechService.stopListening();
      _pulseController.stop();
      if (mounted) {
        setState(() {
          _voiceState = VoiceState.idle;
        });
      }
      return;
    }

    final initialized = await _speechService.initialize();
    if (!initialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.voiceNotAvailable ?? 'Voice input not available on this device.',
            ),
            backgroundColor: AppColors.alertCritical,
          ),
        );
      }
      return;
    }

    _autoSpeakNextResponse = true;

    if (mounted) {
      setState(() {
        _voiceState = VoiceState.listening;
      });
      _pulseController.repeat(reverse: true);
    }

    await _speechService.startListening(
      languageCode: activeLocale.languageCode,
      onResult: (recognizedText) {
        if (mounted && recognizedText.isNotEmpty) {
          setState(() {
            _messageController.text = recognizedText;
            _messageController.selection = TextSelection.fromPosition(
              TextPosition(offset: _messageController.text.length),
            );
          });
        }
      },
      onStateChanged: (state) {
        if (mounted) {
          setState(() {
            _voiceState = state;
          });
          if (state != VoiceState.listening) {
            _pulseController.stop();
          }
        }
      },
      onError: (error) {
        if (mounted) {
          _pulseController.stop();
          setState(() {
            _voiceState = VoiceState.idle;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.voiceError ?? 'Could not understand speech. Please try again.',
              ),
              backgroundColor: AppColors.alertCritical,
            ),
          );
        }
      },
    );
  }

  Future<void> _handleSendMessage([String? prefilledText, bool isVoice = false]) async {
    // Stop any ongoing TTS or voice listening
    if (_ttsState == TtsState.playing) {
      await _ttsService.stop();
    }

    if (_voiceState == VoiceState.listening) {
      await _speechService.stopListening();
      _pulseController.stop();
      if (mounted) {
        setState(() {
          _voiceState = VoiceState.idle;
        });
      }
    }

    final text = prefilledText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    if (prefilledText == null) {
      _messageController.clear();
    }

    final currentLocale = ref.read(localeProvider);
    final targetAnimalId = await _resolveActiveAnimalId();
    if (targetAnimalId == null || targetAnimalId.isEmpty) {
      aiAdvisorNotifier.setErrorMessage('No active animal context');
      return;
    }
    animalNotifier.setSelectedAnimalId(targetAnimalId);

    final shouldAutoSpeak = _autoSpeakNextResponse || isVoice;
    _autoSpeakNextResponse = false;

    final success = await aiAdvisorNotifier.sendMessage(
      text,
      animalId: targetAnimalId,
      preferredLanguage: currentLocale.languageCode,
    );
    if (success) {
      _scrollToBottom();
      if (shouldAutoSpeak) {
        final messages = aiAdvisorNotifier.messages;
        if (messages.isNotEmpty) {
          final latest = messages.last;
          if (!latest.isUser) {
            await _ttsService.speak(
              latest.content,
              languageCode: currentLocale.languageCode,
              messageId: latest.id,
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activeLocale = ref.watch(localeProvider);

    return AnimatedBuilder(
      animation: Listenable.merge([aiAdvisorNotifier, animalNotifier]),
      builder: (context, _) {
        final animals = animalNotifier.animals;
        final activeId = widget.animalId.isNotEmpty
            ? widget.animalId
            : (animalNotifier.selectedAnimalId ?? (animals.isNotEmpty ? animals.first.id : ''));
        final animal = animals.isNotEmpty
            ? animals.firstWhere(
                (a) => a.id == activeId,
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
                  l10n?.aiVeterinaryAdvisor ?? 'AI Veterinary Advisor',
                  style: AppTypography.screenTitle.copyWith(fontSize: 18),
                ),
                Text(
                  l10n?.assistiveClinicalScreening ?? 'Assistive Clinical Screening',
                  style: AppTypography.captionMetadata.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () => context.push('/language-settings'),
                icon: const Icon(Icons.language, size: 16, color: AppColors.primary),
                label: Text(
                  AppLocales.getLanguageNativeName(activeLocale.languageCode),
                  style: AppTypography.captionMetadata.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                onPressed: () async {
                  final targetId = await _resolveActiveAnimalId();
                  if (targetId != null && targetId.isNotEmpty) {
                    animalNotifier.setSelectedAnimalId(targetId);
                    aiAdvisorNotifier.startSession(
                      targetId,
                      preferredLanguage: activeLocale.languageCode,
                    );
                  }
                },
                tooltip: l10n?.startNewSession ?? 'Start New Session',
              ),
            ],
          ),
          body: Column(
            children: [
              // 1. Animal Context Banner
              if (animal != null) _buildAnimalHeader(animal, l10n),

              // 2. Urgent Escalation Banner (if applicable)
              if (session != null &&
                  (session.status == AIAdvisorSessionStatus.urgentVeterinaryReview ||
                      session.riskLevel == AIAdvisorRiskLevel.critical))
                _buildEmergencyBanner(context, animal?.id ?? widget.animalId, l10n),

              // 3. Conversation & Assessment Stream
              Expanded(
                child: isLoading && session == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: AppColors.primary),
                            const SizedBox(height: 16),
                            Text(l10n?.loading ?? 'Initializing Advisor Context...'),
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
                                    onPressed: () async {
                                      final targetId = await _resolveActiveAnimalId();
                                      if (targetId != null && targetId.isNotEmpty) {
                                        animalNotifier.setSelectedAnimalId(targetId);
                                        aiAdvisorNotifier.startSession(
                                          targetId,
                                          preferredLanguage: activeLocale.languageCode,
                                        );
                                      } else {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(l10n?.noAnimalsYet ?? 'Please add or select an animal first.'),
                                            backgroundColor: AppColors.alertCritical,
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary),
                                    child: Text(l10n?.retry ?? 'Try Again',
                                        style: const TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _buildMessageList(session, l10n),
              ),

              // 4. Booking Consultation Action (if assessment is available)
              if (session?.assessment != null)
                _buildConsultationBar(context, animal?.id ?? widget.animalId, l10n),

              // 5. Input Field
              _buildInputArea(isSending, l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimalHeader(dynamic animal, AppLocalizations? l10n) {
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
          Chip(
            label: Text(l10n?.liveContext ?? 'Live Context', style: const TextStyle(fontSize: 11, color: Colors.white)),
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyBanner(BuildContext context, String animalId, AppLocalizations? l10n) {
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
                  l10n?.urgentClinicalConcern ?? 'Urgent Clinical Concern',
                  style: AppTypography.cardTitle
                      .copyWith(color: AppColors.alertCritical, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n?.urgentConcernNotice ?? 'Reported symptoms warrant immediate on-site veterinary evaluation.',
                  style: AppTypography.captionMetadata
                      .copyWith(color: AppColors.textPrimary, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/appointment-booking', extra: {
              'animalId': animalId,
              'isEmergency': true,
              'visitType': VisitType.emergency,
              'reason': 'EMERGENCY AI TRIAGE: Urgent Clinical Concern',
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertCritical,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l10n?.bookVet ?? 'Book Vet', style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(AIAdvisorSessionModel? session, AppLocalizations? l10n) {
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
          return _buildAssessmentCard(session!.assessment!, l10n);
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.content,
                        style: TextStyle(
                          fontSize: 14,
                          color: isUser ? Colors.white : AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      if (!isUser) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                if (_ttsState == TtsState.playing && _speakingMessageId == msg.id) {
                                  _ttsService.stop();
                                } else {
                                  final activeLocale = ref.read(localeProvider);
                                  _ttsService.speak(
                                    msg.content,
                                    languageCode: activeLocale.languageCode,
                                    messageId: msg.id,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (_ttsState == TtsState.playing && _speakingMessageId == msg.id)
                                      ? AppColors.primary.withValues(alpha: 0.12)
                                      : AppColors.surfaceBackground,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: (_ttsState == TtsState.playing && _speakingMessageId == msg.id)
                                        ? AppColors.primary
                                        : AppColors.borderHairline,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      (_ttsState == TtsState.playing && _speakingMessageId == msg.id)
                                          ? Icons.volume_up_rounded
                                          : Icons.volume_up_outlined,
                                      size: 14,
                                      color: (_ttsState == TtsState.playing && _speakingMessageId == msg.id)
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      (_ttsState == TtsState.playing && _speakingMessageId == msg.id)
                                          ? _getSpeakingLabel(ref.read(localeProvider).languageCode)
                                          : _getReadAloudLabel(ref.read(localeProvider).languageCode),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: (_ttsState == TtsState.playing && _speakingMessageId == msg.id)
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: (_ttsState == TtsState.playing && _speakingMessageId == msg.id)
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                    if (_ttsState == TtsState.playing && _speakingMessageId == msg.id) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.stop_circle_rounded, size: 14, color: AppColors.alertCritical),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
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

  Widget _buildAssessmentCard(AIAdvisorAssessmentModel assessment, AppLocalizations? l10n) {
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
                  Text(l10n?.preliminaryAssessment ?? 'Preliminary Assessment',
                      style: AppTypography.cardTitle.copyWith(fontSize: 16)),
                ],
              ),
              Chip(
                label: Text(
                  _getRiskLabel(assessment.riskLevel, l10n),
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
          Text(l10n?.suspectedConditions ?? 'Suspected Conditions',
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
                          '${l10n?.confidence ?? "AI Confidence"} ${(cond.confidence * 100).toInt()}%',
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
                Text(l10n?.ownerReportedSymptoms ?? 'Owner-Reported Symptoms & Vitals',
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
                Text(l10n?.aiClinicalObservations ?? 'AI Clinical Observations',
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
                      l10n?.recommendedSupportiveCare ?? 'Recommended Supportive Care',
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

  Widget _buildConsultationBar(BuildContext context, String animalId, AppLocalizations? l10n) {
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
          label: Text(
            l10n?.bookVetConsultation ?? 'Book Vet Consultation',
            style: const TextStyle(
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

  Widget _buildInputArea(bool isSending, AppLocalizations? l10n) {
    final isListening = _voiceState == VoiceState.listening;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(top: BorderSide(color: AppColors.borderHairline)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_voiceState == VoiceState.listening)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.alertCritical.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.alertCritical,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getListeningBannerText(ref.watch(localeProvider).languageCode),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.alertCritical,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _handleToggleVoiceInput,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_ttsState == TtsState.playing)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.primary.withValues(alpha: 0.12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.volume_up_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getSpeakingBannerText(ref.watch(localeProvider).languageCode),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _ttsService.stop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.alertCritical.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.stop_circle_rounded,
                              size: 14,
                              color: AppColors.alertCritical,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getStopLabel(ref.watch(localeProvider).languageCode),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.alertCritical,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (isSending)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.primary.withValues(alpha: 0.08),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getThinkingBannerText(ref.watch(localeProvider).languageCode),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBackground,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isListening
                              ? AppColors.alertCritical
                              : AppColors.borderHairline,
                          width: isListening ? 1.5 : 1.0,
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        enabled: !isSending,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSendMessage(),
                        decoration: InputDecoration(
                          hintText: isListening
                              ? (l10n?.voiceListening ?? 'Listening...')
                              : (l10n?.typeMessageHint ??
                                  l10n?.describeSymptomsHint ??
                                  'Describe symptoms or answer questions...'),
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: isListening
                                ? AppColors.alertCritical
                                : AppColors.textSecondary,
                            fontWeight: isListening
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: isListening
                        ? (l10n?.voiceListening ?? 'Listening...')
                        : (l10n?.voiceInputTapToSpeak ?? 'Tap to speak'),
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: isListening ? _pulseAnimation.value : 1.0,
                          child: child,
                        );
                      },
                      child: Material(
                        color: isListening
                            ? AppColors.alertCritical
                            : (_ttsState == TtsState.playing
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.surfaceBackground),
                        shape: const CircleBorder(),
                        elevation: isListening ? 2 : 0,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: isSending ? null : _handleToggleVoiceInput,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isListening
                                    ? AppColors.alertCritical
                                    : (_ttsState == TtsState.playing
                                        ? AppColors.primary
                                        : AppColors.borderHairline),
                              ),
                            ),
                            child: Icon(
                              isListening
                                  ? Icons.mic_rounded
                                  : Icons.mic_none_rounded,
                              color: isListening
                                  ? Colors.white
                                  : AppColors.primary,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
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
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                      onPressed: isSending ? null : () => _handleSendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSpeakingLabel(String lang) {
    switch (lang.toLowerCase()) {
      case 'mr':
        return 'बोलत आहे';
      case 'hi':
        return 'बोल रहा है';
      default:
        return 'Speaking';
    }
  }

  String _getReadAloudLabel(String lang) {
    switch (lang.toLowerCase()) {
      case 'mr':
        return 'ऐका';
      case 'hi':
        return 'सुनें';
      default:
        return 'Read Aloud';
    }
  }

  String _getStopLabel(String lang) {
    switch (lang.toLowerCase()) {
      case 'mr':
        return 'थांबवा';
      case 'hi':
        return 'रोकें';
      default:
        return 'Stop';
    }
  }

  String _getListeningBannerText(String lang) {
    switch (lang.toLowerCase()) {
      case 'mr':
        return 'मराठीत ऐकत आहे... लक्षणे सांगा';
      case 'hi':
        return 'हिंदी में सुन रहा है... लक्षण बताएं';
      default:
        return 'Listening in English... Speak symptoms now';
    }
  }

  String _getSpeakingBannerText(String lang) {
    switch (lang.toLowerCase()) {
      case 'mr':
        return 'एआय उत्तर वाचत आहे...';
      case 'hi':
        return 'एआई उत्तर पढ़ रहा है...';
      default:
        return 'AI is speaking response...';
    }
  }

  String _getThinkingBannerText(String lang) {
    switch (lang.toLowerCase()) {
      case 'mr':
        return 'प्राण्याच्या नोंदी तपासून एआय विश्लेषण करत आहे...';
      case 'hi':
        return 'पशु संदर्भ के साथ एआई विश्लेषण कर रहा है...';
      default:
        return 'AI is analyzing with live animal context...';
    }
  }

  String _getRiskLabel(AIAdvisorRiskLevel level, AppLocalizations? l10n) {
    switch (level) {
      case AIAdvisorRiskLevel.critical:
        return l10n?.criticalStatus ?? 'Critical';
      case AIAdvisorRiskLevel.severe:
        return 'Severe';
      case AIAdvisorRiskLevel.moderate:
        return 'Moderate';
      case AIAdvisorRiskLevel.mild:
        return 'Mild';
      case AIAdvisorRiskLevel.unknown:
        return 'Unknown';
    }
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
