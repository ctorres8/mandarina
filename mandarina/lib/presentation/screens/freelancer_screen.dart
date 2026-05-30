import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

/// Pantalla Modo Freelancer para la aplicación Mandarina.
/// Diseñada por un Desarrollador Senior de Flutter.
/// 
/// Características:
/// - Fondo plano naranja (#E07A5F).
/// - Tipografía Quicksand para todo el diseño.
/// - Contenedor neumórfico/estilizado para animación Lottie.
/// - Cronómetro libre incremental visualizado mediante `sleek_circular_slider`.
/// - Lógica de checkpoints mediante toques simples y parada/resumen.
/// - Botón interactivo con barra de carga visual para la pulsación larga de 2 segundos.
/// - Diálogo estilizado de resumen con lista de checkpoints y tiempos exactos.
class FreelancerScreen extends StatefulWidget {
  const FreelancerScreen({Key? key}) : super(key: key);
  static const String name = 'freelancer_screen';

  @override
  State<FreelancerScreen> createState() => _FreelancerScreenState();
}

class _FreelancerScreenState extends State<FreelancerScreen> with TickerProviderStateMixin {
  // Lógica del Cronómetro
  bool _isRunning = false;
  Duration _elapsedDuration = Duration.zero;
  DateTime? _startTime;
  Timer? _timer;
  
  // Lista de checkpoints guardados (tiempos transcurridos exactos)
  final List<Duration> _checkpoints = [];

  // Lógica de Pulsación Larga (2 segundos)
  Timer? _holdTimer;
  Timer? _holdingProgressTimer;
  double _holdingProgress = 0.0;
  bool _longPressTriggered = false;

  @override
  void dispose() {
    _timer?.cancel();
    _holdTimer?.cancel();
    _holdingProgressTimer?.cancel();
    super.dispose();
  }

  // Obtener la duración transcurrida exacta sin desfase
  Duration get _currentElapsed {
    if (!_isRunning || _startTime == null) {
      return _elapsedDuration;
    }
    return _elapsedDuration + DateTime.now().difference(_startTime!);
  }

  // Iniciar el temporizador
  void _startTimer() {
    setState(() {
      _startTime = DateTime.now();
      _isRunning = true;
      _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        setState(() {}); // Actualiza la UI para animar el slider y el texto de forma fluida
      });
    });
  }

  // Pausar/Detener el temporizador
  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    if (_startTime != null) {
      _elapsedDuration += DateTime.now().difference(_startTime!);
      _startTime = null;
    }
    _isRunning = false;
  }

  // Reiniciar por completo el temporizador y los checkpoints
  void _resetTimer() {
    _stopTimer();
    setState(() {
      _elapsedDuration = Duration.zero;
      _checkpoints.clear();
    });
  }

  // Añadir un nuevo Checkpoint (toque corto)
  void _addCheckpoint() {
    if (!_isRunning) return;
    
    final current = _currentElapsed;
    setState(() {
      _checkpoints.add(current);
    });

    // Pequeño feedback visual de tipo Snackbar flotante y elegante
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const FaIcon(FontAwesomeIcons.solidCircleCheck, color: MandarinaAppTheme.primaryOrangeColor),
            const SizedBox(width: 12),
            Text(
              'Tarea #${_checkpoints.length} registrada: ${_formatDuration(current)}',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w800,
                color: MandarinaAppTheme.blueBisColor,//Color(0xFF3D405B),
              ),
            ),
          ],
        ),
        backgroundColor: MandarinaAppTheme.whiteColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.only(bottom: 198, left: 24, right: 24),
      ),
    );
  }

  // Formatear duración en formato "HH:MM:SS"
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = duration.inMinutes.toString();
    //String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    //return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    return "$minutes:$twoDigitSeconds";
  }

  // Iniciar la detección de la pulsación larga de 2 segundos con barra de progreso
  void _onButtonTapDown(TapDownDetails details) {
    if (!_isRunning) return; // Solo se detiene si está en ejecución
    
    setState(() {
      _holdingProgress = 0.0;
      _longPressTriggered = false;
    });

    // Cronómetro de 2 segundos para la acción final
    _holdTimer = Timer(const Duration(seconds: 1), () {
      _longPressTriggered = true;
      _holdingProgressTimer?.cancel();
      _holdTimer?.cancel();
      _handleSessionStop();
    });

    // Actualizar el progreso visual del botón cada 30ms (2000ms total)
    const int tickIntervalMs = 30;
    _holdingProgressTimer = Timer.periodic(const Duration(milliseconds: tickIntervalMs), (timer) {
      setState(() {
        _holdingProgress += tickIntervalMs / 2000.0;
        if (_holdingProgress >= 1.0) {
          _holdingProgress = 1.0;
          timer.cancel();
        }
      });
    });
  }

  // Cancelar la pulsación larga si se levanta el dedo antes
  void _onButtonTapUp(TapUpDetails details) {
    _cancelHoldProgress();
    
    if (_longPressTriggered) return;

    if (!_isRunning) {
      _startTimer();
    } else {
      _addCheckpoint();
    }
  }

  // Cancelar en caso de arrastre fuera del botón o interrupción
  void _onButtonTapCancel() {
    _cancelHoldProgress();
  }

  void _cancelHoldProgress() {
    _holdTimer?.cancel();
    _holdingProgressTimer?.cancel();
    if (_holdingProgress > 0.0) {
      setState(() {
        _holdingProgress = 0.0;
      });
    }
  }

  // Detener la sesión y mostrar el cuadro de diálogo
  void _handleSessionStop() {
    final finalDuration = _currentElapsed;
    _stopTimer();
    _cancelHoldProgress();
    _showSummaryDialog(finalDuration);
  }

  // Mostrar el AlertDialog estilizado
  void _showSummaryDialog(Duration totalDuration) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: MandarinaAppTheme.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MandarinaAppTheme.primaryOrangeColor.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: const FaIcon(
                  FontAwesomeIcons.circleCheck,
                  color: MandarinaAppTheme.primaryOrangeColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sesión Finalizada',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: MandarinaAppTheme.blueColor,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tareas completadas durante esta sesión de trabajo:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: MandarinaAppTheme.blueColor,
                  ),
                ),
                const SizedBox(height: 20),
                if (_checkpoints.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: MandarinaAppTheme.primaryColor.withValues(alpha: 0.1),//color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      'No registraste subtareas individuales.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: MandarinaAppTheme.blueColor,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _checkpoints.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MandarinaAppTheme.primaryColor.withValues(alpha: 0.1),//const Color(0xFFF4F1DE).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFF4F1DE)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tarea ${index + 1}',
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.w700,
                                    color: MandarinaAppTheme.blueColor,//Color(0xFF3D405B),
                                  ),
                                ),
                                Text(
                                  _formatDuration(_checkpoints[index]),
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.w800,
                                    color: MandarinaAppTheme.primaryOrangeColor,//Color(0xFFE07A5F),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.transparent,//MandarinaAppTheme.blueColor,//const Color(0xFF3D405B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiempo Total',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: MandarinaAppTheme.primaryOrangeColor,
                        ),
                      ),
                      Text(
                        _formatDuration(totalDuration),
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: MandarinaAppTheme.primaryOrangeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetTimer();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MandarinaAppTheme.primaryOrangeColor,//const Color(0xFFE07A5F),
                foregroundColor: MandarinaAppTheme.whiteColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Cerrar y Guardar',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _currentElapsed;
    final double sliderValue = (elapsed.inMilliseconds % 60000) / 1000.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            //MandarinaAppTheme.primaryColor,
            //MandarinaAppTheme.secondaryColor,
            //MandarinaAppTheme.whiteBisColor
            //MandarinaAppTheme.blueColor,
            MandarinaAppTheme.blueBisColor,
            MandarinaAppTheme.blueColor,
            //MandarinaAppTheme.darkBlueColor,
          ],
          stops: const [0.5, 0.9],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,//const Color(0xFFE07A5F),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const FaIcon(
              FontAwesomeIcons.circleChevronLeft, 
              color: MandarinaAppTheme.whiteColor,
              size: 30,
            ),
          ),
          title: Text(
            'Workflow',
            style: GoogleFonts.quicksand(
              color: MandarinaAppTheme.whiteColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32, // Restando padding vertical
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header de la Pantalla
                      /*
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.maybeOf(context)?.pop(),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          ),
                          const Text(
                            'MODO FREELANCER',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: Colors.white,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(width: 48), // Spacer para centrar el título
                        ],
                      ),
                      */
      
                      const SizedBox(height: 20),
      
                      // Contenedor Circular Premium para la animación Lottie
                      /*
                      Container(
                        height: 180,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "Lottie Animation\nPlaceholder",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
      
                      const SizedBox(height: 30),
                      */
      
                      // Indicador Sleek Circular Slider
                      SizedBox(
                        height: 280,
                        width: 280,
                        child: SleekCircularSlider(
                          appearance: CircularSliderAppearance(
                            animationEnabled: false, // Evita desfase en tiempo real
                            customColors: CustomSliderColors(
                              trackColor: MandarinaAppTheme.whiteBisColor.withValues(alpha: 0.2),//Colors.white.withOpacity(0.2),
                              progressBarColor: MandarinaAppTheme.whiteColor,
                              dotColor: MandarinaAppTheme.whiteColor,
                              shadowColor: Colors.transparent,
                            ),
                            customWidths: CustomSliderWidths(
                              trackWidth: 6,
                              handlerSize: 16, // Ocultar el manejador para que actúe de visualizador limpio
                              progressBarWidth: 14,
                              shadowWidth: 0,
                            ),
                            
                            startAngle: 270, // Comienza en el punto más alto (12 en punto)
                            angleRange: 360, // Circunferencia completa
                            //size: 280,
                          ),
                          min: 0.0,
                          max: 60.0,
                          initialValue: sliderValue,
                          innerWidget: (double value) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: FaIcon(
                                      _isRunning ? FontAwesomeIcons.hourglassEnd : FontAwesomeIcons.hourglass, //Icons.hourglass_top_rounded : Icons.hourglass_empty_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _isRunning ? "TRABAJANDO" : "MODO LIBRE",
                                    style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white70,
                                      fontSize: 11,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
      
                      const SizedBox(height: 20),
      
                      // Tiempo Transcurrido Grande "MM:SS"
                      Text(
                        _formatDuration(elapsed),
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w600,
                          fontSize: 100,
                          color: MandarinaAppTheme.whiteColor,
                          //letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
      
                      const SizedBox(height: 30),
      
                      // Feed Visual de Checkpoints de Subtareas
                      if (_checkpoints.isNotEmpty)
                        Container(
                          height: 70,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _checkpoints.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: MandarinaAppTheme.whiteColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: MandarinaAppTheme.whiteColor.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.solidCircleCheck, 
                                      color: MandarinaAppTheme.whiteColor, 
                                      size: 18
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Tarea ${index + 1}',
                                          style: GoogleFonts.quicksand(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: MandarinaAppTheme.whiteColor.withValues(alpha: 0.8),
                                          ),
                                        ),
                                        Text(
                                          _formatDuration(_checkpoints[index]),
                                          style: GoogleFonts.quicksand(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            color: MandarinaAppTheme.whiteColor.withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      else
                        SizedBox(height: 90, child: Center(
                          child: Text(
                            "Los checkpoints registrados aparecerán aquí",
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.w600,
                              color: MandarinaAppTheme.whiteColor.withValues(alpha:0.7),
                              fontSize: 13,
                            ),
                          ),
                        )),
      
                      // Botón Principal Checkpoint / Start con progreso animado de parada
                      GestureDetector(
                        onTapDown: _onButtonTapDown,
                        onTapUp: _onButtonTapUp,
                        onTapCancel: _onButtonTapCancel,
                        child: Container(
                          width: 100,//280,
                          height: 100,//60,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: MandarinaAppTheme.whiteColor,
                            //borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Barra de progreso visual al mantener presionado (Long Press)
                              if (_holdingProgress > 0.0)
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 280 * _holdingProgress,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2CC8F).withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              // Texto y contenido del botón
                              Center(
                                child: FaIcon(
                                      _longPressTriggered
                                          ? FontAwesomeIcons.stopwatch
                                          : (_isRunning ? FontAwesomeIcons.solidFlag : FontAwesomeIcons.play),
                                      color: MandarinaAppTheme.primaryColor,
                                      size: 48,
                                    ),
                              ),
                              /*
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    _longPressTriggered
                                        ? FontAwesomeIcons.stopwatch
                                        : (_isRunning ? FontAwesomeIcons.flag : FontAwesomeIcons.play),
                                    color: MandarinaAppTheme.primaryColor,
                                    size: 50,
                                  ),
                                  
                                  const SizedBox(width: 8),
                                  Text(
                                    _holdingProgress > 0.1
                                        ? "SOLTAR PARA CHECKPOINT"
                                        : (_isRunning ? "CHECKPOINT" : "START"),
                                    style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: MandarinaAppTheme.primaryColor,
                                    ),
                                  ),
                                  
                                ],
                              ),
                              */
                            ],
                          ),
                        ),
                      ),
      
                      const SizedBox(height: 12),
      
                      // Leyenda instructiva de acción
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _isRunning ? 1.0 : 0.0,
                        child: Text(
                          "Mantén presionado 1s para finalizar sesión.",
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: MandarinaAppTheme.whiteColor.withValues(alpha: 0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
