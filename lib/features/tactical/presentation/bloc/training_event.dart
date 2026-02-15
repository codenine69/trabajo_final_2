import 'package:equatable/equatable.dart';

/// Eventos del BLoC de entrenamiento
abstract class EventoEntrenamiento extends Equatable {
  const EventoEntrenamiento();

  @override
  List<Object?> get props => [];
}

class IniciarEntrenamiento extends EventoEntrenamiento {
  final String processId;
  final String exerciseId;
  final String userId;
  final String genero;

  const IniciarEntrenamiento({
    required this.processId,
    required this.exerciseId,
    required this.userId,
    required this.genero,
  });

  @override
  List<Object?> get props => [processId, exerciseId, userId, genero];
}

class ComenzarCarrera extends EventoEntrenamiento {}

class ActualizarPosicion extends EventoEntrenamiento {
  final double latitud;
  final double longitud;

  const ActualizarPosicion({required this.latitud, required this.longitud});

  @override
  List<Object?> get props => [latitud, longitud];
}

class ActualizarTiempo extends EventoEntrenamiento {
  final int segundos;

  const ActualizarTiempo(this.segundos);

  @override
  List<Object?> get props => [segundos];
}

class FinalizarEntrenamiento extends EventoEntrenamiento {}

class DetenerEntrenamiento extends EventoEntrenamiento {}
