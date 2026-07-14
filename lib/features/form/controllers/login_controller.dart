import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> logarUsuario({
    required BuildContext context,
    required String email,
    required String senha,
  }) async {
    try {
      _showLoading(context);

      // Realiza o login com e-mail e senha no Supabase
      final AuthResponse res = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: senha.trim(),
      );

      // Fecha o indicador de carregamento
      if (context.mounted) Navigator.pop(context);

      if (res.user != null && context.mounted) {
        _showSnackBar(
          context,
          'Bem-vindo ao FastMap!',
          Colors.green.shade700,
        );

      }
    } on AuthException catch (e) {
      if (context.mounted) Navigator.pop(context); // Fecha o loading

      final mensagem = _tratarErroSupabase(e);
      if (context.mounted) {
        _showSnackBar(context, mensagem, Colors.red.shade800);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Fecha o loading
      if (context.mounted) {
        _showSnackBar(
          context,
          'Erro de conexão. Verifique sua internet.',
          Colors.red.shade800,
        );
      }
    }
  }

  String _tratarErroSupabase(AuthException e) {
    final erro = e.message.toLowerCase();
    
    if (erro.contains('invalid login credentials') || 
        erro.contains('invalid credentials') ||
        e.statusCode == '400') {
      return 'E-mail ou senha incorretos. Verifique e tente novamente.';
    } else if (erro.contains('email not confirmed')) {
      return 'Por favor, confirme seu e-mail antes de acessar.';
    } else if (erro.contains('too many requests')) {
      return 'Muitas tentativas seguidas. Aguarde um momento.';
    }
    
    return 'Erro Supabase: ${e.message}';
  }

  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showSnackBar(BuildContext context, String mensagem, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}