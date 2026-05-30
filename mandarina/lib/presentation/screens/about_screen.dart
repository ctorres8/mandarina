import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mandarina/core/theme/app_theme.dart';

/*
/// ============================================================================
/// MANDARINA COLOR SYSTEM & THEME DEFINITIONS
/// ============================================================================
/// NOTA: Si en tu proyecto real ya tienes una clase para el branding de colores,
/// puedes eliminar esta definición local y reemplazarla con tu importación correspondiente.
class MandarinaAppTheme {
  // Degradado lineal primario para pantallas naranjas
  static const Color primaryColor = Color(0xFFF28F3B); // Naranja Mandarina cálido (Arriba)
  static const Color accentColor = Color(0xFFC85A17);  // Terracota profundo y vibrante (Abajo)
  
  // Colores de utilidad para branding y texto
  static const Color whiteColor = Colors.white;
  static const Color glassBorderColor = Color(0x33FFFFFF); // Blanco con 20% de opacidad para bordes de tarjetas
  static const Color glassBgStart = Color(0x1EFFFFFF);    // Blanco con 12% de opacidad para efecto vidrio
  static const Color glassBgEnd = Color(0x0AFFFFFF);      // Blanco con 4% de opacidad para profundidad
}

/// ============================================================================
/// MANDARINA TYPOGRAPHY & TEXT STYLES HELPERS
/// ============================================================================
/// NOTA: Esta función garantiza que la tipografía global 'Quicksand' esté aplicada
/// de manera consistente, tal como se especifica en los lineamientos de diseño.
/// En tu aplicación real, puedes importar tu 'mandarinaTextStyle' global.
TextStyle mandarinaTextStyle({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
}) {
  return TextStyle(
    fontFamily: 'Quicksand',
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color ?? MandarinaAppTheme.whiteColor,
    letterSpacing: letterSpacing,
    height: height,
  );
}
*/
/// ============================================================================
/// DEMO WRAPPER FOR PREVIEWING (Interactive Test Harness)
/// ============================================================================
/// Puedes usar este widget interactivo para probar la pantalla de forma autónoma.
/// Está optimizado para inicializar el sistema de vistas y layouts.
class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);
  static const String name = "about_screen";

  @override
  Widget build(BuildContext context) {
    return AboutScreenView(); 
    /*MaterialApp(
      title: 'Mandarina Ecosistema - Acerca de',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Quicksand',
      ),
      home: const AboutScreen(),
    );*/
  }
}

/// ============================================================================
/// ABOUT SCREEN (Core Stateless Widget)
/// ============================================================================
class AboutScreenView extends StatelessWidget {
  const AboutScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Configuración premium de la barra de estado y de navegación del sistema
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: MandarinaAppTheme.accentColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.chevron_left_rounded, color: MandarinaAppTheme.whiteColor,),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                MandarinaAppTheme.primaryColor,
                MandarinaAppTheme.primaryOrangeColor,
              ],
            ),
          ),
          child: Stack(
            children: [
              // ---------------------------------------------------------------
              // IMAGEN DE FONDO (Logo de Mandarina como marca de agua sutil)
              // ---------------------------------------------------------------
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: 0.08, // Opacidad muy leve para no competir con el texto
                    child: Image.asset(
                      'assets/images/logo_blanco.png',
                      scale: 24, // Escala exacta solicitada por lineamiento
                      errorBuilder: (context, error, stackTrace) {
                        // En caso de que la imagen física no esté montada en el simulador,
                        // mostramos un fallback vectorial premium para evitar pantallas rotas.
                        return _buildVectorLogoFallback();
                      },
                    ),
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              // CUERPO PRINCIPAL (Layout responsivo y escaneable)
              // ---------------------------------------------------------------
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600), // Ancho máximo para mantener legibilidad en tablets/iPad
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          // --- CABECERA Y BOTÓN DE RETORNO ---
                          _buildHeaderSection(context),

                          const SizedBox(height: 32),

                          // --- BLOQUE 1: NUESTRA INSPIRACIÓN ---
                          _buildGlassCard(
                            stepNumber: '01',
                            title: 'Nuestra Inspiración',
                            icon: Icons.spa_rounded, // Icono Zen/Hoja representando crecimiento orgánico
                            text: 'Mandarina nace de una necesidad personal: encontrar un equilibrio real en un mundo lleno de distracciones digitales. Diseñar este ecosistema fue la respuesta al desafío de crear un espacio de trabajo donde la tecnología no compita por nuestra atención, sino que la acompañe de forma orgánica.',
                          ),

                          const SizedBox(height: 20),

                          // --- BLOQUE 2: EL ECOSISTEMA ---
                          _buildGlassCard(
                            stepNumber: '02',
                            title: 'El Ecosistema',
                            icon: Icons.devices_other_rounded, // Icono de fusión software/hardware
                            text: 'El proyecto une el desarrollo de software y hardware a través de una aplicación móvil y un asistente físico de escritorio (PET). Juntos, actúan en sintonía para transformar las rutinas de trabajo en experiencias de productividad consciente, utilizando estímulos sutiles y dinámicas de enfoque diseñadas a nuestra medida.',
                          ),

                          const SizedBox(height: 20),

                          // --- BLOQUE 3: EL FUTURO ---
                          _buildGlassCard(
                            stepNumber: '03',
                            title: 'El Futuro',
                            icon: Icons.explore_rounded, // Icono de brújula/dirección futura
                            text: 'El objetivo de Mandarina es devolvernos el control sobre nuestro tiempo. Aspira a convertirse en una herramienta que no solo mide el rendimiento, sino que optimice activamente nuestro entorno físico y mental, demostrando que el hardware inteligente puede integrarse de manera empática en nuestra vida cotidiana.',
                          ),

                          const SizedBox(height: 40),

                          // --- FOOTER PREMIUM ---
                          _buildFooterSection(),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECCIÓN: CABECERA (Header)
  // ---------------------------------------------------------------------------
  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Botón de Volverminimalista e interactivo con Haptic Feedback
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.maybeOf(context)?.pop();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MandarinaAppTheme.backgroundSettingsColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: MandarinaAppTheme.blueColor,
                width: 1.2,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: MandarinaAppTheme.whiteColor,
              size: 16,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Etiqueta superior sutil
        Text(
          'CONOCE NUESTRO ORIGEN',
          style: mandarinaTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: MandarinaAppTheme.whiteColor.withOpacity(0.7),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Título de la pantalla destacado y semibold
        Text(
          'Acerca de Mandarina',
          style: mandarinaTextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Separador fino e interactivo
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: MandarinaAppTheme.whiteColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // COMPONENTE: TARJETA TRANSLÚCIDA GLASSMORPHIC (Card UI)
  // ---------------------------------------------------------------------------
  Widget _buildGlassCard({
    required String stepNumber,
    required String title,
    required IconData icon,
    required String text,
  }) {
    return Container(
      decoration: BoxDecoration(
        // Efecto degradado interno tipo cristal esmerilado (Glassmorphism)
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MandarinaAppTheme.whiteColor.withValues(alpha: 0.2),
            MandarinaAppTheme.whiteColor.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: MandarinaAppTheme.whiteColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila de Cabecera de la Tarjeta (Icono + Título + Número de sección)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Círculo contenedor para el Icono sutil
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: MandarinaAppTheme.whiteColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: MandarinaAppTheme.whiteColor.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: MandarinaAppTheme.whiteColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Título llamativo y destacado (semibold)
                    Text(
                      title,
                      style: mandarinaTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                // Indicador de Paso Sutil
                Text(
                  stepNumber,
                  style: mandarinaTextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: MandarinaAppTheme.whiteColor.withOpacity(0.25),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 18),
            
            // Cuerpo de Texto con excelente separación de líneas (height) para lectura consciente
            Text(
              text,
              style: mandarinaTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: MandarinaAppTheme.whiteColor.withOpacity(0.95),
                height: 1.6, // Altura óptima para fácil lectura consciente y escaneo
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECCIÓN: FOOTER (Pie de pantalla)
  // ---------------------------------------------------------------------------
  Widget _buildFooterSection() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.favorite_rounded,
            color: MandarinaAppTheme.whiteColor.withOpacity(0.4),
            size: 16,
          ),
          const SizedBox(height: 8),
          Text(
            'Mandarina Ecosistema',
            style: mandarinaTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: MandarinaAppTheme.whiteColor.withOpacity(0.6),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Desarrollo Empático y Productividad Consciente © 2026',
            style: mandarinaTextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: MandarinaAppTheme.whiteColor.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FALLBACK VECTORIAL: Logo alternativo en caso de ausencia de Asset Físico
  // ---------------------------------------------------------------------------
  /// Este widget dibuja un hermoso vector minimalista que emula el logo de la 
  /// mandarina. Garantiza que la pantalla nunca se rompa si no encuentra el recurso local.
  Widget _buildVectorLogoFallback() {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: MandarinaAppTheme.whiteColor.withOpacity(0.04),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base naranja concéntrica interna
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: MandarinaAppTheme.whiteColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
          ),
          // Sutil hoja superior
          Positioned(
            top: 48,
            right: 80,
            child: Transform.rotate(
              angle: 0.6,
              child: Container(
                width: 32,
                height: 18,
                decoration: BoxDecoration(
                  color: MandarinaAppTheme.whiteColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
