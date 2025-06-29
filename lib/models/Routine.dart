class Routine {
  final String id;
  final String name;
  final List<String> exerciseIds; // IDs de ejercicios en la rutina

  Routine({
    required this.id,
    required this.name,
    required this.exerciseIds,
  });

  factory Routine.fromMap(Map<String, dynamic> map, String documentId) {
    return Routine(
      id: documentId,
      name: map['name'] ?? '',
      exerciseIds: List<String>.from(map['exerciseIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'exerciseIds': exerciseIds,
    };
  }
}
