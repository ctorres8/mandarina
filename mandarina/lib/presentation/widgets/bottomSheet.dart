import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/domain/activities.dart';
import 'package:mandarina/presentation/viewmodel/providers.dart';
import 'package:mandarina/presentation/viewmodel/state/pomo_state.dart';
import 'package:numberpicker/numberpicker.dart';

class PomoSettingsSheet extends ConsumerWidget {
  const PomoSettingsSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final currentPomoState = ref.watch(pomoProvider);
  
    return Container(
      height: 900, // Ajusté el alto para que sea más orgánico
      decoration: BoxDecoration(
        color: MandarinaAppTheme.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Cabecera Mandarina
          Container(
            height: 50,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: MandarinaAppTheme.primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo_blanco.png', scale: 18),
                  const SizedBox(width: 5),
                  Text(
                    'Mandarina',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: MandarinaAppTheme.whiteColor,
                    ),
                  )
                ],
              ),
            ),
          ),
              
          //Seleccion Actividad
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  '¿Qué hacemos?', 
                  style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: MandarinaAppTheme.primaryColor
                  )
                ),
                SizedBox(height: 10,),
                SelectedTaskList(currentPomoState: currentPomoState), //Lista de tareas
              ],
            ),
          ),
          SizedBox(height: 15,),
          //Tag tiempo establecido
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  '¿Cómo lo hacemos?', 
                  style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: MandarinaAppTheme.primaryColor
                  )
                ),
                SizedBox(height: 5,),
                NumberPicker(
                  minValue: 5, 
                  maxValue: 120, 
                  value: (currentPomoState.countTimer/60).toInt().clamp(5, 120),
                  step: 5,
                  axis: Axis.horizontal,
                  itemWidth: 80,
                  itemCount: 5,
                  onChanged: (value){
                    double seconds = value*60;
                    ref.watch(pomoProvider.notifier).setTime(seconds);
                  },
                  textStyle: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: MandarinaAppTheme.blueColor.withValues(alpha: 0.4)
                  ),
                  selectedTextStyle: GoogleFonts.quicksand(
                    fontSize: 30,
                    fontWeight: FontWeight.w500, 
                    color:MandarinaAppTheme.primaryColor
                  ),
                ),
              ],
            ),
          )
    
        ],
      ),
    );
  }
}

class SelectedTaskList extends ConsumerWidget {
  const SelectedTaskList({
    super.key,
    required this.currentPomoState,
  });

  final PomoState currentPomoState;

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          taskList.length,
          (index) {
            // CLAVE: Comparamos contra el estado del watch
            final isSelected = currentPomoState.actualTaskName == taskList[index].title;
        
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: () {
                  ref.read(pomoProvider.notifier).setTask(taskList[index].title);
                },
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(width: 2.0, color: MandarinaAppTheme.primaryColor)
                            : null,
                        color: isSelected 
                            ? MandarinaAppTheme.primaryColor.withValues(alpha: 0.2) 
                            : Colors.transparent,
                      ),
                      child: Icon(
                        taskList[index].icon,
                        color: isSelected 
                            ? MandarinaAppTheme.primaryColor 
                            : MandarinaAppTheme.blueColor.withValues(alpha: 0.4),
                        size: 32.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      taskList[index].title,
                      style: GoogleFonts.quicksand(
                        color: isSelected ? MandarinaAppTheme.primaryColor : MandarinaAppTheme.blueColor.withValues(alpha: 0.4),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}