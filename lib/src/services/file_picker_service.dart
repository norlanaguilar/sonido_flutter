import 'package:file_picker/file_picker.dart';

class FilePickerService {
  Future<List<String>> pickAudioFiles() async {
    // Volvemos a usar .platform que es el correcto para la v8.0.0
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return [];

    return result.files
        .where((f) => f.path != null)
        .map((f) => f.path!)
        .toList();
  }

  Future<String?> pickSingleAudioFile() async {
    // Volvemos a usar .platform que es el correcto para la v8.0.0
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;
    return result.files.first.path;
  }
}