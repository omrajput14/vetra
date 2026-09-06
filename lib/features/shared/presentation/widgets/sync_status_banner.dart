import 'package:flutter/material.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/offline/sync_status_notifier.dart';

/// Polished, reactive status strip informing users of offline queue state and sync progress.
class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: syncStatusNotifier,
      builder: (context, _) {
        final isOnline = syncStatusNotifier.isOnline;
        final isSyncing = syncStatusNotifier.isSyncing;
        final pendingCount = syncStatusNotifier.pendingCount;

        // If online and nothing is pending/syncing, keep UI completely clean
        if (isOnline && !isSyncing && pendingCount == 0) {
          return const SizedBox.shrink();
        }

        Color bgColor;
        Color textColor;
        IconData iconData;
        String message;
        Widget? actionWidget;

        if (isSyncing) {
          bgColor = AppColors.vetAccent.withValues(alpha: 0.12);
          textColor = AppColors.vetAccent;
          iconData = Icons.sync;
          message = 'Synchronizing with VETRA Cloud...';
          actionWidget = const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.vetAccent),
          );
        } else if (!isOnline) {
          bgColor = AppColors.cautionAmber.withValues(alpha: 0.14);
          textColor = const Color(0xFFC06A1A);
          iconData = Icons.cloud_off_rounded;
          message = pendingCount > 0
              ? 'Offline Mode • $pendingCount update${pendingCount == 1 ? "" : "s"} queued'
              : 'Offline Mode • All changes saved locally';
        } else {
          // Online with pending items waiting for sync cycle
          bgColor = AppColors.primary.withValues(alpha: 0.12);
          textColor = AppColors.primary;
          iconData = Icons.cloud_queue_rounded;
          message = '$pendingCount item${pendingCount == 1 ? "" : "s"} ready to sync';
          actionWidget = TextButton(
            onPressed: () => syncStatusNotifier.syncNow(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              minimumSize: const Size(40, 24),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Sync Now',
              style: AppTypography.captionMetadata.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: textColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(iconData, size: 18, color: textColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.captionMetadata.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              if (actionWidget != null) actionWidget,
            ],
          ),
        );
      },
    );
  }
}
