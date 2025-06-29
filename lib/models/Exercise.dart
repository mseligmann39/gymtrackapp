class Exercise {
  final String id;
  final String name;
  final String description;
  final String muscleGroup;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
  });

  factory Exercise.fromMap(Map<String, dynamic> map, String documentId) {
    return Exercise(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      muscleGroup: map['muscleGroup'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'muscleGroup': muscleGroup,
    };
  }
}
