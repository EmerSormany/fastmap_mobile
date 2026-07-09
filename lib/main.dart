import 'package:flutter/material.dart';
import 'features/form/formulario_terreno_screen.dart';

void main() {
  runApp(const FastMapApp());
}

class FastMapApp extends StatelessWidget {
  const FastMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FastMap Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal.shade700,
          secondary: Colors.orange.shade600,
        ),
        useMaterial3: true,
      ),
      // A primeira tela que o app vai abrir
      home: const FormularioTerrenoScreen(), 
    );
  }
}