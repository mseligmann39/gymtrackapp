import 'package:cloud_firestore/cloud_firestore.dart';

class Routine {
  final String? id;
  final String name;
  final List<String> exerciseIds; // Guardamos solo los IDs de los ejercicios
  final String userId;

  Routine({
    this.id,
    required this.name,
    required this.exerciseIds,
    required this.userId,
  });

  // Métodos para convertir a/desde un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'exerciseIds': exerciseIds,
      'userId': userId,
    };
  }

  factory Routine.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Routine(
      id: doc.id,
      name: data['name'] ?? '',
      // Nos aseguramos de convertir la lista de dynamic a String
      exerciseIds: List<String>.from(data['exerciseIds'] ?? []),
      userId: data['userId'] ?? '',
    );
  }
}
