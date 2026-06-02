// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../models/user_profile_model.dart';
import '../providers/user_profile_provider.dart';
import '../providers/comparison_provider.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'compare_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _remindersEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReminderState();
  }

  Future<void> _loadReminderState() async {
    final enabled = await NotificationService.instance.areMealRemindersEnabled();
    if (mounted) {
      setState(() => _remindersEnabled = enabled);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);
    final comparisonCount = ref.watch(comparisonCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (comparisonCount > 0)
            Badge(
              label: Text(comparisonCount.toString()),
              child: IconButton(
                icon: const Icon(Icons.compare_arrows),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CompareScreen()),
                  );
                },
                tooltip: 'Compare products',
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'History'),
            Tab(text: 'Favorites'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryTab(),
          _buildFavoritesTab(),
          _buildSettingsTab(profileState),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final history = StorageService.getHistory();

    if (history.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'No Scan History',
        subtitle: 'Products you scan will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final product = history[index];
        return ProductCard(
          product: product,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    final favorites = StorageService.getFavorites();

    if (favorites.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite,
        title: 'No Favorites',
        subtitle: 'Tap the heart icon on products to save them here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final product = favorites[index];
        return ProductCard(
          product: product,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsTab(UserProfileState profileState) {
    final profile = profileState.profile;
    final nutritionGoals = profile?.nutritionGoals ?? NutritionGoals();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Notifications Section
        _buildSectionHeader('Notifications'),
        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Meal Reminders'),
            subtitle: const Text('Daily reminders to log your meals'),
            trailing: Switch(
              value: _remindersEnabled,
              onChanged: (enabled) async {
                if (enabled) {
                  await NotificationService.instance.enableMealReminders();
                } else {
                  await NotificationService.instance.disableMealReminders();
                }
                setState(() => _remindersEnabled = enabled);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Theme Section
        _buildSectionHeader('Appearance'),
        Card(
          child: ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Consumer(
              builder: (context, ref, _) {
                final themeMode = ref.watch(themeModeProvider);
                return Switch(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (_) {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Nutrition Goals Section
        _buildSectionHeader('Nutrition Goals'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.local_fire_department),
                title: const Text('Daily Calories'),
                trailing: Text('${nutritionGoals.dailyCalories.toInt()} kcal'),
                onTap: () => _showGoalDialog(
                  'Daily Calories',
                  nutritionGoals.dailyCalories,
                  1200,
                  4000,
                  (value) => _updateGoal(
                    nutritionGoals.copyWith(dailyCalories: value),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('Daily Protein'),
                trailing: Text('${nutritionGoals.dailyProtein.toInt()}g'),
                onTap: () => _showGoalDialog(
                  'Daily Protein',
                  nutritionGoals.dailyProtein,
                  20,
                  200,
                  (value) => _updateGoal(
                    nutritionGoals.copyWith(dailyProtein: value),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.grain),
                title: const Text('Daily Carbs'),
                trailing: Text('${nutritionGoals.dailyCarbs.toInt()}g'),
                onTap: () => _showGoalDialog(
                  'Daily Carbs',
                  nutritionGoals.dailyCarbs,
                  50,
                  500,
                  (value) => _updateGoal(
                    nutritionGoals.copyWith(dailyCarbs: value),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.opacity),
                title: const Text('Daily Fat'),
                trailing: Text('${nutritionGoals.dailyFat.toInt()}g'),
                onTap: () => _showGoalDialog(
                  'Daily Fat',
                  nutritionGoals.dailyFat,
                  20,
                  150,
                  (value) => _updateGoal(
                    nutritionGoals.copyWith(dailyFat: value),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Allergens Section
        _buildSectionHeader('Allergens to Avoid'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You\'ll be warned when scanned products contain these allergens',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CommonAllergens.all.map((allergen) {
                    final isSelected =
                        profile?.allergensToAvoid.contains(allergen) ?? false;
                    return FilterChip(
                      label: Text(allergen),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref
                              .read(userProfileProvider.notifier)
                              .addAllergen(allergen);
                        } else {
                          ref
                              .read(userProfileProvider.notifier)
                              .removeAllergen(allergen);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Data Section
        _buildSectionHeader('Data'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Clear History'),
                onTap: () => _showClearConfirmation(
                  'Clear History',
                  'This will delete all your scan history.',
                  () async {
                    await StorageService.clearHistory();
                    if (mounted) {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('History cleared')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // About Section
        _buildSectionHeader('About'),
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Version'),
                trailing: Text('1.0.5'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () => _launchUrl('https://nutrilenspro.web.app/privacy'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () => _launchUrl('https://nutrilenspro.web.app/terms'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Open Source Licenses'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'NutriLens Pro',
                    applicationVersion: '1.0.5',
                    applicationIcon:
                        Image.asset('assets/icons/app_icon.png', width: 48),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Data Source'),
                subtitle: const Text('Powered by Open Food Facts'),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () => _launchUrl('https://world.openfoodfacts.org'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDialog(
    String title,
    double currentValue,
    double min,
    double max,
    Function(double) onSave,
  ) {
    double tempValue = currentValue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tempValue.toInt().toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Slider(
                value: tempValue,
                min: min,
                max: max,
                divisions: ((max - min) / 10).toInt(),
                onChanged: (value) {
                  setState(() => tempValue = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                onSave(tempValue);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateGoal(NutritionGoals goals) {
    ref.read(userProfileProvider.notifier).setNutritionGoals(goals);
  }

  void _showClearConfirmation(
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
