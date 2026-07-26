import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String description;

  const EmptyStateWidget({
    super.key,
    this.title = 'No records found',
    this.description = 'There are no entries available right now.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2, size: 48, color: AppColors.textMetadata),
          const SizedBox(height: 12),
          Text(title, style: AppTypography.cardTitle),
          const SizedBox(height: 4),
          Text(description, style: AppTypography.captionMetadata),
        ],
      ),
    );
  }
}
