import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'training_event.dart';
import 'training_state.dart';
import '../../data/services/firestore_service.dart';
import '../../domain/logic/scoring_logic.dart';
import '../../domain/entities/training_session.dart';
import 'dart:math' show sqrt, pow, atan2, cos, sin;

/// BLoC para gestionar el estado del entrenamiento
class BlocEntrenamiento extends Bloc<EventoEntrenamiento, EstadoEntrenamiento> {
  final ServicioFirestore servicioFirestore;

  Timer? _timer;
  int _segundosTranscurridos = 0;
  List<Map<String, double>> _puntosGPS = [];
  double _distanciaTotal = 0.0;

  BlocEntrenamiento({required this.servicioFirestore})
    : super(EntrenamientoInicial()) {
    on<IniciarEntrenamiento>(_onIniciarEntrenamiento);
    on<ComenzarCarrera>(_onComenzarCarrera);
    on<ActualizarPosicion>(_onActualizarPosicion);
    on<ActualizarTiempo>(_onActualizarTiempo);
    on<FinalizarEntrenamiento>(_onFinalizarEntrenamiento);
    on<DetenerEntrenamiento>(_onDetenerEntrenamiento);
  }

  Future<void> _onIniciarEntrenamiento(
    IniciarEntrenamiento event,
    Emitter<EstadoEntrenamiento> emit,
  ) async {
    emit(EntrenamientoCargando());
    try {
      final ejercicio = await servicioFirestore.obtenerEjercicio(
        event.processId,
        event.exerciseId,
      );

      if (ejercicio == null) {
        emit(const EntrenamientoError('Ejercicio no encontrado'));
        return;
      }

      emit(EntrenamientoListo(ejercicio: ejercicio, genero: event.genero));
    } catch (e) {
      emit(EntrenamientoError('Error al cargar ejercicio: $e'));
    }
  }

  void _onComenzarCarrera(
    ComenzarCarrera event,
    Emitter<EstadoEntrenamiento> emit,
  ) {
    final currentState = state;
    if (currentState is! EntrenamientoListo) return;

    // Inicializar variables
    _segundosTranscurridos = 0;
    _puntosGPS = [];
    _distanciaTotal = 0.0;

    // Iniciar cronómetro
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _segundosTranscurridos++;
      add(ActualizarTiempo(_segundosTranscurridos));
    });

    emit(
      EntrenamientoEnCurso(
        ejercicio: currentState.ejercicio,
        genero: currentState.genero,
        tiempoTranscurrido: 0,
        distanciaRecorrida: 0,
        puntosGPS: [],
      ),
    );
  }

  void _onActualizarPosicion(
    ActualizarPosicion event,
    Emitter<EstadoEntrenamiento> emit,
  ) {
    final currentState = state;
    if (currentState is! EntrenamientoEnCurso) return;

    // Agregar nuevo punto GPS
    final nuevoPunto = {'lat': event.latitud, 'lng': event.longitud};
    _puntosGPS.add(nuevoPunto);

    // Calcular distancia si hay al menos 2 puntos
    if (_puntosGPS.length >= 2) {
      final ultimo = _puntosGPS[_puntosGPS.length - 2];
      final actual = _puntosGPS.last;

      final distancia = _calcularDistanciaHaversine(
        ultimo['lat']!,
        ultimo['lng']!,
        actual['lat']!,
        actual['lng']!,
      );

      _distanciaTotal += distancia;
    }

    emit(
      EntrenamientoEnCurso(
        ejercicio: currentState.ejercicio,
        genero: currentState.genero,
        tiempoTranscurrido: _segundosTranscurridos,
        distanciaRecorrida: _distanciaTotal,
        puntosGPS: List.from(_puntosGPS),
      ),
    );
  }

  void _onActualizarTiempo(
    ActualizarTiempo event,
    Emitter<EstadoEntrenamiento> emit,
  ) {
    final currentState = state;
    if (currentState is! EntrenamientoEnCurso) return;

    emit(
      EntrenamientoEnCurso(
        ejercicio: currentState.ejercicio,
        genero: currentState.genero,
        tiempoTranscurrido: event.segundos,
        distanciaRecorrida: _distanciaTotal,
        puntosGPS: currentState.puntosGPS,
      ),
    );
  }

  Future<void> _onFinalizarEntrenamiento(
    FinalizarEntrenamiento event,
    Emitter<EstadoEntrenamiento> emit,
  ) async {
    final currentState = state;
    if (currentState is! EntrenamientoEnCurso) return;

    _timer?.cancel();

    // Calcular puntuación
    final tabla = currentState.genero == 'M'
        ? currentState.ejercicio.tablaHommes
        : currentState.ejercicio.tablaMujeres;

    final valorFinal = _segundosTranscurridos.toDouble();
    final puntuacion = LogicaPuntuacion.calcularPuntuacion(
      valor: valorFinal,
      tabla: tabla,
    );

    // Crear sesión
    final sesion = SesionEntrenamiento(
      userId: 'current_user', // TODO: Obtener del contexto de autenticación
      nombreProceso: 'Proceso Actual', // TODO: Obtener del proceso activo
      puntuacionTotal: puntuacion,
      timestamp: DateTime.now(),
      resultadosEjercicios: [
        ResultadoEjercicio(
          nombre: currentState.ejercicio.nombre,
          valor: valorFinal,
          puntos: puntuacion,
          polilineaGps: _puntosGPS,
        ),
      ],
    );

    // Guardar en Firestore
    try {
      await servicioFirestore.guardarSesionEntrenamiento(sesion);
      emit(
        EntrenamientoCompletado(
          puntuacion: puntuacion,
          valorFinal: valorFinal,
          sesion: sesion,
        ),
      );
    } catch (e) {
      emit(EntrenamientoError('Error al guardar sesión: $e'));
    }
  }

  void _onDetenerEntrenamiento(
    DetenerEntrenamiento event,
    Emitter<EstadoEntrenamiento> emit,
  ) {
    _timer?.cancel();
    _segundosTranscurridos = 0;
    _puntosGPS = [];
    _distanciaTotal = 0.0;
    emit(EntrenamientoInicial());
  }

  /// Calcula la distancia entre dos puntos GPS usando la fórmula
  /// Retorna la distancia en metros
  double _calcularDistanciaHaversine(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const radioTierra = 6371000.0; // en metros
    final dLat = _gradosARadianes(lat2 - lat1);
    final dLon = _gradosARadianes(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_gradosARadianes(lat1)) *
            cos(_gradosARadianes(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radioTierra * c;
  }

  double _gradosARadianes(double grados) {
    return grados * 3.14159265359 / 180.0;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
