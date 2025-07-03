import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileService _profileService = ProfileService();
  late TextEditingController _nameController;
  File? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<User?>();
    _nameController = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _profileService.pickImage();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío.')),
      );
      return;
    }
    
    setState(() => _isSaving = true);

    try {
      await _profileService.updateUserProfile(
        newName: _nameController.text.trim(),
        newImageFile: _selectedImage,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado con éxito.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          if (_isSaving)
            const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)))
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _saveProfile)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Selector de imagen
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (user?.photoURL != null ? NetworkImage(user!.photoURL!) : null) as ImageProvider?,
                child: _selectedImage == null && user?.photoURL == null
                    ? Icon(Icons.camera_alt, color: Colors.grey.shade800, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _pickImage, child: const Text('Cambiar foto')),
            const SizedBox(height: 24),

            // Campo de texto para el nombre
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre para mostrar',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
