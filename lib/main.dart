import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:votacionesappg14/firebase_options.dart';
import 'package:votacionesappg14/features/tactical/presentation/pages/process_selection_screen.dart';
import 'package:votacionesappg14/features/tactical/data/scripts/seed_data.dart';
import 'package:votacionesappg14/features/tactical/data/services/firestore_service.dart';

/// 🚀 PUNTO DE ENTRADA DE LA APLICACIÓN
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Entrenamiento PNP/FFAA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      home: const PantallaInicio(),
    );
  }
}

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({Key? key}) : super(key: key);

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  bool _datosCargados = false;
  bool _verificandoDatos = true;

  @override
  void initState() {
    super.initState();
    _verificarDatosExistentes();
  }

  /// Verifica si ya existen datos en Firestore
  Future<void> _verificarDatosExistentes() async {
    try {
      final servicio = ServicioFirestore();
      final procesos = await servicio.obtenerProcesos();
      setState(() {
        _datosCargados = procesos.isNotEmpty;
        _verificandoDatos = false;
      });
    } catch (e) {
      setState(() {
        _verificandoDatos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_verificandoDatos) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Entrenamiento militar'), elevation: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono principal
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Sistema de Entrenamiento  PNP/FFAA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Entrena para tu examen de admisión',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),

              // Botón: Cargar Datos (solo si NO existen)
              if (!_datosCargados)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _cargarDatosSemilla(context);
                      setState(() {
                        _datosCargados = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text(
                      'Cargar Datos de Prueba',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (!_datosCargados) const SizedBox(height: 16),

              // Botón: Ir a Entrenamiento
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _irAEntrenamiento(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'Ir a Entrenamiento',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              if (_datosCargados)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Datos listos',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cargarDatosSemilla(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final datosSemilla = DatosSemilla();
      await datosSemilla.ejecutar();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Datos cargados correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _irAEntrenamiento(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PantallaSeleccionProceso(
          userId: 'demo_user',
          tipoUsuario: 'POSTULANTE',
          subtipoUsuario: null,
          genero: 'M',
        ),
      ),
    );
  }
}
