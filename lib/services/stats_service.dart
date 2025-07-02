import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_session.dart';

// La clase para los puntos de datos no cambia
class ProgressDataPoint {
  final DateTime date;
  final double value;

  ProgressDataPoint({required this.date, required this.value});
}

class StatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<WorkoutSession>> _getWorkoutHistory(String userId) async {
    final snapshot = await _firestore
        .collection('workout_sessions')
        .where('userId', isEqualTo: userId)
        .orderBy('date') // Ordenamos por fecha para procesar en orden cronológico
        .get();
        
    return snapshot.docs.map((doc) => WorkoutSession.fromMap(doc.data(), doc.id)).toList();
  }

  // --- LÓGICA MEJORADA AQUÍ ---
  Future<List<ProgressDataPoint>> getMaxWeightProgress(String exerciseId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    final history = await _getWorkoutHistory(user.uid);
    
    // Usamos un Map para agregar los datos por día, quedándonos con el máximo.
    final Map<DateTime, double> dailyMaxWeights = {};

    for (final session in history) {
      double maxWeightInSession = 0;
      
      final performedExercises = session.exercises.where((ex) => ex.exerciseId == exerciseId);

      if (performedExercises.isNotEmpty) {
        for (final loggedEx in performedExercises) {
          for (final set in loggedEx.sets) {
            if (set.weight > maxWeightInSession) {
              maxWeightInSession = set.weight;
            }
          }
        }
        
        if (maxWeightInSession > 0) {
          // Normalizamos la fecha a medianoche para agrupar por día
          final day = DateTime(session.date.year, session.date.month, session.date.day);
          
          // Si ya tenemos un registro para ese día, solo lo actualizamos si el nuevo peso es mayor.
          if (dailyMaxWeights.containsKey(day)) {
            if (maxWeightInSession > dailyMaxWeights[day]!) {
              dailyMaxWeights[day] = maxWeightInSession;
            }
          } else {
            // Si no, lo añadimos.
            dailyMaxWeights[day] = maxWeightInSession;
          }
        }
      }
    }
    
    // Convertimos el mapa a una lista de puntos de datos
    final dataPoints = dailyMaxWeights.entries.map((entry) {
      return ProgressDataPoint(date: entry.key, value: entry.value);
    }).toList();
    
    // Ordenamos la lista final por fecha para asegurarnos de que el gráfico sea correcto
    dataPoints.sort((a, b) => a.date.compareTo(b.date));
    
    return dataPoints;
  }
}
