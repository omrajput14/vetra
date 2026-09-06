import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/models/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/chat_message_model.dart';
import '../providers/appointment_provider.dart';

class AppointmentChatPage extends StatefulWidget {
  final String appointmentId;

  const AppointmentChatPage({super.key, required this.appointmentId});

  @override
  State<AppointmentChatPage> createState() => _AppointmentChatPageState();
}

class _AppointmentChatPageState extends State<AppointmentChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appointmentNotifier.loadChatMessages(widget.appointmentId);
      appointmentNotifier.getAppointmentById(widget.appointmentId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    final success = await appointmentNotifier.sendChatMessage(
      appointmentId: widget.appointmentId,
      content: text,
      messageType: 'TEXT',
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appointmentNotifier.errorMessage ?? 'Failed to send message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPrescribeTreatmentDialog() {
    final diagnosisCtrl = TextEditingController();
    final medicationCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    final careInstructionsCtrl = TextEditingController();
    final followUpCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.medical_services, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Clinical Treatment Instructions', style: AppTypography.cardTitle.copyWith(fontSize: 16)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: diagnosisCtrl,
                decoration: const InputDecoration(
                  labelText: 'Clinical Diagnosis *',
                  hintText: 'e.g. Acute Mastitis / Foot Rot',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: medicationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Prescribed Medication(s)',
                  hintText: 'e.g. Cestocid bolus, Enrofloxacin',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dosageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dosage & Schedule',
                  hintText: 'e.g. 1 bolus morning & evening for 3 days',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: careInstructionsCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Farmer Care & Isolation Instructions *',
                  hintText: 'Keep animal dry, isolate from herd, provide clean water',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: followUpCtrl,
                decoration: const InputDecoration(
                  labelText: 'Follow-up Advice',
                  hintText: 'e.g. Re-evaluate after 5 days if swelling persists',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Issue Treatment Rx'),
            onPressed: () async {
              final diag = diagnosisCtrl.text.trim();
              final care = careInstructionsCtrl.text.trim();
              if (diag.isEmpty || care.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide diagnosis and care instructions.')),
                );
                return;
              }

              final payload = jsonEncode({
                'diagnosis': diag,
                'medication': medicationCtrl.text.trim(),
                'dosage': dosageCtrl.text.trim(),
                'careInstructions': care,
                'followUp': followUpCtrl.text.trim(),
                'issuedAt': DateTime.now().toIso8601String(),
              });

              Navigator.pop(ctx);

              final success = await appointmentNotifier.sendChatMessage(
                appointmentId: widget.appointmentId,
                content: 'Treatment Instructions: $diag - $care',
                messageType: 'TREATMENT_INSTRUCTION',
                treatmentPayloadJson: payload,
              );

              if (mounted) {
                if (success) {
                  Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(appointmentNotifier.errorMessage ?? 'Failed to issue treatment'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVet = authNotifier.currentRole == UserRole.veterinarian;
    final currentUserId = authNotifier.currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Consultation & Treatment', style: AppTypography.screenTitle.copyWith(fontSize: 16)),
            Text('Direct Consultation Chat', style: AppTypography.captionMetadata.copyWith(fontSize: 11)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isVet)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                onPressed: _showPrescribeTreatmentDialog,
                icon: const Icon(Icons.medication, size: 16),
                label: const Text('Issue Rx', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => appointmentNotifier.loadChatMessages(widget.appointmentId),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: appointmentNotifier,
        builder: (context, _) {
          final messages = appointmentNotifier.getMessages(widget.appointmentId);

          return Column(
            children: [
              Expanded(
                child: appointmentNotifier.isChatLoading && messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : messages.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.textMetadata),
                                  const SizedBox(height: 12),
                                  Text('No consultation messages yet', style: AppTypography.cardTitle),
                                  const SizedBox(height: 6),
                                  Text(
                                    isVet
                                        ? 'Send clinical instructions, advise the farmer, or clarify animal symptoms.'
                                        : 'Ask your assigned veterinarian questions or provide updates on your animal.',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.captionMetadata,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: messages.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, idx) {
                              final msg = messages[idx];
                              final isMyMessage = msg.senderId == currentUserId;
                              final isTreatment = msg.messageType == 'TREATMENT_INSTRUCTION';

                              if (isTreatment) {
                                return _buildTreatmentInstructionCard(msg);
                              }

                              return _buildChatBubble(msg, isMyMessage);
                            },
                          ),
              ),
              _buildInputBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatBubble(ChatMessageModel msg, bool isMyMessage) {
    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMyMessage ? AppColors.primary : AppColors.surfaceCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMyMessage ? 14 : 2),
            bottomRight: Radius.circular(isMyMessage ? 2 : 14),
          ),
          border: isMyMessage ? null : Border.all(color: AppColors.borderHairline),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMyMessage)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  msg.senderRole == 'VETERINARIAN' ? 'Dr. ${msg.senderName}' : msg.senderName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isMyMessage ? Colors.white70 : AppColors.primary,
                  ),
                ),
              ),
            Text(
              msg.content,
              style: TextStyle(
                fontSize: 14,
                color: isMyMessage ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg.createdAt.contains('T')
                  ? msg.createdAt.split('T')[1].substring(0, 5)
                  : msg.createdAt,
              style: TextStyle(
                fontSize: 10,
                color: isMyMessage ? Colors.white70 : AppColors.textMetadata,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentInstructionCard(ChatMessageModel msg) {
    Map<String, dynamic> payload = {};
    if (msg.treatmentPayloadJson != null && msg.treatmentPayloadJson!.isNotEmpty) {
      try {
        payload = jsonDecode(msg.treatmentPayloadJson!) as Map<String, dynamic>;
      } catch (_) {}
    }

    final diagnosis = payload['diagnosis']?.toString() ?? 'Clinical Treatment';
    final medication = payload['medication']?.toString();
    final dosage = payload['dosage']?.toString();
    final care = payload['careInstructions']?.toString() ?? msg.content;
    final followUp = payload['followUp']?.toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF81C784), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.green.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
                child: const Icon(Icons.receipt_long, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OFFICIAL TREATMENT INSTRUCTION',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
                    ),
                    Text('Issued by ${msg.senderName}', style: AppTypography.captionMetadata.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(4)),
                child: const Text('Rx', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const Divider(height: 18, color: Color(0xFFA5D6A7)),
          Text('Diagnosis:', style: AppTypography.captionMetadata.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20))),
          Text(diagnosis, style: AppTypography.cardTitle.copyWith(fontSize: 15, color: const Color(0xFF1B5E20))),
          if (medication != null && medication.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Medication(s):', style: AppTypography.captionMetadata.copyWith(fontWeight: FontWeight.bold)),
            Text(medication, style: AppTypography.bodyDefault.copyWith(fontWeight: FontWeight.w600)),
          ],
          if (dosage != null && dosage.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Dosage & Administration:', style: AppTypography.captionMetadata.copyWith(fontWeight: FontWeight.bold)),
            Text(dosage, style: AppTypography.bodySmall),
          ],
          const SizedBox(height: 8),
          Text('Care & Isolation Instructions:', style: AppTypography.captionMetadata.copyWith(fontWeight: FontWeight.bold)),
          Text(care, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
          if (followUp != null && followUp.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Follow-up Advice:', style: AppTypography.captionMetadata.copyWith(fontWeight: FontWeight.bold)),
            Text(followUp, style: AppTypography.captionMetadata.copyWith(color: Colors.orange.shade900)),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              msg.createdAt.split('T').first,
              style: AppTypography.captionMetadata.copyWith(fontSize: 10, color: const Color(0xFF2E7D32)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
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
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Type consultation message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onSubmitted: (_) => _handleSendMessage(),
              ),
            ),
            IconButton(
              onPressed: _isSending ? null : _handleSendMessage,
              icon: _isSending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
