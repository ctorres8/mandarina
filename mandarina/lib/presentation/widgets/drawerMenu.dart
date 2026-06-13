import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/presentation/screens/about_screen.dart';
import 'package:mandarina/presentation/screens/workflow_screen.dart';
import 'package:mandarina/presentation/screens/pet_screen.dart';
import 'package:mandarina/presentation/screens/profile_screen.dart';
import 'package:mandarina/presentation/screens/settings_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: MandarinaAppTheme.whiteColor,
      width: 230,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  Icons.home_rounded,
                  'Inicio',
                  true,
                  onTap: () => context.pop(),
                ),
                _buildMenuItem(
                  Icons.person,
                  'Mi Perfil',
                  false,
                  onTap: () {
                    context.pop();
                    context.pushNamed(ProfileScreen.name);
                  },
                ),
                _buildMenuItem(Icons.bar_chart_rounded, 'Historial', false),
                _buildMenuItem(
                  Icons.auto_graph,
                  'Workflow',
                  false,
                  onTap: () {
                    context.pop();
                    context.pushNamed(FreelancerScreen.name);
                  },
                ),
                _buildMenuItem(
                  Icons.pets,
                  'Mandarina PET',
                  false,
                  onTap: () {
                    context.pop();
                    context.pushNamed(PetScreen.name);
                  },
                ),
                _buildMenuItem(
                  Icons.info,
                  'Sobre Mandarina',
                  false,
                  onTap: () {
                    context.pop();
                    context.pushNamed(AboutScreen.name);
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
                  false,
                  onTap: () {
                    context.pop();
                    context.pushNamed(SettingsScreen.name);
                  },
                ),
                _buildMenuItem(Icons.exit_to_app, 'Cerrar sesión', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity, // Esto asegura que ocupe todo el ancho del Drawer
      padding: const EdgeInsets.only(
        top: 40,
        left: 16,
        bottom: 16,
      ), // Ajustamos el espacio interno
      decoration: const BoxDecoration(color: MandarinaAppTheme.primaryColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: MandarinaAppTheme.blueColor,
            radius: 25, // Un poquito más grande se ve mejor
            child: Icon(
              Icons.person,
              size: 25,
              color: MandarinaAppTheme.whiteColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Username',
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
        // Efecto de selección
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
