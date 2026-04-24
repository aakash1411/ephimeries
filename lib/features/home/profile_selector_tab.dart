import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/services/timezone_service.dart';
import '../../domain/models/birth_profile.dart';
import '../../providers/birth_profiles_provider.dart';

/// In-shell profile manager tab. Lives at `/profile/:id/home`. Shares
/// behaviour with [HomeScreen] but renders without its own AppBar — the
/// surrounding [ProfileShell] already provides one.
class ProfileSelectorTab extends ConsumerWidget {
  const ProfileSelectorTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(birthProfilesProvider);
    final activeId = ref.watch(activeProfileIdProvider);
    final df = DateFormat.yMMMd().add_jm();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/profile/new'),
        icon: const Icon(Icons.add),
        label: const Text('New profile'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profiles) {
          if (profiles.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
            itemCount: profiles.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _ProfileCard(
              profile: profiles[i],
              df: df,
              isActive: profiles[i].id == activeId,
            ),
          );
        },
      ),
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard({
    required this.profile,
    required this.df,
    required this.isActive,
  });

  final BirthProfile profile;
  final DateFormat df;
  final bool isActive;

  Future<bool> _confirmDelete(BuildContext context) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${profile.name}"?'),
        content: const Text('This will remove the profile and its charts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return r ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey('profile-${profile.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) =>
          ref.read(birthProfilesProvider.notifier).delete(profile.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isActive ? scheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor:
                isActive ? scheme.primary : scheme.secondaryContainer,
            foregroundColor:
                isActive ? scheme.onPrimary : scheme.onSecondaryContainer,
            child: Text(
              profile.name.isNotEmpty ? profile.name.characters.first : '?',
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  profile.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isActive)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.check_circle,
                      size: 16, color: scheme.primary),
                ),
            ],
          ),
          subtitle: Text(
            '${TimezoneService.formatInZone(profile.dateTime, profile.timezoneName, df)}\n${profile.placeLabel}',
          ),
          isThreeLine: true,
          trailing: PopupMenuButton<String>(
            onSelected: (v) {
              switch (v) {
                case 'edit':
                  context.push('/profile/${profile.id}/edit');
                case 'delete':
                  _confirmDelete(context).then((ok) {
                    if (ok) {
                      ref
                          .read(birthProfilesProvider.notifier)
                          .delete(profile.id);
                    }
                  });
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
          onTap: () {
            if (isActive) return; // already on this profile
            ref.read(activeProfileIdProvider.notifier).state = profile.id;
            context.go('/profile/${profile.id}/natal');
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 64),
            const SizedBox(height: 16),
            Text(
              'No profiles yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first birth profile to compute its Vedic chart.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
