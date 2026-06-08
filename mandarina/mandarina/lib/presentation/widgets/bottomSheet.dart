import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/domain/activities.dart';
import 'package:mandarina/presentation/viewmodel/providers.dart';
import 'package:numberpicker/numberpicker.dart';

class PomoSettingsSheet extends ConsumerWidget {
  const PomoSettingsSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final currentPomoState = ref.watch(pomoProvider);

    double time = currentPomoState.countTimer; //variable local del tiempo
    String taskName = currentPomoState.actualTaskName; //variable local de la tarea
  
    return StatefulBuilder( //StatefulBuilderpara tener un setState local
      builder: (context,setModalState){

        return Container(
          height: 900, // Ajusté el alto para que sea más orgánico
          decoration: BoxDecoration(
            color: MandarinaAppTheme.whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            //mainAxisSize: MainAxisSize.min,
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
                    SelectedTaskList(
                      selectedTaskName: taskName,
                      onTaskSelected: (newType){
                        setModalState(() => taskName =newType);
                      }
                    ), //Lista de tareas
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
                    SizedBox(height: 15,),
                    SelectedTime(
                      selectedTime: time,
                      onTimeSelected: (newValue){
                        setModalState(() => time=newValue,);
                      }

                    ),
                    
                  ],
                ),
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                  backgroundColor: MandarinaAppTheme.blueColor,
                ),
                onPressed: (){
                  ref.read(pomoProvider.notifier).setTime(time);
                  ref.read(pomoProvider.notifier).setTask(taskName);
                  context.pop();
                }, 
                child: Text(
                  'Confirmar',
                  style: GoogleFonts.quicksand(
                    color: MandarinaAppTheme.whiteColor,
                    fontSize: 28,
                  ),
                )
              )
        
            ],
          ),
        );
      }
    );
  }
  /*
  Widget _buildTimeSelector(PomoState currentPomoState, WidgetRef ref) {
    final circleSize = ref.watch(dynamicCircleSizeProvider);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          // Solo se infla si el usuario tiene el dedo apoyado (dragDetails != null)
          if (notification.dragDetails != null) {
            ref.read(dynamicCircleSizeProvider.notifier).state = 1.0; // Valor inflado
          } else {
            // Si se mueve por inercia pero sin dedo, vuelve al original
            ref.read(dynamicCircleSizeProvider.notifier).state = 60.0;
          }
        } else if (notification is ScrollEndNotification) {
          // Al detenerse por completo, nos aseguramos que vuelva a 60
          ref.read(dynamicCircleSizeProvider.notifier).state = 60.0;
        }
        return false;
      },
      child: Stack(
        alignment: Alignment.center,
        children: [

          /*
          // Lineas guía para el centrado del número
          
          Container(
            width: 40,
            height: 50,
            decoration: BoxDecoration(shape: BoxShape.rectangle,borderRadius: BorderRadius.circular(5),color: Colors.transparent,border: Border.all(color: Colors.black, width: 1),),
          ),
          Container(
            width: 200,
            height: 30,
            decoration: BoxDecoration(shape: BoxShape.rectangle,borderRadius: BorderRadius.circular(5),color: Colors.transparent,border: Border.all(color: Colors.black, width: 1),),
          ),
          */
          
          // La burbuja que reacciona al gesto
          Transform.translate(
            offset: const Offset(0, -0.2),
            child: AnimatedContainer(
              alignment: Alignment.center,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: circleSize,
                width: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,//MandarinaAppTheme.accentColor.withValues(alpha: 0.2),
                  border: Border.all(color: MandarinaAppTheme.accentColor, width: 2),
                ),
              ),
          ),     
        
          Transform.translate(
              offset: const Offset(-2, 0),
              child: NumberPicker(
                // ... tus otras propiedades (minValue, maxValue, etc.)
                        minValue: 5, 
                        maxValue: 120, 
                        value: (currentPomoState.countTimer/60).toInt().clamp(5, 120),
                        step: 5,
                        itemWidth: 80,
                        itemCount: 5,
                axis: Axis.horizontal,
                //decoration:BoxDecoration(shape:BoxShape.circle,border: Border.all(color: Colors.black)),
                onChanged: (value) {
                  ref.read(pomoProvider.notifier).setTime(value.toDouble() * 60);
                },
                                  textStyle: GoogleFonts.quicksand(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: MandarinaAppTheme.blueColor.withValues(alpha: 0.4),
                          height: 1.0,
                        ),
                        selectedTextStyle: GoogleFonts.quicksand(
                          fontSize: 30,
                          fontWeight: FontWeight.w600, 
                          color:MandarinaAppTheme.primaryColor,
                          height: -0.1,
                        ),
              ),
          ),
        ],
      ),
    );
  }
  */
}

class SelectedTime extends ConsumerWidget {
  const SelectedTime({
    super.key,
    required this.selectedTime,
    required this.onTimeSelected
  });

  final double selectedTime;
  final Function(double) onTimeSelected;


  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final circleSize = ref.watch(dynamicCircleSizeProvider);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          // Solo se infla si el usuario tiene el dedo apoyado (dragDetails != null)
          if (notification.dragDetails != null) {
            ref.read(dynamicCircleSizeProvider.notifier).state = 1.0; // Valor inflado
          } else {
            // Si se mueve por inercia pero sin dedo, vuelve al original
            ref.read(dynamicCircleSizeProvider.notifier).state = 60.0;
          }
        } else if (notification is ScrollEndNotification) {
          // Al detenerse por completo, nos aseguramos que vuelva a 60
          ref.read(dynamicCircleSizeProvider.notifier).state = 60.0;
        }
        return false;
      },
      child: Stack(
        alignment: Alignment.center,
        children: [

          // Lineas guía para el centrado del número
          /*
          Container(
            width: 40,
            height: 50,
            decoration: BoxDecoration(shape: BoxShape.rectangle,borderRadius: BorderRadius.circular(5),color: Colors.transparent,border: Border.all(color: Colors.black, width: 1),),
          ),
          Container(
            width: 200,
            height: 30,
            decoration: BoxDecoration(shape: BoxShape.rectangle,borderRadius: BorderRadius.circular(5),color: Colors.transparent,border: Border.all(color: Colors.black, width: 1),),
          ),
          */
          
          // La burbuja que reacciona al gesto
          Transform.translate(
            offset: const Offset(0, -0.2),
            child: AnimatedContainer(
              alignment: Alignment.center,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: circleSize,
                width: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,//MandarinaAppTheme.accentColor.withValues(alpha: 0.2),
                  border: Border.all(color: MandarinaAppTheme.accentColor, width: 2),
                ),
              ),
          ),     
        
          Transform.translate(
            offset: const Offset(-2, 0),
            child: NumberPicker(
              // ... tus otras propiedades (minValue, maxValue, etc.)
              minValue: 5, 
              maxValue: 120, 
              //value: (currentPomoState.countTimer/60).toInt().clamp(5, 120),
              value: (selectedTime/60).toInt().clamp(5, 120),
              step: 5,
              itemWidth: 80,
              itemCount: 5,
                          axis: Axis.horizontal,
                          //decoration:BoxDecoration(shape:BoxShape.circle,border: Border.all(color: Colors.black)),
                          onChanged: (value) {
                            onTimeSelected(value.toDouble() * 60);
                          },
                        textStyle: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: MandarinaAppTheme.blueColor.withValues(alpha: 0.4),
                height: 1.0,
              ),
              selectedTextStyle: GoogleFonts.quicksand(
                fontSize: 30,
                fontWeight: FontWeight.w600, 
                color:MandarinaAppTheme.primaryColor,
                height: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectedTaskList extends ConsumerWidget {
  const SelectedTaskList({
    super.key,
    required this.selectedTaskName,
    required this.onTaskSelected,
  });

  final String selectedTaskName;
  final Function(String) onTaskSelected;

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          taskList.length,
          (index) {
            // CLAVE: Comparamos contra el estado del watch
            final isSelected = selectedTaskName == taskList[index].title;
        
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: () {
                  onTaskSelected(taskList[index].title);
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