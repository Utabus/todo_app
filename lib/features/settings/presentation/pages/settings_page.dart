import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../todos/presentation/providers/todo_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _hapticsEnabled = true;
  bool _cloudSyncEnabled = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final controller = ref.read(todoControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        title: const Text(
          'Settings & Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            Material(
              color: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryContainer.withValues(alpha: 0.12),
                        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.person_rounded, size: 28, color: AppColors.primaryContainer),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Alex Morgan',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? 'alex.morgan@company.com',
                            style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Organization & Navigation
            const Text(
              'ORGANIZATION',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary, letterSpacing: 0.8),
            ),
            const SizedBox(height: AppSpacing.xs),
            Material(
              color: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.category_outlined, color: AppColors.primaryContainer),
                    title: const Text('Categories & Tags', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Manage groups, colors and tags', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.secondary),
                    onTap: () => context.push(RouteNames.categories),
                  ),
                  const Divider(height: 1, color: AppColors.borderSubtle),
                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryContainer),
                    title: const Text('Notification & Reminders', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Scheduled alerts and reminders', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.secondary),
                    onTap: () => context.push(RouteNames.notifications),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Preferences Section
            const Text(
              'PREFERENCES',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary, letterSpacing: 0.8),
            ),
            const SizedBox(height: AppSpacing.xs),
            Material(
              color: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _hapticsEnabled,
                    title: const Text('Haptic Feedback', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Light vibration upon task completion', style: TextStyle(fontSize: 12)),
                    activeThumbColor: AppColors.primaryContainer,
                    onChanged: (val) => setState(() => _hapticsEnabled = val),
                  ),
                  const Divider(height: 1, color: AppColors.borderSubtle),
                  SwitchListTile(
                    value: _cloudSyncEnabled,
                    title: const Text('Cloud Sync (Firestore)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Automatic offline caching & sync', style: TextStyle(fontSize: 12)),
                    activeThumbColor: AppColors.primaryContainer,
                    onChanged: (val) => setState(() => _cloudSyncEnabled = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Data Management Section
            const Text(
              'DATA MANAGEMENT',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary, letterSpacing: 0.8),
            ),
            const SizedBox(height: AppSpacing.xs),
            Material(
              color: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
              child: ListTile(
                leading: const Icon(Icons.cleaning_services_outlined, color: AppColors.error),
                title: const Text('Clear Completed Tasks',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error)),
                subtitle: const Text('Remove all finished tasks from list', style: TextStyle(fontSize: 12)),
                onTap: () {
                  controller.clearCompleted();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Completed tasks cleared')),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // App Info
            Center(
              child: Column(
                children: const [
                  Text(
                    'Todo App • Calm Productivity',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Version 1.0.0 (Build 2026.09.30)',
                    style: TextStyle(fontSize: 11, color: AppColors.outline),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
