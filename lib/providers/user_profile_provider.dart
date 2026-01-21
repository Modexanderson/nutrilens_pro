// lib/providers/user_profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile_model.dart';
import '../services/storage_service.dart';

// User Profile State
class UserProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  const UserProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  UserProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// User Profile Notifier
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  UserProfileNotifier() : super(const UserProfileState()) {
    _loadProfile();
  }

  void _loadProfile() {
    state = state.copyWith(isLoading: true);
    try {
      final profile = StorageService.getUserProfile();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> createProfile({
    String name = '',
    List<String>? allergensToAvoid,
    List<String>? dietaryRestrictions,
    NutritionGoals? nutritionGoals,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = UserProfile(
        id: const Uuid().v4(),
        name: name,
        allergensToAvoid: allergensToAvoid,
        dietaryRestrictions: dietaryRestrictions,
        nutritionGoals: nutritionGoals,
        onboardingCompleted: true,
      );
      await StorageService.saveUserProfile(profile);
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    state = state.copyWith(isLoading: true);
    try {
      await StorageService.updateUserProfile(profile);
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateName(String name) async {
    if (state.profile != null) {
      final updatedProfile = state.profile!.copyWith(name: name);
      await updateProfile(updatedProfile);
    }
  }

  Future<void> addAllergen(String allergen) async {
    if (state.profile != null) {
      final allergens = List<String>.from(state.profile!.allergensToAvoid);
      if (!allergens.contains(allergen)) {
        allergens.add(allergen);
        final updatedProfile =
            state.profile!.copyWith(allergensToAvoid: allergens);
        await updateProfile(updatedProfile);
      }
    }
  }

  Future<void> removeAllergen(String allergen) async {
    if (state.profile != null) {
      final allergens = List<String>.from(state.profile!.allergensToAvoid);
      allergens.remove(allergen);
      final updatedProfile =
          state.profile!.copyWith(allergensToAvoid: allergens);
      await updateProfile(updatedProfile);
    }
  }

  Future<void> setAllergens(List<String> allergens) async {
    if (state.profile != null) {
      final updatedProfile =
          state.profile!.copyWith(allergensToAvoid: allergens);
      await updateProfile(updatedProfile);
    }
  }

  Future<void> addDietaryRestriction(String restriction) async {
    if (state.profile != null) {
      final restrictions =
          List<String>.from(state.profile!.dietaryRestrictions);
      if (!restrictions.contains(restriction)) {
        restrictions.add(restriction);
        final updatedProfile =
            state.profile!.copyWith(dietaryRestrictions: restrictions);
        await updateProfile(updatedProfile);
      }
    }
  }

  Future<void> removeDietaryRestriction(String restriction) async {
    if (state.profile != null) {
      final restrictions =
          List<String>.from(state.profile!.dietaryRestrictions);
      restrictions.remove(restriction);
      final updatedProfile =
          state.profile!.copyWith(dietaryRestrictions: restrictions);
      await updateProfile(updatedProfile);
    }
  }

  Future<void> setNutritionGoals(NutritionGoals goals) async {
    if (state.profile != null) {
      final updatedProfile = state.profile!.copyWith(nutritionGoals: goals);
      await updateProfile(updatedProfile);
    }
  }

  Future<void> completeOnboarding() async {
    if (state.profile != null) {
      final updatedProfile = state.profile!.copyWith(onboardingCompleted: true);
      await updateProfile(updatedProfile);
    }
  }

  bool hasAllergen(String allergen) {
    return state.profile?.allergensToAvoid.contains(allergen) ?? false;
  }

  List<String> checkProductAllergens(List<String>? productAllergens) {
    if (productAllergens == null || state.profile == null) return [];

    final userAllergens = state.profile!.allergensToAvoid
        .map((a) => a.toLowerCase())
        .toSet();

    return productAllergens
        .where((allergen) => userAllergens.any(
            (userAllergen) => allergen.toLowerCase().contains(userAllergen)))
        .toList();
  }
}

// Providers
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>(
  (ref) => UserProfileNotifier(),
);

// Convenience provider to check if onboarding is completed
final isOnboardingCompletedProvider = Provider<bool>((ref) {
  final profileState = ref.watch(userProfileProvider);
  return profileState.profile?.onboardingCompleted ?? false;
});

// Convenience provider to get nutrition goals
final nutritionGoalsProvider = Provider<NutritionGoals>((ref) {
  final profileState = ref.watch(userProfileProvider);
  return profileState.profile?.nutritionGoals ?? NutritionGoals();
});

// Convenience provider to get user allergens
final userAllergensProvider = Provider<List<String>>((ref) {
  final profileState = ref.watch(userProfileProvider);
  return profileState.profile?.allergensToAvoid ?? [];
});
