import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../formulario_login_screen.dart';

class CadastroController {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> cadastrarUsuario({
    required BuildContext context,
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      // Mostra o loading na tela
      _showLoading(context);

      // Envia os dados para o Supabase
      final AuthResponse res = await _client.auth.signUp(
        email: email.trim(),
        password: senha.trim(),
        data: {'display_name': nome.trim()},
      );

      // Fecha o indicador de carregamento
      if (context.mounted) Navigator.pop(context);

      if (res.user != null && context.mounted) {
        _showSnackBar(
          context,
          'Cadastro realizado com sucesso!',
          Colors.green.shade700,
        );

        // Redireciona para o Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const FormularioLoginScreen(),
          ),
        );
      }
    } on AuthException catch (e) {
      if (context.mounted) Navigator.pop(context); // Fecha loading

      final mensagem = _tratarErroSupabase(e);
      if (context.mounted)
        _showSnackBar(context, mensagem, Colors.red.shade800);
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Fecha loading
      if (context.mounted) {
        _showSnackBar(
          context,
          'Sem conexão com a internet. Verifique seu sinal.',
          Colors.red.shade800,
        );
      }
    }
  }

  String _tratarErroSupabase(AuthException e) {
    final erro = e.message.toLowerCase();
    if (erro.contains('already registered') ||
        erro.contains('already exists') ||
        e.statusCode == '422') {
      return 'Este e-mail já está cadastrado. Tente outro ou faça login.';
    } else if (erro.contains('invalid email') || erro.contains('bad email')) {
      return 'O formato do e-mail digitado não é válido.';
    } else if (erro.contains('password') && erro.contains('weak')) {
      return 'Senha muito fraca. Tente misturar letras e números.';
    }
    return 'Não foi possível criar sua conta agora. Tente novamente.';
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
