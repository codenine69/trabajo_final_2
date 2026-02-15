import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/training_bloc.dart';
import '../bloc/training_event.dart';
import '../bloc/training_state.dart';
import '../../domain/logic/scoring_logic.dart';

/// Pantalla principal para el entrenamiento con GPS
class PantallaCorreedor extends StatefulWidget {
  final String processId;
  final String exerciseId;
  final String userId;
  final String genero;

  const PantallaCorreedor({
    Key? key,
    required this.processId,
    required this.exerciseId,
    required this.userId,
    required this.genero,
  }) : super(key: key);

  @override
  State<PantallaCorreedor> createState() => _PantallaCorredorState();
}

class _PantallaCorredorState extends State<PantallaCorreedor> {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Position? _posicionActual;
  bool _siguiendoUsuario = true;
  StreamSubscription<Position>? _posicionSubscription;

  @override
  void initState() {
    super.initState();
    context.read<BlocEntrenamiento>().add(
      IniciarEntrenamiento(
        processId: widget.processId,
        exerciseId: widget.exerciseId,
        userId: widget.userId,
        genero: widget.genero,
      ),
    );
    _inicializarGPS();
  }

  Future<void> _inicializarGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _mostrarError('Por favor, activa el GPS');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _mostrarError('Permisos de ubicación denegados');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _mostrarError('Permisos de ubicación permanentemente denegados');
      return;
    }

    // Obtener posición actual
    _posicionActual = await Geolocator.getCurrentPosition();
    setState(() {});
  }

  void _comenzarEntrenamiento() {
    context.read<BlocEntrenamiento>().add(ComenzarCarrera());

    // 🎮 SIMULACIÓN DE GPS PARA EMULADOR
    // Cambiar para GPS real en dispositivo físico
    const bool usarSimulacion = true;

    if (usarSimulacion) {
      // Stream simulado de movimiento (para emulador)
      _posicionSubscription = _simulatedLocationStream().listen((
        Position position,
      ) {
        _posicionActual = position;
        context.read<BlocEntrenamiento>().add(
          ActualizarPosicion(
            latitud: position.latitude,
            longitud: position.longitude,
          ),
        );

        if (_siguiendoUsuario && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(position.latitude, position.longitude),
            ),
          );
        }
      });
    } else {
      // GPS real (para dispositivo físico)
      _posicionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5, // Actualizar cada 5 metros
            ),
          ).listen((Position position) {
            _posicionActual = position;
            context.read<BlocEntrenamiento>().add(
              ActualizarPosicion(
                latitud: position.latitude,
                longitud: position.longitude,
              ),
            );

            if (_siguiendoUsuario && _mapController != null) {
              _mapController!.animateCamera(
                CameraUpdate.newLatLng(
                  LatLng(position.latitude, position.longitude),
                ),
              );
            }
          });
    }
  }

  /// 🎮 Simulación de movimiento GPS para emulador
  /// Genera posiciones cada 2 segundos simulando una carrera en Lima
  Stream<Position> _simulatedLocationStream() async* {
    // Coordenadas iniciales (Lima, Perú - cerca del Pentagonito)
    double lat = -12.046374;
    double lng = -77.042793;

    // Simular movimiento durante ~5 minutos (150 segundos)
    for (int i = 0; i < 75; i++) {
      await Future.delayed(const Duration(seconds: 2));

      // Simular movimiento realista (zigzag ligero)
      lat += 0.00015; // ~16.7 metros hacia el norte
      lng += (i % 2 == 0) ? 0.00003 : -0.00003; // Zigzag leve

      yield Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 150.0,
        altitudeAccuracy: 3.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 3.5, // ~3.5 m/s (velocidad de carrera moderada)
        speedAccuracy: 0.5,
      );
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrenamiento Táctico'),
        backgroundColor: Colors.teal,
      ),
      body: BlocConsumer<BlocEntrenamiento, EstadoEntrenamiento>(
        listener: (context, state) {
          if (state is EntrenamientoError) {
            _mostrarError(state.mensaje);
          } else if (state is EntrenamientoCompletado) {
            _mostrarResultado(state);
          }
        },
        builder: (context, state) {
          if (state is EntrenamientoCargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EntrenamientoListo) {
            return _buildPantallaLista(state);
          }

          if (state is EntrenamientoEnCurso) {
            return _buildPantallaEnCurso(state);
          }

          return const Center(child: Text('Inicializando...'));
        },
      ),
    );
  }

  Widget _buildPantallaLista(EntrenamientoListo state) {
    return Column(
      children: [
        Expanded(
          child: _posicionActual == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _posicionActual!.latitude,
                      _posicionActual!.longitude,
                    ),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                state.ejercicio.nombre,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Género: ${state.genero == "M" ? "Masculino" : "Femenino"}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _comenzarEntrenamiento,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'COMENZAR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPantallaEnCurso(EntrenamientoEnCurso state) {
    // Actualizar polyline
    if (state.puntosGPS.isNotEmpty) {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('ruta'),
          points: state.puntosGPS
              .map((p) => LatLng(p['lat']!, p['lng']!))
              .toList(),
          color: Colors.blue,
          width: 5,
        ),
      };
    }

    // Calcular puntuación en vivo
    final tabla = state.genero == 'M'
        ? state.ejercicio.tablaHommes
        : state.ejercicio.tablaMujeres;
    final puntuacionActual = LogicaPuntuacion.calcularPuntuacion(
      valor: state.tiempoTranscurrido.toDouble(),
      tabla: tabla,
    );

    return Column(
      children: [
        Expanded(
          child: _posicionActual == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _posicionActual!.latitude,
                      _posicionActual!.longitude,
                    ),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  polylines: _polylines,
                  markers: _markers,
                ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Métricas principales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetrica(
                    'Tiempo',
                    LogicaPuntuacion.formatearTiempo(state.tiempoTranscurrido),
                    Icons.timer,
                  ),
                  _buildMetrica(
                    'Distancia',
                    '${state.distanciaRecorrida.toStringAsFixed(0)}m',
                    Icons.straighten,
                  ),
                  _buildMetrica(
                    'Puntos',
                    puntuacionActual.toStringAsFixed(1),
                    Icons.stars,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 💬 Mensaje motivacional con objetivos
              _buildMensajeMotivacional(
                state.tiempoTranscurrido,
                puntuacionActual,
                tabla,
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<BlocEntrenamiento>().add(
                    FinalizarEntrenamiento(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 40,
                  ),
                ),
                child: const Text(
                  'FINALIZAR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetrica(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.teal),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  /// 💬 Construye mensaje motivacional basado en las tablas de Firebase
  Widget _buildMensajeMotivacional(
    int tiempoActual,
    double puntuacionActual,
    List<dynamic> tabla,
  ) {
    // Encontrar el siguiente objetivo (mejor puntaje)
    String mensaje = '';
    Color colorFondo = Colors.blue.shade50;
    IconData icono = Icons.info_outline;

    // Ordenar tabla por puntos descendente para encontrar objetivos
    final tablaOrdenada = List.from(tabla)
      ..sort((a, b) => b.puntos.compareTo(a.puntos));

    // Buscar el siguiente nivel de puntaje
    var siguienteNivel = tablaOrdenada.firstWhere(
      (rango) => rango.puntos > puntuacionActual,
      orElse: () => null,
    );

    if (puntuacionActual >= 20) {
      // Excelente rendimiento
      mensaje =
          '🏆 ¡EXCELENTE! Puntuación máxima: ${puntuacionActual.toStringAsFixed(1)} pts';
      colorFondo = Colors.green.shade50;
      icono = Icons.emoji_events;
    } else if (puntuacionActual >= 15) {
      // Buen rendimiento
      if (siguienteNivel != null) {
        final tiempoObjetivo = siguienteNivel.max.toInt();
        final diferencia = tiempoActual - tiempoObjetivo;
        mensaje =
            '✨ ${puntuacionActual.toStringAsFixed(1)} pts - Para ${siguienteNivel.puntos.toStringAsFixed(0)} pts necesitas ${LogicaPuntuacion.formatearTiempo(tiempoObjetivo)} (${diferencia}s más rápido)';
      } else {
        mensaje = '👍 Buen tiempo: ${puntuacionActual.toStringAsFixed(1)} pts';
      }
      colorFondo = Colors.green.shade50;
      icono = Icons.trending_up;
    } else if (puntuacionActual >= 10) {
      // Rendimiento regular
      if (siguienteNivel != null) {
        final tiempoObjetivo = siguienteNivel.max.toInt();
        final diferencia = tiempoActual - tiempoObjetivo;
        mensaje =
            '💪 ${puntuacionActual.toStringAsFixed(1)} pts - Objetivo: ${siguienteNivel.puntos.toStringAsFixed(0)} pts en ${LogicaPuntuacion.formatearTiempo(tiempoObjetivo)} (${diferencia}s más rápido)';
      } else {
        mensaje = '⚡ Sigue así: ${puntuacionActual.toStringAsFixed(1)} pts';
      }
      colorFondo = Colors.orange.shade50;
      icono = Icons.speed;
    } else {
      // Necesita mejorar
      if (siguienteNivel != null) {
        final tiempoObjetivo = siguienteNivel.max.toInt();
        final diferencia = tiempoActual - tiempoObjetivo;
        mensaje =
            '🚀 ¡Acelera! Para ${siguienteNivel.puntos.toStringAsFixed(0)} pts necesitas ${LogicaPuntuacion.formatearTiempo(tiempoObjetivo)} (${diferencia}s menos)';
      } else {
        mensaje =
            '🏃 ¡Vamos, puedes más! ${puntuacionActual.toStringAsFixed(1)} pts';
      }
      colorFondo = Colors.red.shade50;
      icono = Icons.rocket_launch;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorFondo.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Icon(icono, color: Colors.teal.shade700, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarResultado(EntrenamientoCompletado state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Entrenamiento Completado!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              state.puntuacion >= 15 ? Icons.check_circle : Icons.warning,
              size: 64,
              color: state.puntuacion >= 15 ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Tiempo: ${LogicaPuntuacion.formatearTiempo(state.valorFinal.toInt())}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Puntuación: ${state.puntuacion.toStringAsFixed(1)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('CERRAR'),
          ),
        ],
      ),
    );

    /// 📊 Muestra modal con tabla de puntuación

    @override
    void dispose() {
      _posicionSubscription?.cancel();
      _mapController?.dispose();
      super.dispose();
    }
  }
}
