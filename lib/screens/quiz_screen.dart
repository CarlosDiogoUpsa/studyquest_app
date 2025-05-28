import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quizzes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tus Quizzes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Lista de quizzes o tarjetas que representan cada quiz
            ListView.builder(
              shrinkWrap: true,
              itemCount: 5, // Esto debería ser el número de quizzes disponibles
              itemBuilder: (ctx, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    title: Text('Quiz ${index + 1}'),
                    subtitle: const Text('Fecha: 01/01/2025'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Aquí se podría navegar a una pantalla de detalles del quiz
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => QuizDetailScreen(quizIndex: index),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Botón para añadir un nuevo quiz
            ElevatedButton(
              onPressed: () {
                // Lógica para añadir un nuevo quiz
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Añadir Quiz'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Nombre del Quiz',
                            ),
                          ),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Fecha de examen',
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                            ); // Cerrar el diálogo sin añadir quiz
                          },
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Lógica para añadir el quiz, como actualizar una base de datos o el estado
                            print('Quiz añadido');
                            Navigator.pop(context);
                          },
                          child: const Text('Añadir Quiz'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Añadir Nuevo Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizDetailScreen extends StatelessWidget {
  final int quizIndex;

  const QuizDetailScreen({super.key, required this.quizIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz ${quizIndex + 1} Detalles')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Detalles del Quiz ${quizIndex + 1}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Descripción del Quiz'),
            const SizedBox(height: 20),
            // Aquí podrías incluir más detalles del quiz
            ElevatedButton(
              onPressed: () {
                // Lógica para empezar el quiz, por ejemplo, navegar a la pantalla del quiz real
                print('Empezar Quiz');
              },
              child: const Text('Empezar Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
