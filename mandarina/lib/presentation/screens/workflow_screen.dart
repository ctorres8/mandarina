import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/presentation/viewmodel/providers.dart';
import 'package:mandarina/presentation/widgets/drawerMenu.dart';
import 'package:mandarina/presentation/viewmodel/state/workflow_state.dart';
import 'package:mandarina/presentation/viewmodel/notifiers/phrases_notifier.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:mandarina/core/services/export_service.dart';

/// Pantalla Modo Freelancer para la aplicación Mandarina.
/// Refactorizada para usar Riverpod (MVVM) y gestión de estados limpia.
///
/// Características:
/// - Fondo plano naranja (#E07A5F) / Degradé azul.
/// - Tipografía Quicksand para todo el diseño.
/// - Cronómetro libre incremental visualizado mediante `sleek_circular_slider`.
/// - Lógica de checkpoints y cálculo de duraciones reales e individuales por tarea.
/// - Edición interactiva de tareas en el diálogo de finalización.
/// - Reinicio automático al guardar.
class FreelancerScreen extends ConsumerStatefulWidget {
  const FreelancerScreen({super.key});
  static const String name = 'freelancer_screen';

  @override
  ConsumerState<FreelancerScreen> createState() => _FreelancerScreenState();
}

class _FreelancerScreenState extends ConsumerState<FreelancerScreen> {
  // Formatear duración en formato "MM:SS"
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = duration.inMinutes.toString();
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$twoDigitSeconds";
  }

  // Añadir un nuevo Checkpoint (toque corto)
  void _addCheckpoint() {
    final newTask = ref.read(workflowProvider.notifier).addCheckpoint();
    if (newTask == null) return;

    // Pequeño feedback visual de tipo Snackbar flotante y elegante
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const FaIcon(
              FontAwesomeIcons.solidCircleCheck,
              color: MandarinaAppTheme.primaryOrangeColor,
            ),
            const SizedBox(width: 12),
            Text(
              'Tarea #${ref.read(workflowProvider).tasks.length} registrada: ${_formatDuration(Duration(seconds: newTask.durationInSeconds))}',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w800,
                color: MandarinaAppTheme.blueBisColor,
              ),
            ),
          ],
        ),
        backgroundColor: MandarinaAppTheme.whiteColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 198, left: 24, right: 24),
      ),
    );
  }

  // Iniciar la detección de la pulsación larga con barra de progreso
  void _onButtonTapDown(TapDownDetails details) {
    final workflowState = ref.read(workflowProvider);
    if (!workflowState.isRunning)
      return; // Solo se detiene si está en ejecución

    ref.read(workflowProvider.notifier).startHold(() {
      _handleSessionStop();
    });
  }

  // Cancelar la pulsación larga si se levanta el dedo antes
  void _onButtonTapUp(TapUpDetails details) {
    final workflowState = ref.read(workflowProvider);

    if (workflowState.longPressTriggered) {
      ref.read(workflowProvider.notifier).clearLongPressTriggered();
      return;
    }

    ref.read(workflowProvider.notifier).cancelHold();

    if (!workflowState.isRunning) {
      ref.read(workflowProvider.notifier).startTimer();
    } else {
      _addCheckpoint();
    }
  }

  // Cancelar en caso de arrastre fuera del botón o interrupción
  void _onButtonTapCancel() {
    ref.read(workflowProvider.notifier).cancelHold();
  }

  // Detener la sesión y mostrar el cuadro de diálogo
  void _handleSessionStop() {
    _showSummaryDialog();
  }

  // Mostrar el AlertDialog estilizado
  void _showSummaryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool isExporting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return Consumer(
              builder: (context, ref, child) {
                final workflowState = ref.watch(workflowProvider);
                final totalDuration = Duration(
                  seconds: workflowState.tasks.fold<int>(
                    0,
                    (sum, t) => sum + t.durationInSeconds,
                  ),
                );

                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(viewInsets: EdgeInsets.zero),
                  child: AlertDialog(
                    backgroundColor: MandarinaAppTheme.whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    title: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: MandarinaAppTheme.primaryOrangeColor
                                .withValues(alpha: 0.1),
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
                          if (workflowState.tasks.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: MandarinaAppTheme.primaryColor
                                    .withValues(alpha: 0.1),
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
                                constraints: const BoxConstraints(
                                  maxHeight: 200,
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: workflowState.tasks.length,
                                  itemBuilder: (context, index) {
                                    final task = workflowState.tasks[index];
                                    return _EditableTaskRow(
                                      task: task,
                                      ref: ref,
                                    );
                                  },
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
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
                    actionsPadding: const EdgeInsets.only(
                      bottom: 24,
                      left: 24,
                      right: 24,
                    ),
                    actions: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: isExporting
                                ? null
                                : () async {
                                    setState(() {
                                      isExporting = true;
                                    });
                                    try {
                                      final ExportService exportService = ref
                                          .read(exportServiceProvider);
                                      await exportService.exportWorkflowToCSV(
                                        workflowState.tasks,
                                        totalTime: _formatDuration(
                                          totalDuration,
                                        ),
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const FaIcon(
                                                  FontAwesomeIcons
                                                      .solidCircleCheck,
                                                  color: MandarinaAppTheme
                                                      .whiteColor,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  '¡Jornada exportada con éxito!',
                                                  style: GoogleFonts.quicksand(
                                                    fontWeight: FontWeight.w800,
                                                    color: MandarinaAppTheme
                                                        .whiteColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: MandarinaAppTheme
                                                .primaryOrangeColor,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error al exportar: $e',
                                              style: GoogleFonts.quicksand(
                                                fontWeight: FontWeight.w600,
                                                color: MandarinaAppTheme
                                                    .whiteColor,
                                              ),
                                            ),
                                            backgroundColor: MandarinaAppTheme
                                                .primaryOrangeColor,
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (context.mounted) {
                                        setState(() {
                                          isExporting = false;
                                        });
                                      }
                                    }
                                  },
                            icon: isExporting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: MandarinaAppTheme.whiteColor,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const FaIcon(
                                    FontAwesomeIcons.fileCsv,
                                    size: 20,
                                  ),
                            label: Text(
                              isExporting
                                  ? 'Exportando...'
                                  : 'Exportar Jornada',
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MandarinaAppTheme.blueColor,
                              foregroundColor: MandarinaAppTheme.whiteColor,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: isExporting
                                ? null
                                : () {
                                    final minutes =
                                        (workflowState.elapsedDuration.inSeconds /
                                                60.0)
                                            .round();
                                    final tasksCount = workflowState.tasks.length;

                                    if (minutes > 0 || tasksCount > 0) {
                                      ref
                                          .read(profileProvider.notifier)
                                          .incrementMetrics(
                                            focusMinutes: minutes,
                                            completedTasks: tasksCount,
                                          );
                                    }

                                    Navigator.of(context).pop();
                                    ref.read(workflowProvider.notifier).reset();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  MandarinaAppTheme.primaryOrangeColor,
                              foregroundColor: MandarinaAppTheme.whiteColor,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Guardar y Cerrar',
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final workflowState = ref.watch(workflowProvider);
    final elapsed = workflowState.elapsedDuration;

    // 30 minutos = 30 * 60 = 1800 segundos.
    // Una vuelta completa del SleekCircularSlider representa 30 minutos.
    final double sliderValue =
        (elapsed.inMilliseconds % (30 * 60 * 1000)) / 1000.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [MandarinaAppTheme.blueBisColor, MandarinaAppTheme.blueColor],
          stops: [0.5, 0.9],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        drawer: const DrawerMenu(currentScreen: 'Workflow'),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const FaIcon(
                FontAwesomeIcons.bars,
                color: MandarinaAppTheme.whiteColor,
                size: 24,
              ),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Frase Motivacional flotante/sutil (puramente transparente)
                Consumer(
                  builder: (context, ref, child) {
                    final phrase = ref.watch(randomPhraseProvider);
                    if (phrase.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        top: 4.0,
                        bottom: 4.0,
                      ),
                      child: Text(
                        phrase,
                        textAlign: TextAlign.center,
                        style: mandarinaTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: MandarinaAppTheme.whiteColor.withValues(
                            alpha: 0.75,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(flex: 1),
                const SizedBox(height: 8),
                // Cronómetro Circular
                _cronometer(sliderValue),

                const Spacer(flex: 1),
                const SizedBox(height: 15),

                // Feed Visual de Checkpoints de Subtareas
                if (workflowState.tasks.isNotEmpty)
                  _checkpointsRow()
                else
                  SizedBox(
                    height: 70,
                    child: Center(
                      child: Text(
                        "Las tareas registradas aparecerán aquí",
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w600,
                          color: MandarinaAppTheme.whiteColor.withValues(
                            alpha: 0.4,
                          ),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                const Spacer(flex: 1),
                // Tiempo Transcurrido Grande "MM:SS"
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _formatDuration(elapsed),
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w600,
                      fontSize: 100,
                      color: MandarinaAppTheme.whiteColor,
                      shadows: const [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 1),
                // Botón Principal Checkpoint / Start con progreso animado de parada
                _playButton(workflowState),

                const SizedBox(height: 6),
                // Leyenda instructiva de acción
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: workflowState.isRunning ? 1.0 : 0.0,
                  child: Text(
                    "Mantén presionado 1s para finalizar sesión.",
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: MandarinaAppTheme.whiteColor.withValues(
                        alpha: 0.8,
                      ),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _playButton(WorkflowState workflowState) {
    return GestureDetector(
      onTapDown: _onButtonTapDown,
      onTapUp: _onButtonTapUp,
      onTapCancel: _onButtonTapCancel,
      child: Container(
        width: 100,
        height: 100,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: MandarinaAppTheme.whiteColor,
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
            if (workflowState.holdingProgress > 0.0)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 100 * workflowState.holdingProgress,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2CC8F).withValues(alpha: 0.7),
                  ),
                ),
              ),
            // Icono del botón
            Center(
              child: FaIcon(
                workflowState.holdingProgress > 0.0
                    ? FontAwesomeIcons.stopwatch
                    : (workflowState.isRunning
                          ? FontAwesomeIcons.solidFlag
                          : FontAwesomeIcons.play),
                color: MandarinaAppTheme.primaryColor,
                size: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkpointsRow() {
    final workflowState = ref.watch(workflowProvider);
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: workflowState.tasks.length,
        itemBuilder: (context, index) {
          final task = workflowState.tasks[index];
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
                const FaIcon(
                  FontAwesomeIcons.solidCircleCheck,
                  color: MandarinaAppTheme.whiteColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      task.name,
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: MandarinaAppTheme.whiteColor.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    Text(
                      _formatDuration(
                        Duration(seconds: task.durationInSeconds),
                      ),
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: MandarinaAppTheme.whiteColor.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cronometer(double sliderValue) {
    final workflowState = ref.watch(workflowProvider);
    return SizedBox(
      height: 280,
      width: 280,
      child: SleekCircularSlider(
        appearance: CircularSliderAppearance(
          animationEnabled: false,
          customColors: CustomSliderColors(
            trackColor: MandarinaAppTheme.whiteBisColor.withValues(alpha: 0.2),
            progressBarColor: MandarinaAppTheme.whiteColor,
            dotColor: MandarinaAppTheme.whiteColor,
            shadowColor: Colors.transparent,
          ),
          customWidths: CustomSliderWidths(
            trackWidth: 6,
            handlerSize: 16,
            progressBarWidth: 14,
            shadowWidth: 0,
          ),
          startAngle: 270,
          angleRange: 360,
        ),
        min: 0.0,
        max: 1800.0, // 30 minutos en segundos
        initialValue: sliderValue,
        innerWidget: (double value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    workflowState.isRunning
                        ? FontAwesomeIcons.hourglassEnd
                        : FontAwesomeIcons.hourglass,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  workflowState.isRunning ? "TRABAJANDO" : "MODO LIBRE",
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
    );
  }
}

/// Widget auxiliar para la edición inline de cada tarea en el diálogo de resumen.
/// Utiliza su propio TextEditingController para no perder foco ni posición de cursor.
class _EditableTaskRow extends StatefulWidget {
  final WorkflowTask task;
  final WidgetRef ref;

  const _EditableTaskRow({required this.task, required this.ref});

  @override
  State<_EditableTaskRow> createState() => _EditableTaskRowState();
}

class _EditableTaskRowState extends State<_EditableTaskRow> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.name);
  }

  @override
  void didUpdateWidget(covariant _EditableTaskRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.name != widget.task.name &&
        _controller.text != widget.task.name) {
      _controller.text = widget.task.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: MandarinaAppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF4F1DE)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (value) {
                widget.ref
                    .read(workflowProvider.notifier)
                    .updateTaskName(widget.task.id, value);
              },
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w700,
                color: MandarinaAppTheme.blueColor,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                fillColor: MandarinaAppTheme.whiteColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: MandarinaAppTheme.secondaryColor.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: MandarinaAppTheme.primaryColor,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatDuration(Duration(seconds: widget.task.durationInSeconds)),
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w800,
              color: MandarinaAppTheme.primaryOrangeColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = duration.inMinutes.toString();
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$twoDigitSeconds";
  }
}
