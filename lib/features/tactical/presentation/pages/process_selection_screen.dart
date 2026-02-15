import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/firestore_service.dart';
import '../../domain/entities/training_process.dart';
import '../bloc/training_bloc.dart';
import 'runner_screen.dart';

/// Pantalla de selección de proceso de entrenamiento
class PantallaSeleccionProceso extends StatefulWidget {
  final String userId;
  final String tipoUsuario;
  final String? subtipoUsuario;
  final String genero;

  const PantallaSeleccionProceso({
    Key? key,
    required this.userId,
    required this.tipoUsuario,
    this.subtipoUsuario,
    required this.genero,
  }) : super(key: key);

  @override
  State<PantallaSeleccionProceso> createState() =>
      _PantallaSeleccionProcesoState();
}

class _PantallaSeleccionProcesoState extends State<PantallaSeleccionProceso> {
  late ServicioFirestore _servicio;
  List<ProcesoEntrenamiento>? _procesos;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _servicio = ServicioFirestore();
    _cargarProcesos();
  }

  Future<void> _cargarProcesos() async {
    try {
      final procesos = await _servicio.obtenerProcesosPorTipo(
        tipoUsuario: widget.tipoUsuario,
        subtipoUsuario: widget.subtipoUsuario,
      );
      setState(() {
        _procesos = procesos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar procesos: $e')));
      }
    }
  }

  void _seleccionarProceso(ProcesoEntrenamiento proceso) async {
    try {
      // Obtener ejercicios del proceso
      final ejercicios = await _servicio.obtenerEjercicios(proceso.id);

      if (ejercicios.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Este proceso no tiene ejercicios disponibles'),
            ),
          );
        }
        return;
      }

      // Por ahora, seleccionar el primer ejercicio
      final ejercicio = ejercicios.first;

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) =>
                  BlocEntrenamiento(servicioFirestore: _servicio),
              child: PantallaCorreedor(
                processId: proceso.id,
                exerciseId: ejercicio.id,
                userId: widget.userId,
                genero: widget.genero,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu Proceso'),
        backgroundColor: Colors.teal,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _procesos == null || _procesos!.isEmpty
          ? const Center(
              child: Text(
                'No hay procesos disponibles para tu perfil',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _procesos!.length,
              itemBuilder: (context, index) {
                final proceso = _procesos![index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Text(
                        proceso.institucion.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      proceso.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${proceso.institucion} - ${proceso.tipoObjetivo}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _seleccionarProceso(proceso),
                  ),
                );
              },
            ),
    );
  }
}
