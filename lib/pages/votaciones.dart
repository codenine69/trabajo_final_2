import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VotacionesPage extends StatefulWidget {
  const VotacionesPage({super.key});

  @override
  State<VotacionesPage> createState() => _VotacionesPageState();
}

class _VotacionesPageState extends State<VotacionesPage> {
  final CollectionReference _partidosRef = FirebaseFirestore.instance
      .collection('partidos');

  // Función datos de prueba
  void _seedData() async {
    QuerySnapshot snapshot = await _partidosRef.get();
    if (snapshot.docs.isEmpty) {
      for (int i = 1; i <= 5; i++) {
        await _partidosRef.add({
          'name': 'P-Politico-0$i',
          'votes': 0 + (i * 5), // Votos iniciales
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // datos automaticos
    // _seedData();
  }

  void _vote(String docId, int currentVotes, int change) {
    int newVotes = currentVotes + change;
    if (newVotes < 0) newVotes = 0; // Evitar negativos
    _partidosRef.doc(docId).update({'votes': newVotes});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FA),
      appBar: AppBar(
        title: const Text(
          "VOTACIONES",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // Botón
          IconButton(
            icon: const Icon(Icons.playlist_add),
            onPressed: _seedData,
            tooltip: 'Generar Partidos de Prueba',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _partidosRef.orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Algo salió mal'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No hay partidos registrados"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _seedData,
                    child: const Text("Crear 5 Partidos de Prueba"),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              String docId = document.id;
              String name = data['name'] ?? 'Partido';
              int votes = data['votes'] ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE), // Gris
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icono de Estrella
                    const Icon(
                      Icons.star_border, // Estrella
                      size: 60,
                      color: Colors.black87,
                      weight: 2.0,
                    ),
                    const SizedBox(width: 20),
                    // Texto Central
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "Votos: $votes",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Controles de Voto
                    Column(
                      children: [
                        InkWell(
                          onTap: () => _vote(docId, votes, 1),
                          child: const Icon(Icons.arrow_upward, size: 24),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            "$votes",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _vote(docId, votes, -1),
                          child: const Icon(Icons.arrow_downward, size: 24),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
