import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../animal/presentation/providers/animal_provider.dart';

/// Matches the query against the user's own animals (name, tag, breed, species).
class SearchResultsPage extends StatefulWidget {
  final String query;
  const SearchResultsPage({super.key, this.query = ''});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  @override
  void initState() {
    super.initState();
    if (animalNotifier.animals.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => animalNotifier.loadAnimals());
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.query.trim().toLowerCase();
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Search Results', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: animalNotifier,
        builder: (context, _) {
          final results = q.isEmpty
              ? const []
              : animalNotifier.animals
                  .where((a) => [a.animalName, a.tagNumber, a.breed, a.species]
                      .any((f) => f != null && f.toLowerCase().contains(q)))
                  .toList();
          if (results.isEmpty && animalNotifier.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (results.isEmpty) {
            return Center(
              child: Text(
                q.isEmpty ? 'Type a name, tag number or breed to search.' : 'No animals match "${widget.query.trim()}".',
                style: AppTypography.captionMetadata,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final a = results[i];
              return ListTile(
                tileColor: AppColors.surfaceCard,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                leading: const Icon(Icons.pets, color: AppColors.primary),
                title: Text('${a.displayName} (${a.tagNumber})', style: AppTypography.cardTitle.copyWith(fontSize: 16)),
                subtitle: Text([a.species, a.breed].whereType<String>().join(' • '), style: AppTypography.captionMetadata),
                onTap: () => context.push('/animal-passport', extra: a.id),
              );
            },
          );
        },
      ),
    );
  }
}
