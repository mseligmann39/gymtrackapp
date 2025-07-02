import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/exercise.dart';
import '../services/exercise_service.dart';
import '../services/stats_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  final StatsService _statsService = StatsService();
  
  List<Exercise> _availableExercises = [];
  Exercise? _selectedExercise;
  bool _isLoadingExercises = true;
  bool _isLoadingChart = false;

  List<FlSpot> _chartData = [];
  double _minX = 0, _maxX = 0, _minY = 0, _maxY = 0;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final exercises = await _exerciseService.getExercises();
      if (mounted) {
        setState(() {
          _availableExercises = exercises;
          _isLoadingExercises = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingExercises = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar ejercicios: $e')),
        );
      }
    }
  }

  Future<void> _onExerciseSelected(Exercise? exercise) async {
    if (exercise == null) return;

    setState(() {
      _selectedExercise = exercise;
      _isLoadingChart = true;
      _chartData = [];
    });

    try {
      final progressData = await _statsService.getMaxWeightProgress(exercise.id);
      
      if (mounted) {
        setState(() {
          if (progressData.length < 2) {
            _chartData = [];
          } else {
            // Convertimos los datos a puntos del gráfico (FlSpot)
            _chartData = progressData.map((data) {
              return FlSpot(
                data.date.difference(progressData.first.date).inDays.toDouble(),
                data.value,
              );
            }).toList();

            // Solo calculamos los límites si de verdad hay datos
            if (_chartData.isNotEmpty) {
              final yValues = _chartData.map((spot) => spot.y);
              _minX = _chartData.first.x;
              _maxX = _chartData.last.x;
              _minY = yValues.reduce((a, b) => a < b ? a : b) - 5;
              _maxY = yValues.reduce((a, b) => a > b ? a : b) + 5;
              
              // Nos aseguramos de que el eje Y no empiece en negativo
              if (_minY < 0) _minY = 0;
            }
          }
          _isLoadingChart = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar el progreso: $e')),
        );
        setState(() {
          _isLoadingChart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso y Estadísticas'),
      ),
      body: _isLoadingExercises
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<Exercise>(
                    value: _selectedExercise,
                    hint: const Text('Selecciona un ejercicio'),
                    isExpanded: true,
                    items: _availableExercises.map((Exercise exercise) {
                      return DropdownMenuItem<Exercise>(
                        value: exercise,
                        child: Text(exercise.name),
                      );
                    }).toList(),
                    onChanged: _onExerciseSelected,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _selectedExercise == null ? 'Progreso' : 'Peso Máx. en ${_selectedExercise!.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.withOpacity(0.05),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: _buildChart(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildChart() {
    if (_isLoadingChart) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_selectedExercise == null) {
      return const Center(child: Text('Selecciona un ejercicio para ver tu progreso.'));
    }
    if (_chartData.isEmpty) {
      return const Center(child: Text('No hay suficientes datos para mostrar un gráfico. Necesitas al menos 2 sesiones con este ejercicio.'));
    }
    
    return LineChart(
      LineChartData(
        minX: _minX,
        maxX: _maxX,
        minY: _minY,
        maxY: _maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) => const FlLine(color: Colors.grey, strokeWidth: 0.5),
          getDrawingVerticalLine: (value) => const FlLine(color: Colors.grey, strokeWidth: 0.5),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text('${value.toInt()} kg', style: const TextStyle(fontSize: 10)),
            ),
          ),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey)),
        lineBarsData: [
          LineChartBarData(
            spots: _chartData,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
