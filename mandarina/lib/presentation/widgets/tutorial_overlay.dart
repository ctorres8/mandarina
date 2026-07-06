import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mandarina/core/theme/app_theme.dart';

class TutorialOverlay extends StatefulWidget {
  final int step;
  final GlobalKey sliderKey;
  final GlobalKey statsKey;
  final GlobalKey clockKey;
  final GlobalKey playKey;
  final VoidCallback onNext;
  final VoidCallback onComplete;

  const TutorialOverlay({
    super.key,
    required this.step,
    required this.sliderKey,
    required this.statsKey,
    required this.clockKey,
    required this.playKey,
    required this.onNext,
    required this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  Rect? _targetRect;
  bool _isCircle = false;
  Offset? _dotPosition;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Calcular la posición inicial después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTargetPosition();
    });
  }

  @override
  void didUpdateWidget(covariant TutorialOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalcular posiciones si el paso cambió
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTargetPosition();
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _updateTargetPosition() {
    if (!mounted) return;

    GlobalKey? activeKey;
    bool isCircle = false;

    switch (widget.step) {
      case 1:
        activeKey = widget.sliderKey;
        isCircle = true;
        break;
      case 2:
        activeKey = widget.statsKey;
        isCircle = false;
        break;
      case 3:
        activeKey = widget.clockKey;
        isCircle = false;
        break;
      case 4:
        activeKey = widget.playKey;
        isCircle = false;
        break;
      case 5:
        activeKey = null; // Pantalla completa sin recorte
        isCircle = false;
        break;
    }

    if (activeKey == null) {
      setState(() {
        _targetRect = null;
        _isCircle = false;
        _dotPosition = null;
      });
      return;
    }

    final context = activeKey.currentContext;
    if (context == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final rect = offset & renderBox.size;

    Offset dotPos;
    if (isCircle) {
      final radius = (rect.width + rect.height) / 4 + 8;
      // Posicionar el dot brillante en la circunferencia superior derecha
      dotPos = Offset(
        rect.center.dx + radius * 0.7,
        rect.center.dy - radius * 0.7,
      );
    } else {
      // Posicionar en lugares estratégicos para cada paso rectangular
      if (widget.step == 2) {
        // En el primer círculo de métricas
        dotPos = Offset(rect.left + 45, rect.center.dy);
      } else if (widget.step == 3) {
        // En la esquina superior derecha del reloj digital
        dotPos = Offset(rect.right - 15, rect.top + 15);
      } else if (widget.step == 4) {
        // En el centro del botón Play (que es la parte superior del widget de columna agrupado)
        dotPos = Offset(rect.center.dx, rect.top + 50);
      } else {
        dotPos = rect.center;
      }
    }

    setState(() {
      _targetRect = rect;
      _isCircle = isCircle;
      _dotPosition = dotPos;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si la máscara debe desvanecerse por completo en el paso 5
    final showMask = widget.step < 5;

    // Título y texto de las instrucciones
    String title = "";
    String description = "";
    String buttonText = "";
    VoidCallback onButtonPressed = widget.onNext;

    switch (widget.step) {
      case 1:
        title = "Ajusta tu Tiempo";
        description =
            "Desliza el dedo alrededor de la circunferencia para configurar los minutos de tu sesión antes de empezar.";
        buttonText = "Siguiente";
        break;
      case 2:
        title = "Elige tu Enfoque";
        description =
            "Toca cualquiera de estos círculos para cambiar de actividad (Estudio, Trabajo, Deporte) o ver tu progreso de sesiones completadas.";
        buttonText = "Siguiente";
        break;
      case 3:
        title = "Tu Tiempo de un Vistazo";
        description =
            "Aquí verás el segundero correr de forma masiva y clara para mantenerte enfocado en la meta.";
        buttonText = "Siguiente";
        break;
      case 4:
        title = "Inicia el Flujo";
        description =
            "Un toque simple inicia o pausa tu sesión. Si necesitas cancelar y reiniciar el contador por completo, mantén presionado el botón por 1 segundo.";
        buttonText = "Entendido";
        break;
      case 5:
        title = "¡Todo Listo para Fluir!";
        description =
            "Desliza desde el borde izquierdo para abrir el menú lateral cuando quieras. Que tengas una excelente jornada.";
        buttonText = "¡Comenzar ahora!";
        onButtonPressed = widget.onComplete;
        break;
    }

    // Determinar la posición de la tarjeta de instrucciones
    // Si no hay target (paso 5), se centra
    // Si el target está en la mitad inferior de la pantalla, la tarjeta va arriba
    // Si el target está en la mitad superior, la tarjeta va abajo
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    Widget cardPositioned;
    if (widget.step == 5) {
      cardPositioned = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _buildInstructionCard(
            title,
            description,
            buttonText,
            onButtonPressed,
            true,
          ),
        ),
      );
    } else if (_targetRect != null) {
      final targetCenterY = _targetRect!.center.dy;
      final isOnLowerHalf = targetCenterY > (screenHeight / 2);

      if (isOnLowerHalf) {
        cardPositioned = Positioned(
          top: mediaQuery.padding.top + 70,
          left: 24,
          right: 24,
          child: _buildInstructionCard(
            title,
            description,
            buttonText,
            onButtonPressed,
            false,
          ),
        );
      } else {
        cardPositioned = Positioned(
          bottom: mediaQuery.padding.bottom + 50,
          left: 24,
          right: 24,
          child: _buildInstructionCard(
            title,
            description,
            buttonText,
            onButtonPressed,
            false,
          ),
        );
      }
    } else {
      // Fallback por si _targetRect es nulo mientras carga
      cardPositioned = const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Máscara oscura semitransparente con recorte
        if (showMask)
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: HolePainter(
                  targetRect: _targetRect,
                  isCircle: _isCircle,
                  animationValue: _glowController.value,
                ),
              );
            },
          ),

        // Bloquear toques en el fondo del tutorial
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {}, // Evita toques accidentales en elementos del home
          ),
        ),

        // Puntero brillante con animación
        if (showMask && _dotPosition != null)
          PulsingDot(position: _dotPosition!),

        // Tarjeta de instrucciones
        cardPositioned,
      ],
    );
  }

  Widget _buildInstructionCard(
    String title,
    String description,
    String buttonText,
    VoidCallback onPressed,
    bool isStep5,
  ) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(22.0),
        decoration: BoxDecoration(
          color: MandarinaAppTheme.whiteColor, //.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: MandarinaAppTheme.accentColor.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicador de Paso (del 1 al 5)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "PASO ${widget.step} DE 5",
                  style: mandarinaTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: MandarinaAppTheme.primaryOrangeColor,
                    letterSpacing: 1.2,
                  ),
                ),
                // Puntos de progreso visuales
                Row(
                  children: List.generate(5, (index) {
                    final isActive = index + 1 == widget.step;
                    return Container(
                      margin: const EdgeInsets.only(left: 4.0),
                      width: isActive ? 12 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? MandarinaAppTheme.primaryOrangeColor
                            : MandarinaAppTheme.blueColor.withValues(
                                alpha: 0.3,
                              ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Título
            Text(
              title,
              style: mandarinaTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MandarinaAppTheme.primaryOrangeColor,
              ),
            ),
            const SizedBox(height: 8),
            // Descripción
            Text(
              description,
              style: mandarinaTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: MandarinaAppTheme.blueColor, //.withValues(alpha: 0.85),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            // Botón de acción principal
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MandarinaAppTheme.primaryOrangeColor,
                  foregroundColor: MandarinaAppTheme.whiteColor,
                  elevation: 2,
                  shadowColor: MandarinaAppTheme.primaryOrangeColor.withValues(
                    alpha: 0.5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 14.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                onPressed: onPressed,
                child: Text(
                  buttonText,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: MandarinaAppTheme.whiteColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HolePainter extends CustomPainter {
  final Rect? targetRect;
  final bool isCircle;
  final double animationValue;

  HolePainter({
    required this.targetRect,
    required this.isCircle,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Máscara oscura semitransparente (60% opacidad)
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.60);

    if (targetRect == null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        backgroundPaint,
      );
      return;
    }

    // Dibujar el fondo con el hueco usando PathOperation.difference
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path();

    if (isCircle) {
      final radius = (targetRect!.width + targetRect!.height) / 4 + 8;
      holePath.addOval(
        Rect.fromCircle(center: targetRect!.center, radius: radius),
      );
    } else {
      holePath.addRRect(
        RRect.fromRectAndRadius(
          targetRect!.inflate(8), // margen
          const Radius.circular(16),
        ),
      );
    }

    final path = Path.combine(
      PathOperation.difference,
      backgroundPath,
      holePath,
    );
    canvas.drawPath(path, backgroundPaint);

    // Dibujar borde brillante/glowing
    final borderPaint = Paint()
      ..color = MandarinaAppTheme.accentColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Pintar el borde exterior del recorte con efecto de halo
    if (isCircle) {
      final radius = (targetRect!.width + targetRect!.height) / 4 + 8;
      // Halo exterior
      final glowPaint = Paint()
        ..color = MandarinaAppTheme.accentColor.withValues(
          alpha: 0.3 * (1 - animationValue),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 + (8 * animationValue);
      canvas.drawCircle(targetRect!.center, radius, glowPaint);
      canvas.drawCircle(targetRect!.center, radius, borderPaint);
    } else {
      final rect = targetRect!.inflate(8);
      final glowPaint = Paint()
        ..color = MandarinaAppTheme.accentColor.withValues(
          alpha: 0.3 * (1 - animationValue),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 + (8 * animationValue);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(16)),
        glowPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(16)),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HolePainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.isCircle != isCircle ||
        oldDelegate.animationValue != animationValue;
  }
}

class PulsingDot extends StatefulWidget {
  final Offset position;
  const PulsingDot({super.key, required this.position});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              left: widget.position.dx - 18,
              top: widget.position.dy - 18,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MandarinaAppTheme.accentColor.withValues(
                    alpha: 0.4 * (1 - _controller.value),
                  ),
                ),
              ),
            ),
            Positioned(
              left: widget.position.dx - 8,
              top: widget.position.dy - 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: MandarinaAppTheme.accentColor,
                  boxShadow: [
                    BoxShadow(
                      color: MandarinaAppTheme.accentColor,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
