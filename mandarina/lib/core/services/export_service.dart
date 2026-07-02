import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mandarina/presentation/viewmodel/state/workflow_state.dart';

class ExportService {
  /// Exporta la lista de tareas a un archivo CSV y lo comparte mediante el menú nativo.
  Future<void> exportWorkflowToCSV(
    List<WorkflowTask> tasks, {
    required String totalTime,
  }) async {
    // 1. Crear las filas para el CSV
    final List<List<dynamic>> rows = [
      ['Nombre de Tarea', 'Duración'],
    ];

    for (final task in tasks) {
      rows.add([task.name, _formatDuration(task.durationInSeconds)]);
    }

    // Fila vacía al final
    rows.add([]);

    // Fila con el tiempo total acumulado
    rows.add(['Tiempo Total', totalTime]);

    // 2. Convertir a formato texto CSV usando CsvEncoder
    final String csvData = const CsvEncoder().convert(rows);

    // 3. Guardar temporalmente en el directorio de caché del dispositivo
    final Directory tempDir = await getTemporaryDirectory();
    final String filePath = '${tempDir.path}/Resumen_Mandarina_Workflow.csv';
    final File file = File(filePath);
    await file.writeAsString(csvData);

    // 4. Compartir usando share_plus
    await SharePlus.instance.share(
      ShareParams(
        text: 'Resumen de mi jornada de trabajo en Mandarina',
        subject: 'Resumen de Jornada - Mandarina Workflow',
        files: [XFile(file.path, mimeType: 'application/vnd.ms-excel')],
      ),
    );
  }

  // Método auxiliar para formatear la duración en "MM:SS"
  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final String minutes = duration.inMinutes.toString();
    final String twoDigitSeconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return "$minutes:$twoDigitSeconds";
  }
}
