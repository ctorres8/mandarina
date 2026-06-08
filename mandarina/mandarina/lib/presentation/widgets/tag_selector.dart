import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/domain/activities.dart';
import 'package:mandarina/presentation/viewmodel/providers.dart';

/// Modal Bottom Sheet personalizado y avanzado para la aplicación Mandarina.
/// Permite configurar dinámicamente tareas de enfoque estándar (Trabajo, Estudio, Descanso)
/// y rutinas deportivas HIIT personalizadas.
class TagSelectorBottomSheet extends ConsumerStatefulWidget {
  const TagSelectorBottomSheet({super.key});

  /// Método estático utilitario para mostrar este modal.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const TagSelectorBottomSheet(),
    );
  }

  @override
  ConsumerState<TagSelectorBottomSheet> createState() =>
      _TagSelectorBottomSheetState();
}

class _TagSelectorBottomSheetState
    extends ConsumerState<TagSelectorBottomSheet> {
  // Tarea/Tag seleccionado actualmente
  late Task _selectedTask;

  // Variables de configuración de tiempo y sesiones (Caso A - Estándar)
  late int _selectedTime; // En minutos
  late int _selectedSessions; // Cantidad de sesiones (1 a 5)

  // Variables de configuración para Deporte (Caso B - HIIT)
  late String _selectedSportRoutine; // Ej. "40s Actividad / 20s Descanso"
  late int _selectedSportSeries; // Rounds/Series (3 a 5)

  // Memoria temporal por sesión de Bottom Sheet para recordar preferencias al cambiar de tag
  final Map<int, int> _customTimes = {};
  final Map<int, int> _customSessions = {};

  @override
  void initState() {
    super.initState();
    final pomoState = ref.read(pomoProvider);
    _selectedTask = pomoState.currentTask;

    // Inicialización del tiempo en minutos a partir de los segundos en estado
    final currentMinutes = (pomoState.focusedTime / 60).round();
    final validTimes = [15, 20, 25, 30, 45, 60];
    _selectedTime = validTimes.contains(currentMinutes) ? currentMinutes : 25;

    _selectedSessions = pomoState.sessionsCount;

    // Configuraciones deportivas por defecto o cargadas desde el estado anterior
    _selectedSportRoutine =
        pomoState.sportRoutine ?? '40s Actividad / 20s Descanso';
    _selectedSportSeries = pomoState.sessionsCount.clamp(3, 5);

    // Cache inicial de configuraciones del tag actual
    _customTimes[_selectedTask.id] = _selectedTime;
    _customSessions[_selectedTask.id] = _selectedSessions;
  }

  /// Helper que asocia iconos minimalistas y elegantes para cada uno de los 4 Tags principales
  IconData _getTagIcon(String title) {
    switch (title) {
      case 'Estudio':
        return Icons.school_rounded;
      case 'Trabajo':
        return Icons.business_center_rounded;
      case 'Descanso':
        return Icons.coffee_rounded;
      case 'Deporte':
        return Icons.directions_run_rounded;
      default:
        return Icons.bookmark_rounded;
    }
  }

  /// Asigna un tiempo inicial sugerido si el usuario no lo ha personalizado previamente
  int _getDefaultTimeForTask(Task task) {
    if (task.title == 'Descanso') return 15; // Descanso corto por defecto
    if (task.title == 'Trabajo') return 50; // Foco extendido por defecto
    return 25; // Estudio / default
  }

  /// Asigna una cantidad de sesiones sugerida según el tipo de tag
  int _getDefaultSessionsForTask(Task task) {
    if (task.title == 'Descanso') return 1;
    if (task.title == 'Trabajo') return 2;
    return 4; // Foco Pomodoro estándar
  }

  /// Gestor reactivo del cambio de Tags que almacena las opciones en caché temporal
  void _onTaskSelected(Task task) {
    setState(() {
      // Guardar configuraciones del tag anterior
      if (_selectedTask.title != 'Deporte') {
        _customTimes[_selectedTask.id] = _selectedTime;
        _customSessions[_selectedTask.id] = _selectedSessions;
      } else {
        _selectedSportSeries = _selectedSessions;
      }

      _selectedTask = task;

      // Cargar configuraciones del nuevo tag seleccionado
      if (task.title == 'Deporte') {
        _selectedSessions = _selectedSportSeries;
      } else {
        _selectedTime = _customTimes[task.id] ?? _getDefaultTimeForTask(task);
        _selectedSessions =
            _customSessions[task.id] ?? _getDefaultSessionsForTask(task);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar los 4 tags requeridos por especificación (Trabajo, Estudio, Descanso, Deporte)
    final tasksToShow = [
      taskList.firstWhere(
        (t) => t.title == 'Estudio',
        orElse: () => taskList[1],
      ),
      taskList.firstWhere(
        (t) => t.title == 'Trabajo',
        orElse: () => taskList[0],
      ),
      taskList.firstWhere(
        (t) => t.title == 'Descanso',
        orElse: () => taskList[2],
      ),
      taskList.firstWhere(
        (t) => t.title == 'Deporte',
        orElse: () => taskList[3],
      ),
    ];

    final isSportMode = _selectedTask.title == 'Deporte';

    return Container(
      decoration: const BoxDecoration(
        color: MandarinaAppTheme.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle minimalista superior de arrastre
            Center(
              child: Container(
                width: 46,
                height: 4,
                margin: const EdgeInsets.only(top: 14, bottom: 18),
                decoration: BoxDecoration(
                  color: MandarinaAppTheme.darkBlueColor.withValues(
                    alpha: 0.15,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Encabezado con título Quicksand y Botón Cerrar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Text(
                    'Configurar Enfoque',
                    style: mandarinaTextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: MandarinaAppTheme.blueColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: MandarinaAppTheme.blueColor.withValues(alpha: 0.6),
                    style: IconButton.styleFrom(
                      backgroundColor: MandarinaAppTheme.blueColor.withValues(
                        alpha: 0.05,
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Fila Superior Fija: Selector de 4 Tags
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: tasksToShow.map((task) {
                  final bool isSelected = task.title == _selectedTask.title;
                  final icon = _getTagIcon(task.title);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () => _onTaskSelected(task),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MandarinaAppTheme.primaryColor.withValues(
                                    alpha: 0.12,
                                  )
                                : Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? MandarinaAppTheme.primaryColor
                                  : MandarinaAppTheme.blueColor.withValues(
                                      alpha: 0.08,
                                    ),
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                                color: isSelected
                                    ? MandarinaAppTheme.primaryColor
                                    : MandarinaAppTheme.blueColor.withValues(
                                        alpha: 0.4,
                                      ),
                                size: 26,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                task.title,
                                style: mandarinaTextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? MandarinaAppTheme.primaryColor
                                      : MandarinaAppTheme.blueColor.withValues(
                                          alpha: 0.7,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Divider(
              height: 1,
              color: MandarinaAppTheme.darkBlueColor.withValues(alpha: 0.08),
            ),

            // Cuerpo dinámico: Contenido adaptable según tag (Con scroll para seguridad de desborde)
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.08),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                  child: isSportMode
                      ? _buildDeporteLayout()
                      : _buildStandardLayout(),
                ),
              ),
            ),

            // Acción de Confirmación (Iniciar Enfoque)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    final pomoNotifier = ref.read(pomoProvider.notifier);

                    // Guardar y configurar variables en el Notifier
                    pomoNotifier.setTask(_selectedTask.title);

                    if (isSportMode) {
                      pomoNotifier.setSessionsCount(_selectedSportSeries);
                      pomoNotifier.setSportRoutine(_selectedSportRoutine);

                      // Asigna un tiempo calculado para Deporte según rutina HIIT y series
                      // Rutina 1: 40s Activo + 20s Descanso = 60s por round
                      // Rutina 2: 50s Activo + 15s Descanso = 65s por round
                      // Rutina 3: 30s Activo + 30s Descanso = 60s por round
                      double secondsPerRound = 60;
                      if (_selectedSportRoutine.contains('50s')) {
                        secondsPerRound = 65;
                      }
                      final totalHiitSeconds =
                          secondsPerRound * _selectedSportSeries;
                      pomoNotifier.setTime(totalHiitSeconds);
                    } else {
                      pomoNotifier.setSessionsCount(_selectedSessions);
                      pomoNotifier.setSportRoutine(null);
                      pomoNotifier.setTime(_selectedTime * 60.0);
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MandarinaAppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Confirmar',
                    style: mandarinaTextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Layout Estándar (Caso A: Estudio, Trabajo, Descanso)
  Widget _buildStandardLayout() {
    final times = [15, 20, 25, 30, 45, 60];

    return Column(
      key: const ValueKey('standard_layout'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Selector de Cronómetro (Tiempos)
        Row(
          children: [
            const Icon(
              Icons.timer_outlined,
              color: MandarinaAppTheme.accentColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Tiempo de Enfoque',
              style: mandarinaTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: MandarinaAppTheme.blueColor,
              ),
            ),
            const Spacer(),
            Text(
              '$_selectedTime min',
              style: mandarinaTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: MandarinaAppTheme.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Chips horizontales scrollables
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: times.length,
            itemBuilder: (context, index) {
              final time = times[index];
              final bool isTimeSelected = time == _selectedTime;

              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTime = time),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: isTimeSelected
                          ? const LinearGradient(
                              colors: [
                                MandarinaAppTheme.primaryColor,
                                MandarinaAppTheme.accentColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isTimeSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isTimeSelected
                            ? Colors.transparent
                            : MandarinaAppTheme.blueColor.withValues(
                                alpha: 0.08,
                              ),
                        width: 1.2,
                      ),
                      boxShadow: isTimeSelected
                          ? [
                              BoxShadow(
                                color: MandarinaAppTheme.primaryColor
                                    .withValues(alpha: 0.22),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      '$time min',
                      style: mandarinaTextStyle(
                        fontSize: 14,
                        fontWeight: isTimeSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isTimeSelected
                            ? Colors.white
                            : MandarinaAppTheme.blueColor.withValues(
                                alpha: 0.7,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 28),

        // Selector de Sesiones
        Row(
          children: [
            const Icon(
              Icons.cached_rounded,
              color: MandarinaAppTheme.accentColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Sesiones de Enfoque',
              style: mandarinaTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: MandarinaAppTheme.blueColor,
              ),
            ),
            const Spacer(),
            Text(
              '$_selectedSessions ${_selectedSessions == 1 ? "sesión" : "sesiones"}',
              style: mandarinaTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: MandarinaAppTheme.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Control de Sesiones con Botones e Indicadores de Círculos
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: MandarinaAppTheme.blueColor.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _selectedSessions > 1
                    ? () => setState(() => _selectedSessions--)
                    : null,
                icon: const Icon(Icons.remove_rounded, size: 22),
                color: MandarinaAppTheme.primaryColor,
                disabledColor: MandarinaAppTheme.blueColor.withValues(
                  alpha: 0.15,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: MandarinaAppTheme.whiteColor,
                  elevation: 0.5,
                  padding: const EdgeInsets.all(8),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final int circleNumber = index + 1;
                    final bool isFilled = circleNumber <= _selectedSessions;

                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedSessions = circleNumber),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled
                              ? MandarinaAppTheme.accentColor
                              : Colors.transparent,
                          border: Border.all(
                            color: isFilled
                                ? MandarinaAppTheme.accentColor
                                : MandarinaAppTheme.blueColor.withValues(
                                    alpha: 0.15,
                                  ),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              IconButton(
                onPressed: _selectedSessions < 5
                    ? () => setState(() => _selectedSessions++)
                    : null,
                icon: const Icon(Icons.add_rounded, size: 22),
                color: MandarinaAppTheme.primaryColor,
                disabledColor: MandarinaAppTheme.blueColor.withValues(
                  alpha: 0.15,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: MandarinaAppTheme.whiteColor,
                  elevation: 0.5,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Layout para Deporte (Caso B: Esquema HIIT / Cardio)
  Widget _buildDeporteLayout() {
    final routines = [
      {
        'title': '40s Actividad / 20s Descanso',
        'desc':
            'Foco de alta intensidad cardiovascular para activar tu energía.',
        'icon': Icons.flash_on_rounded,
      },
      {
        'title': '50s Actividad / 15s Descanso',
        'desc':
            'Intervalos de resistencia pura con pausas de recuperación corta.',
        'icon': Icons.fitness_center_rounded,
      },
      {
        'title': '30s Actividad / 30s Descanso',
        'desc': 'Cardio balanceado para adaptación e intervalos intermedios.',
        'icon': Icons.timer_rounded,
      },
    ];

    return Column(
      key: const ValueKey('deporte_layout'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              color: MandarinaAppTheme.accentColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Intervalo de Cardio/HIIT',
              style: mandarinaTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: MandarinaAppTheme.blueColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ListTiles visuales e interactivas de rutinas
        ...routines.map((r) {
          final bool isSelected = r['title'] == _selectedSportRoutine;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: GestureDetector(
              onTap: () =>
                  setState(() => _selectedSportRoutine = r['title'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? MandarinaAppTheme.primaryColor.withValues(alpha: 0.04)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? MandarinaAppTheme.primaryColor
                        : MandarinaAppTheme.darkBlueColor.withValues(
                            alpha: 0.08,
                          ),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: MandarinaAppTheme.primaryColor.withValues(
                              alpha: 0.03,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? MandarinaAppTheme.primaryColor.withValues(
                                alpha: 0.12,
                              )
                            : MandarinaAppTheme.blueColor.withValues(
                                alpha: 0.05,
                              ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        r['icon'] as IconData,
                        color: isSelected
                            ? MandarinaAppTheme.primaryColor
                            : MandarinaAppTheme.blueColor.withValues(
                                alpha: 0.6,
                              ),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r['title'] as String,
                            style: mandarinaTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? MandarinaAppTheme.primaryColor
                                  : MandarinaAppTheme.blueColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r['desc'] as String,
                            style: mandarinaTextStyle(
                              fontSize: 12,
                              color: MandarinaAppTheme.darkBlueColor.withValues(
                                alpha: 0.5,
                              ),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? MandarinaAppTheme.primaryColor
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? MandarinaAppTheme.primaryColor
                              : MandarinaAppTheme.blueColor.withValues(
                                  alpha: 0.15,
                                ),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),

        // Selector de Series de Deporte
        Row(
          children: [
            const Icon(
              Icons.loop_rounded,
              color: MandarinaAppTheme.accentColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Rounds/Series',
              style: mandarinaTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: MandarinaAppTheme.blueColor,
              ),
            ),
            const Spacer(),
            Text(
              '$_selectedSportSeries ${_selectedSportSeries == 1 ? "serie" : "series"}',
              style: mandarinaTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: MandarinaAppTheme.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Botones de series expandibles
        Row(
          children: [3, 4, 5].map((series) {
            final bool isSelected = series == _selectedSportSeries;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSportSeries = series),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? MandarinaAppTheme.accentColor.withValues(
                              alpha: 0.12,
                            )
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? MandarinaAppTheme.accentColor
                            : MandarinaAppTheme.blueColor.withValues(
                                alpha: 0.08,
                              ),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Text(
                      '$series Series',
                      style: mandarinaTextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? MandarinaAppTheme.accentColor
                            : MandarinaAppTheme.blueColor.withValues(
                                alpha: 0.7,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
