import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/presentation/widgets/drawerMenu.dart';

/// Pantalla informativa sobre la inspiración, el ecosistema y el futuro de Mandarina.
///
/// Presenta una experiencia inmersiva y minimalista mediante navegación horizontal,
/// con un fondo degradado de la marca, marca de agua estática y transiciones sutiles.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});
  static const String name = 'about_screen';

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Construye cada página individual de forma consistente y protegida contra desbordamientos.
  Widget _buildPage({required String title, required String body}) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60.0),
            Text(
              title,
              style: mandarinaTextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: MandarinaAppTheme.whiteColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20.0),
            // Divisor decorativo minimalista
            Container(
              width: 50.0,
              height: 3.5,
              decoration: BoxDecoration(
                color: MandarinaAppTheme.whiteColor.withOpacity(0.35),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            const SizedBox(height: 32.0),
            Text(
              body,
              style: mandarinaTextStyle(
                fontSize: 16.5,
                height: 1.7,
                color: MandarinaAppTheme.whiteColor.withOpacity(0.92),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Indicador de páginas interactivo con transiciones suaves en AnimatedContainer.
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final bool isActive = _currentPage == index;
        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            height: 8.0,
            width: isActive ? 24.0 : 8.0,
            decoration: BoxDecoration(
              color: MandarinaAppTheme.whiteColor.withOpacity(isActive ? 1.0 : 0.35),
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<List<Color>> pageGradients = [
      // Bloque 1: Inspiración (Tonos Mandarina / Naranja clásicos)
      [
        //MandarinaAppTheme.primaryOrangeColor,
        MandarinaAppTheme.primaryColor,
        MandarinaAppTheme.primaryColor,
      ],
      // Bloque 2: El Ecosistema (Un tono más profundo o ciruela/terracota intermedio)
      [
        //MandarinaAppTheme.fontBlueColor,
        //MandarinaAppTheme.fontBlueColor,
        MandarinaAppTheme.darkBlueColor,
        MandarinaAppTheme.darkBlueColor,
        //MandarinaAppTheme.darkBlueColor,
        //MandarinaAppTheme.accentColor,
        //const Color(0xFFD35400), // Ejemplo: Naranja quemado/oscuro continuo
      ],
      // Bloque 3: El Futuro (Un tono más inclinado hacia un naranja oscuro premium o rojizo sutil)
      [
        //const Color(0xFFD35400),
        MandarinaAppTheme.blueColor,
        MandarinaAppTheme.blueColor,
        //MandarinaAppTheme.accentColor,
        //MandarinaAppTheme.accentColor,
        //MandarinaAppTheme.accentColor,
      ],
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const DrawerMenu(currentScreen: 'Sobre Mandarina'),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu, color: MandarinaAppTheme.whiteColor,),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Degradado Lineal de Fondo
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: pageGradients[_currentPage],
                /*[
                  MandarinaAppTheme.primaryColor,
                  MandarinaAppTheme.accentColor,
                ],
                */
              ),
            ),
          ),
          
          // 2. Imagen de Fondo Estática de la Marca (Con Opacidad Sutil)
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.06,
                child: Image.asset(
                  'assets/images/logo_blanco.png',
                  scale: 1.5,
                  // Control de error para entornos de desarrollo sin el asset físico configurado
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.blur_on_rounded,
                      size: 140.0,
                      color: MandarinaAppTheme.whiteColor.withOpacity(0.12),
                    );
                  },
                ),
              ),
            ),
          ),

          // 3. Estructura Principal del Contenido
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int pageIndex) {
                    setState(() {
                      _currentPage = pageIndex;
                    });
                  },
                  children: [
                    _buildPage(
                      title: 'Nuestra Inspiración',
                      body: 'Mandarina nace de una necesidad personal: encontrar un equilibrio real en un mundo lleno de distracciones digitales. Diseñar este ecosistema fue la respuesta al desafío de crear un espacio de trabajo donde la tecnología no compita por nuestra atención, sino que la acompañe de forma orgánica.',
                    ),
                    _buildPage(
                      title: 'El Ecosistema',
                      body: 'El proyecto une el desarrollo de software y hardware a través de una aplicación móvil y un asistente físico de escritorio (PET). Juntos, actúan en sintonía para transformar las rutinas de trabajo en experiencias de productividad consciente, utilizando estímulos sutiles y dinámicas de enfoque diseñadas a nuestra medida.',
                    ),
                    _buildPage(
                      title: 'El Futuro',
                      body: 'El objetivo de Mandarina es devolvernos el control sobre nuestro tiempo. Aspira a convertirse en una herramienta que no solo mida el rendimiento, sino que optimice activamente nuestro entorno físico y mental, demostrando que el hardware inteligente puede integrarse de manera empática en nuestra vida cotidiana.',
                    ),
                  ],
                ),
              ),
              // Indicador inferior fijo fuera del PageView y envuelto en SafeArea
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.0, top: 16.0),
                  child: _buildPageIndicator(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
