import 'package:equatable/equatable.dart';
import '../../domain/entities/exercise_config.dart';
import '../../domain/entities/training_session.dart';

/// Estados del BLoC de entrenamiento
abstract class EstadoEntrenamiento extends Equatable {
  const EstadoEntrenamiento();

  @override
  List<Object?> get props => [];
}

class EntrenamientoInicial extends EstadoEntrenamiento {}

class EntrenamientoCargando extends EstadoEntrenamiento {}

class EntrenamientoListo extends EstadoEntrenamiento {
  final ConfiguracionEjercicio ejercicio;
  final String genero;

  const EntrenamientoListo({required this.ejercicio, required this.genero});

  @override
  List<Object?> get props => [ejercicio, genero];
}

class EntrenamientoEnCurso extends EstadoEntrenamiento {
  final ConfiguracionEjercicio ejercicio;
  final String genero;
  final int tiempoTranscurrido; // en segundos
  final double distanciaRecorrida; // en metros
  final List<Map<String, double>> puntosGPS;

  const EntrenamientoEnCurso({
    required this.ejercicio,
    required this.genero,
    required this.tiempoTranscurrido,
    required this.distanciaRecorrida,
    required this.puntosGPS,
  });

  @override
  List<Object?> get props => [
    ejercicio,
    genero,
    tiempoTranscurrido,
    distanciaRecorrida,
    puntosGPS,
  ];
}

class EntrenamientoCompletado extends EstadoEntrenamiento {
  final double puntuacion;
  final double valorFinal; // tiempo o distancia
  final SesionEntrenamiento sesion;

  const EntrenamientoCompletado({
    required this.puntuacion,
    required this.valorFinal,
    required this.sesion,
  });

  @override
  List<Object?> get props => [puntuacion, valorFinal, sesion];
}

class EntrenamientoError extends EstadoEntrenamiento {
  final String mensaje;

  const EntrenamientoError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
