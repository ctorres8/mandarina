import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarina/data/repositories/user_repository.dart';
import 'package:mandarina/domain/user_profile_model.dart';
import 'package:mandarina/presentation/viewmodel/auth_providers.dart';
import 'package:mandarina/presentation/viewmodel/state/profile_state.dart';

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;

    if (user != null) {
      _loadProfile(user.uid);
    } else {
      if (authState.isLoading) {
        return const ProfileState(isLoading: true);
      }
      // Fallback a test_user_mvp para desarrollo/modo sin autenticación
      _loadProfile('test_user_mvp');
    }

    return const ProfileState(isLoading: true);
  }

  Future<void> _loadProfile(String userId) async {
    try {
      final repository = ref.read(userRepositoryProvider);
      final profile = await repository.getProfile(userId);
      state = ProfileState(profile: profile, isLoading: false);
    } catch (e) {
      // Fallback a un perfil local si falla la red o el servicio no está disponible
      final currentUser = ref.read(firebaseAuthServiceProvider).currentUser;
      String initialName = 'Usuario Mandarina';
      if (currentUser != null && currentUser.uid == userId) {
        initialName = currentUser.displayName ??
            currentUser.email?.split('@').first ??
            'Usuario Mandarina';
      }

      final fallbackProfile = UserProfileModel(
        id: userId,
        coverImageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1964&auto=format&fit=crop',
        profileImageUrl: '',
        name: initialName,
        profession: 'Focused Member',
        socialLinks: const [],
        biography:
            '¡Bienvenido a Mandarina! Contanos un poco sobre vos, tus proyectos y tus pasiones editando este perfil.',
        gender: 'No especificado',
        completedTasks: 0,
        focusMinutes: 0,
        affinityLevel: 1,
        hasCompletedTutorial: false,
      );
      state = ProfileState(
        profile: fallbackProfile,
        isLoading: false,
        errorMessage: 'Sin conexión a Firestore: se cargaron datos locales.',
      );
    }
  }

  Future<void> updateProfile({
    required String name,
    required String profession,
    required String biography,
    required String gender,
    required String coverImageUrl,
    required String profileImageUrl,
    required List<String> socialLinks,
  }) async {
    final currentProfile = state.profile;
    if (currentProfile == null) return;

    final user = ref.read(firebaseAuthServiceProvider).currentUser;
    final userId = user?.uid ?? currentProfile.id;

    final updatedProfile = currentProfile.copyWith(
      id: userId,
      name: name,
      profession: profession,
      biography: biography,
      gender: gender,
      coverImageUrl: coverImageUrl,
      profileImageUrl: profileImageUrl,
      socialLinks: socialLinks,
    );

    // Actualización optimista del estado local
    state = state.copyWith(profile: updatedProfile);

    try {
      final repository = ref.read(userRepositoryProvider);
      await repository.saveProfile(userId, updatedProfile);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error al guardar los cambios en la nube: ${e.toString()}',
      );
    }
  }

  Future<void> updateTimerSound(String timerSound) async {
    final currentProfile = state.profile;
    if (currentProfile == null) return;

    final user = ref.read(firebaseAuthServiceProvider).currentUser;
    final userId = user?.uid ?? currentProfile.id;

    final updatedProfile = currentProfile.copyWith(timerSound: timerSound);
    state = state.copyWith(profile: updatedProfile);

    try {
      final repository = ref.read(userRepositoryProvider);
      await repository.updateTimerSound(userId, timerSound);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error al actualizar el sonido en Firestore: ${e.toString()}',
      );
    }
  }
}

