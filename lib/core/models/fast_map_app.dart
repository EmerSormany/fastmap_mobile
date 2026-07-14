import 'package:flutter/material.dart';
import '../../features/form/formulario_login_screen.dart';
import 'package:fastmap_mobile/features/tela_inicial_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      home: const AuthGate() 
    );
  }
}


// controle de sessão
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder ouve o "rádio" do Supabase em tempo real
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Enquanto o Flutter está checando o armazenamento local do celular, mostra um carregamento
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.teal)),
          );
        }

        final session = snapshot.data?.session;

        if (session != null) {
          return const HomeScreen(); // Redireciona para a sua tela inicial com a lista de projetos
        } 
        else {
          return const FormularioLoginScreen(); // Rediriociona para tela login
        }
      },
    );
  }
}