import 'package:equatable/equatable.dart';
import 'scoring_range.dart';

/// Tipos de unidades para ejercicios
enum UnidadEjercicio { segundos, metros, repeticiones }

/// Tipo de objetivo del ejercicio
enum ObjetivoEjercicio { minimo, maximo }

/// Configuración de un ejercicio físico
class ConfiguracionEjercicio extends Equatable {
  final String id;
  final String nombre;
  final UnidadEjercicio unidad;
  final ObjetivoEjercicio objetivo;
  final List<RangoPuntuacion> tablaHommes;
  final List<RangoPuntuacion> tablaMujeres;

  const ConfiguracionEjercicio({
    required this.id,
    required this.nombre,
    required this.unidad,
    required this.objetivo,
    required this.tablaHommes,
    required this.tablaMujeres,
  });

  factory ConfiguracionEjercicio.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return ConfiguracionEjercicio(
      id: id,
      nombre: data['name'] as String,
      unidad: _parseUnidad(data['unit'] as String),
      objetivo: _parseObjetivo(data['goal'] as String),
      tablaHommes: (data['scoring_table_male'] as List<dynamic>)
          .map((e) => RangoPuntuacion.fromMap(e as Map<String, dynamic>))
          .toList(),
      tablaMujeres: (data['scoring_table_female'] as List<dynamic>)
          .map((e) => RangoPuntuacion.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static UnidadEjercicio _parseUnidad(String unit) {
    switch (unit) {
      case 'SECONDS':
        return UnidadEjercicio.segundos;
      case 'METERS':
        return UnidadEjercicio.metros;
      case 'REPS':
        return UnidadEjercicio.repeticiones;
      default:
        throw ArgumentError('Unidad desconocida: $unit');
    }
  }

  static ObjetivoEjercicio _parseObjetivo(String goal) {
    switch (goal) {
      case 'MIN':
        return ObjetivoEjercicio.minimo;
      case 'MAX':
        return ObjetivoEjercicio.maximo;
      default:
        throw ArgumentError('Objetivo desconocido: $goal');
    }
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    unidad,
    objetivo,
    tablaHommes,
    tablaMujeres,
  ];
}
