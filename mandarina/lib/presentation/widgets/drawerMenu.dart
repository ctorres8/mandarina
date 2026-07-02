import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/domain/user_profile_model.dart';
import 'package:mandarina/presentation/screens/about_screen.dart';
import 'package:mandarina/presentation/screens/home_screen.dart';
import 'package:mandarina/presentation/screens/workflow_screen.dart';
import 'package:mandarina/presentation/screens/pet_screen.dart';
import 'package:mandarina/presentation/screens/profile_screen.dart';
import 'package:mandarina/presentation/screens/settings_screen.dart';
import 'package:mandarina/presentation/viewmodel/auth_providers.dart';
import 'package:mandarina/presentation/viewmodel/providers.dart';

class DrawerMenu extends ConsumerWidget {
  final String currentScreen;
  const DrawerMenu({super.key, this.currentScreen = 'Inicio'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchar el perfil actual para sincronizar el nombre y la foto en el Drawer
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    final displayName =
        profile?.name ??
        user?.displayName ??
        user?.email?.split('@').first ??
        'Username';

    return Drawer(
      backgroundColor: MandarinaAppTheme.whiteColor,
      width: 230,
      child: Column(
        children: [
          _buildHeader(profile, displayName),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  Icons.home_rounded,
                  'Inicio',
                  currentScreen == 'Inicio',
                  onTap: () {
                    context.pop();
                    if (currentScreen != 'Inicio') {
                      context.goNamed(HomeScreen.name);
                    }
                  },
                ),
                _buildMenuItem(
                  Icons.person,
                  'Mi Perfil',
                  currentScreen == 'Mi Perfil',
                  onTap: () {
                    context.pop();
                    if (currentScreen != 'Mi Perfil') {
                      context.goNamed(ProfileScreen.name);
                    }
                  },
                ),
                _buildMenuItem(
                  Icons.bar_chart_rounded,
                  'Historial',
                  currentScreen == 'Historial',
                  onTap: () {
                    context.pop();
                  },
                ),
                _buildMenuItem(
                  Icons.auto_graph,
                  'Workflow',
                  currentScreen == 'Workflow',
                  onTap: () {
                    context.pop();
                    if (currentScreen != 'Workflow') {
                      context.goNamed(FreelancerScreen.name);
                    }
                  },
                ),
                _buildMenuItem(
                  Icons.pets,
                  'Mandarina PET',
                  currentScreen == 'Mandarina PET',
                  onTap: () {
                    context.pop();
                    if (currentScreen != 'Mandarina PET') {
                      context.goNamed(PetScreen.name);
                    }
                  },
                ),
                _buildMenuItem(
                  Icons.info,
                  'Sobre Mandarina',
                  currentScreen == 'Sobre Mandarina',
                  onTap: () {
                    context.pop();
                    if (currentScreen != 'Sobre Mandarina') {
                      context.goNamed(AboutScreen.name);
                    }
                  },
                ),
                Divider(
                  color: MandarinaAppTheme.accentColor.withValues(alpha: 0.2),
                  height: 60,
                  indent: 20,
                  endIndent: 20,
                ),
                _buildMenuItem(
                  Icons.settings_outlined,
                  'Ajustes',
                  currentScreen == 'Ajustes',
                  onTap: () {
                    context.pop();
                    if (currentScreen != 'Ajustes') {
                      context.goNamed(SettingsScreen.name);
                    }
                  },
                ),
                _buildMenuItem(
                  Icons.exit_to_app,
                  'Cerrar sesión',
                  false,
                  onTap: () {
                    final authNotifier = ref.read(
                      authControllerProvider.notifier,
                    );
                    context.pop(); // Cierra el drawer primero
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          backgroundColor: MandarinaAppTheme.whiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          title: Text(
                            'Cerrar sesión',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.quicksand(
                              color: MandarinaAppTheme.primaryColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            '¿Estás seguro de que deseas salir?',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.quicksand(
                              color: MandarinaAppTheme.darkBlueColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          actionsAlignment: MainAxisAlignment.spaceEvenly,
                          actionsPadding: const EdgeInsets.only(
                            bottom: 24,
                            left: 16,
                            right: 16,
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: MandarinaAppTheme.blueColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: MandarinaAppTheme.blueColor
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                              onPressed: () => Navigator.pop(dialogContext),
                              child: Text(
                                'Cancelar',
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MandarinaAppTheme.primaryColor,
                                foregroundColor: MandarinaAppTheme.whiteColor,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                Navigator.pop(
                                  dialogContext,
                                ); // Cierra el dialog
                                await authNotifier.signOut();
                              },
                              child: Text(
                                'Salir',
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserProfileModel? profile, String fallbackName) {
    final String profileImageUrl = profile?.profileImageUrl ?? '';
    final bool hasImage = profileImageUrl.isNotEmpty;
    final bool isNetwork =
        hasImage &&
        (profileImageUrl.startsWith('http') ||
            profileImageUrl.startsWith('https'));

    ImageProvider? imageProvider;
    if (hasImage) {
      imageProvider = isNetwork
          ? CachedNetworkImageProvider(profileImageUrl) as ImageProvider
          : FileImage(File(profileImageUrl)) as ImageProvider;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 40, left: 16, bottom: 16),
      decoration: const BoxDecoration(color: MandarinaAppTheme.primaryColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: MandarinaAppTheme.blueColor,
            radius: 25,
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? const Icon(
                    Icons.person,
                    size: 25,
                    color: MandarinaAppTheme.whiteColor,
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            fallbackName,
            style: GoogleFonts.quicksand(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    bool isSelected, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        tileColor: isSelected
            ? MandarinaAppTheme.secondaryColor.withValues(alpha: 0.3)
            : Colors.transparent,
        leading: Icon(icon, color: MandarinaAppTheme.primaryColor),
        title: Text(
          title,
          style: GoogleFonts.quicksand(
            color: MandarinaAppTheme.blueColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
