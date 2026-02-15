import 'package:equatable/equatable.dart';

class RangoPuntuacion extends Equatable {
  final double min;
  final double max;
  final double puntos;

  const RangoPuntuacion({
    required this.min,
    required this.max,
    required this.puntos,
  });

  factory RangoPuntuacion.fromMap(Map<String, dynamic> map) {
    return RangoPuntuacion(
      min: (map['min'] as num).toDouble(),
      max: (map['max'] as num).toDouble(),
      puntos: (map['score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'min': min, 'max': max, 'score': puntos};
  }

  @override
  List<Object?> get props => [min, max, puntos];
}
