import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Resultado de un ejercicio individual
class ResultadoEjercicio {
  final String nombre;
  final double valor;
  final double puntos;
  final List<Map<String, double>>? polilineaGps;

  ResultadoEjercicio({
    required this.nombre,
    required this.valor,
    required this.puntos,
    this.polilineaGps,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': nombre,
      'value': valor,
      'score': puntos,
      if (polilineaGps != null) 'gps_polyline': polilineaGps,
    };
  }
}

/// Sesión de entrenamiento completa
class SesionEntrenamiento extends Equatable {
  final String userId;
  final String nombreProceso;
  final double puntuacionTotal;
  final DateTime timestamp;
  final List<ResultadoEjercicio> resultadosEjercicios;

  const SesionEntrenamiento({
    required this.userId,
    required this.nombreProceso,
    required this.puntuacionTotal,
    required this.timestamp,
    required this.resultadosEjercicios,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'process_name': nombreProceso,
      'total_score': puntuacionTotal,
      'timestamp': Timestamp.fromDate(timestamp),
      'exercises_results': resultadosEjercicios.map((e) => e.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    userId,
    nombreProceso,
    puntuacionTotal,
    timestamp,
    resultadosEjercicios,
  ];
}
