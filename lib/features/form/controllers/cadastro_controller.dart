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
    required String cpf,
  }) async {
    try {
      _showLoading(context);

      // Limpa o CPF para buscar apenas números brutos
      final cpfLimpo = cpf.replaceAll(RegExp(r'[^\d]'), '');

      // 1. VERIFICAÇÃO DE CPF DUPLICADO (Direto na tabela 'perfis')
      final cpfJaCadastrado = await _checarCpfDuplicado(cpfLimpo);

      if (cpfJaCadastrado) {
        if (context.mounted) Navigator.pop(context); // Fecha o loading
        if (context.mounted) {
          _showSnackBar(
            context,
            'Este CPF já está vinculado a outra conta.',
            Colors.red.shade800,
          );
        }
        return; // Para a execução aqui e não deixa cadastrar!
      }

      // 2. SE O CPF NÃO EXISTIR, PROSEGUE COM O CADASTRO NORMAL
      final AuthResponse res = await _client.auth.signUp(
        email: email.trim(),
        password: senha.trim(),
        data: {'display_name': nome.trim(), 'cpf': cpfLimpo},
      );

      if (context.mounted) Navigator.pop(context);

      if (res.user != null && context.mounted) {
        _showSnackBar(
          context,
          'Cadastro realizado com sucesso!',
          Colors.green.shade700,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const FormularioLoginScreen(),
          ),
        );
      }
    } on AuthException catch (e) {
      if (context.mounted) Navigator.pop(context);
      final mensagem = _tratarErroSupabase(e);
      if (context.mounted) {
        _showSnackBar(context, mensagem, Colors.red.shade800);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        _showSnackBar(
          context,
          'Erro ao validar dados. Detalhe: $e',
          Colors.red.shade800,
        );
      }
    }
  }

  // Função auxiliar para checar duplicidade na tabela pública de usuários/perfis
  Future<bool> _checarCpfDuplicado(String cpf) async {
    try {
      final resposta = await _client
          .from('perfis')
          .select('cpf')
          .eq('cpf', cpf)
          .maybeSingle();

      return resposta != null;
    } catch (_) {
      return false;
    }
  }

  String _tratarErroSupabase(AuthException e) {
    final erro = e.message.toLowerCase();

    // O Supabase retorna "database error saving new user" quando o trigger falha (CPF Duplicado)
    if (erro.contains('already registered') ||
        erro.contains('already exists') ||
        erro.contains('database error') ||
        erro.contains('unexpected_failure') ||
        e.statusCode == '422') {
      return 'E-mail ou CPF já cadastrados. Tente fazer login.';
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
