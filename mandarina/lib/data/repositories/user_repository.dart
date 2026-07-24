import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarina/domain/user_profile_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveProfile(String userId, UserProfileModel profile) async {
    await _firestore.collection('users').doc(userId).set(profile.toMap());
  }

  Future<UserProfileModel> getProfile(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final profile = UserProfileModel.fromMap(docSnapshot.data()!, docSnapshot.id);
        if (profile.name.trim().isNotEmpty) {
          return profile;
        }
      }
    } catch (e) {
      // Intentar cargar desde la caché local si el servicio no está disponible (ej. offline)
      try {
        final cachedDoc = await _firestore
            .collection('users')
            .doc(userId)
            .get(const GetOptions(source: Source.cache));
        if (cachedDoc.exists && cachedDoc.data() != null) {
          final profile = UserProfileModel.fromMap(cachedDoc.data()!, cachedDoc.id);
          if (profile.name.trim().isNotEmpty) {
            return profile;
          }
        }
      } catch (_) {
        // Ignorar fallos de la caché y proceder al fallback por defecto
      }
    }

    // Extraer datos del usuario logueado en Firebase Auth para el perfil inicial
    final currentUser = FirebaseAuth.instance.currentUser;
    String initialName = 'Usuario Mandarina';
    if (currentUser != null && currentUser.uid == userId) {
      initialName = currentUser.displayName ??
          currentUser.email?.split('@').first ??
          'Usuario Mandarina';
    }

    // Retornar el perfil inicial/defecto de prueba genérico
    final defaultProfile = UserProfileModel(
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

    // Guardar el perfil en Firestore de forma segura para precargar los datos
    try {
      await saveProfile(userId, defaultProfile);
    } catch (_) {
      // Ignorar errores en caso de no contar con acceso de escritura en ese instante (ej. offline)
    }

    return defaultProfile;
  }

  Future<void> createUserProfileAfterSignup(String userId, String email) async {
    final String initialName = email.isNotEmpty ? email.split('@').first : 'Usuario Mandarina';
    final defaultProfile = UserProfileModel(
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
      hasAcceptedTerms: true,
    );

    final Map<String, dynamic> data = defaultProfile.toMap();
    data['acceptedTermsAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }

  Future<void> markTermsAccepted(String userId) async {
    await _firestore.collection('users').doc(userId).set({
      'hasAcceptedTerms': true,
      'acceptedTermsAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<bool> checkUserHasAcceptedTerms(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists || doc.data() == null) {
        return false;
      }
      final data = doc.data()!;
      return (data['hasAcceptedTerms'] == true) || (data['acceptedTerms'] == true);
    } catch (_) {
      return false;
    }
  }

  Stream<UserProfileModel> streamProfile(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((
      docSnapshot,
    ) {
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final profile = UserProfileModel.fromMap(docSnapshot.data()!, docSnapshot.id);
        if (profile.name.trim().isNotEmpty) {
          return profile;
        }
      }
      
      final currentUser = FirebaseAuth.instance.currentUser;
      String initialName = 'Usuario Mandarina';
      if (currentUser != null && currentUser.uid == userId) {
        initialName = currentUser.displayName ??
            currentUser.email?.split('@').first ??
            'Usuario Mandarina';
      }

      return UserProfileModel(
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
    }).handleError((error) {
      // Retornar perfil genérico local en caso de desconexión u otros errores del stream
      final currentUser = FirebaseAuth.instance.currentUser;
      String initialName = 'Usuario Mandarina';
      if (currentUser != null && currentUser.uid == userId) {
        initialName = currentUser.displayName ??
            currentUser.email?.split('@').first ??
            'Usuario Mandarina';
      }

      return UserProfileModel(
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
    });
  }

  Future<void> updateTimerSound(String userId, String timerSound) async {
    await _firestore.collection('users').doc(userId).set({
      'timer_sound': timerSound,
    }, SetOptions(merge: true));
  }

  Future<void> updateTimerVolume(String userId, double timerVolume) async {
    await _firestore.collection('users').doc(userId).set({
      'timer_volume': timerVolume,
    }, SetOptions(merge: true));
  }

  Future<void> incrementUserMetrics(
    String userId, {
    int focusMinutes = 0,
    int completedTasks = 0,
  }) async {
    if (focusMinutes <= 0 && completedTasks <= 0) return;

    final Map<String, dynamic> updates = {};
    if (focusMinutes > 0) {
      updates['focusMinutes'] = FieldValue.increment(focusMinutes);
    }
    if (completedTasks > 0) {
      updates['completedTasks'] = FieldValue.increment(completedTasks);
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .set(updates, SetOptions(merge: true));
  }
}


final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

