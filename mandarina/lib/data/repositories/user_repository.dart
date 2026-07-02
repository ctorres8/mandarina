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
        return UserProfileModel.fromMap(docSnapshot.data()!, docSnapshot.id);
      }
    } catch (e) {
      // Intentar cargar desde la caché local si el servicio no está disponible (ej. offline)
      try {
        final cachedDoc = await _firestore
            .collection('users')
            .doc(userId)
            .get(const GetOptions(source: Source.cache));
        if (cachedDoc.exists && cachedDoc.data() != null) {
          return UserProfileModel.fromMap(cachedDoc.data()!, cachedDoc.id);
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
    return UserProfileModel(
      id: userId,
      coverImageUrl: '',
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
    );
  }

  Stream<UserProfileModel> streamProfile(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((
      docSnapshot,
    ) {
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return UserProfileModel.fromMap(docSnapshot.data()!, docSnapshot.id);
      } else {
        final currentUser = FirebaseAuth.instance.currentUser;
        String initialName = 'Usuario Mandarina';
        if (currentUser != null && currentUser.uid == userId) {
          initialName = currentUser.displayName ??
              currentUser.email?.split('@').first ??
              'Usuario Mandarina';
        }

        return UserProfileModel(
          id: userId,
          coverImageUrl: '',
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
        );
      }
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
        coverImageUrl: '',
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
      );
    });
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});
