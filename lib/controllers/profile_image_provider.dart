import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

final profileImageProvider = NotifierProvider<ProfileImageNotifier, File?>(() {
  return ProfileImageNotifier();
});

class ProfileImageNotifier extends Notifier<File?> {
  static const _imageKey = 'profile_image_path';

  @override
  File? build() {
    _loadSavedImage();
    return null;
  }

  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_imageKey);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        state = file;
      } else {
        await prefs.remove(_imageKey);
      }
    }
  }

  Future<void> pickAndSaveImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'profile_image_${DateTime.now().millisecondsSinceEpoch}${p.extension(pickedFile.path)}';
        final savedPath = p.join(directory.path, fileName);
        
        final savedFile = await File(pickedFile.path).copy(savedPath);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_imageKey, savedPath);
        
        state = savedFile;
      } catch (e) {
        // Ignorar error de guardado en producción
      }
    }
  }
}
