import 'package:fastmap_mobile/features/tela_inicial_screen.dart';
import 'package:flutter/material.dart';
import '../constants/environment.dart';
import '../../features/form/formulario_cadastro_screen.dart';
import '../../features/form/formulario_login_screen.dart';

class FastMapApp extends StatelessWidget {
  const FastMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String telaInicial = Environment.telaInicial;

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
      home: telaInicial == 'cadastro' 
          ? const CadastroTerrenoScreen() 
          : const HomeScreen(), 
    );
  }
}