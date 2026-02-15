import '../entities/scoring_range.dart';

/// Lógica pura de puntuación para ejercicios
class LogicaPuntuacion {
  /// Calcula la puntuación dada una tabla y un valor (tiempo, distancia, repeticiones)

  static double calcularPuntuacion({
    required double valor,
    required List<RangoPuntuacion> tabla,
  }) {
    for (final rango in tabla) {
      if (valor >= rango.min && valor <= rango.max) {
        return rango.puntos;
      }
    }

    // Si no se encuentra en ningún rango, retornar 0
    return 0.0;
  }

  /// Calcula la puntuación y retorna información adicional
  static ResultadoPuntuacion calcularPuntuacionDetallada({
    required double valor,
    required List<RangoPuntuacion> tabla,
  }) {
    for (final rango in tabla) {
      if (valor >= rango.min && valor <= rango.max) {
        return ResultadoPuntuacion(
          puntos: rango.puntos,
          rangoEncontrado: rango,
          valorValido: true,
        );
      }
    }

    return ResultadoPuntuacion(
      puntos: 0.0,
      rangoEncontrado: null,
      valorValido: false,
    );
  }

  /// Formatea el tiempo en segundos a formato legible (MM:SS)
  static String formatearTiempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segs = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segs.toString().padLeft(2, '0')}';
  }

  /// Convierte formato MM:SS a segundos totales
  static int parsearTiempo(String tiempo) {
    final partes = tiempo.split(':');
    if (partes.length != 2) {
      throw FormatException('Formato de tiempo inválido. Use MM:SS');
    }
    final minutos = int.parse(partes[0]);
    final segundos = int.parse(partes[1]);
    return minutos * 60 + segundos;
  }
}

/// Resultado detallado de una puntuación
class ResultadoPuntuacion {
  final double puntos;
  final RangoPuntuacion? rangoEncontrado;
  final bool valorValido;

  ResultadoPuntuacion({
    required this.puntos,
    required this.rangoEncontrado,
    required this.valorValido,
  });
}
