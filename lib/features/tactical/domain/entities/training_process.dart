import 'package:equatable/equatable.dart';

///   proceso de entrenamiento (PNP, Ejército, etc.)
class ProcesoEntrenamiento extends Equatable {
  final String id;
  final String institucion;
  final String nombre;
  final String tipoObjetivo;
  final String? subtipoObjetivo;

  const ProcesoEntrenamiento({
    required this.id,
    required this.institucion,
    required this.nombre,
    required this.tipoObjetivo,
    this.subtipoObjetivo,
  });

  factory ProcesoEntrenamiento.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return ProcesoEntrenamiento(
      id: id,
      institucion: data['institution'] as String,
      nombre: data['name'] as String,
      tipoObjetivo: data['target_type'] as String,
      subtipoObjetivo: data['target_subtype'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'institution': institucion,
      'name': nombre,
      'target_type': tipoObjetivo,
      'target_subtype': subtipoObjetivo,
    };
  }

  @override
  List<Object?> get props => [
    id,
    institucion,
    nombre,
    tipoObjetivo,
    subtipoObjetivo,
  ];
}
