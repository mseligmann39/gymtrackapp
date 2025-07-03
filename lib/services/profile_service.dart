import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart'; // Deshabilitado temporalmente
import 'package:image_picker/image_picker.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance; // Deshabilitado temporalmente
  final ImagePicker _picker = ImagePicker();

  // La función para elegir imagen se mantiene, pero no se usará para subirla por ahora.
  Future<File?> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return null;
    return File(image.path);
  }

  /*
  // --- SECCIÓN DE SUBIDA DE IMAGEN DESHABILITADA TEMPORALMENTE ---
  // Cuando decidas usar Firebase Storage, puedes descomentar este bloque.
  
  Future<String> _uploadProfilePicture(File imageFile, String userId) async {
    try {
      final ref = _storage.ref().child('profile_pictures').child('$userId.jpg');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error al subir la imagen: $e");
      rethrow;
    }
  }
  */

  // Actualiza el perfil del usuario (solo el nombre por ahora)
  Future<void> updateUserProfile({
    required String newName,
    File? newImageFile, // El parámetro se mantiene, pero no lo usaremos
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    /*
    // --- LÓGICA DE SUBIDA DE IMAGEN DESHABILITADA ---
    String? newPhotoUrl;
    if (newImageFile != null) {
      newPhotoUrl = await _uploadProfilePicture(newImageFile, user.uid);
    }
    */

    // Actualizamos solo el nombre en Firebase Auth
    await user.updateDisplayName(newName);
    
    /*
    // --- LÓGICA DE ACTUALIZACIÓN DE URL DESHABILITADA ---
    if (newPhotoUrl != null) {
      await user.updatePhotoURL(newPhotoUrl);
    }
    */
    
    // Es necesario recargar el usuario para que los cambios se reflejen en la app
    await user.reload();
  }
}