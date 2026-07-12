import 'package:flutter/material.dart';
import 'controllers/cadastro_controller.dart';
import 'widgets/cadastro_input_field.dart';
import 'formulario_login_screen.dart';

class CadastroTerrenoScreen extends StatefulWidget {
  const CadastroTerrenoScreen({super.key});

  @override
  State<CadastroTerrenoScreen> createState() => _CadastroTerrenoScreenState();
}

class _CadastroTerrenoScreenState extends State<CadastroTerrenoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = CadastroController();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _obscureText = true;

  void _onCadastrarPressed() {
    if (_formKey.currentState!.validate()) {
      _controller.cadastrarUsuario(
        context: context,
        nome: _nomeController.text,
        email: _emailController.text,
        senha: _senhaController.text,
      );
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Criar Conta', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Icon(Icons.person_add_alt_1_outlined, size: 80, color: primaryColor),
                const SizedBox(height: 24),
                Text(
                  'Cadastro de Usuário',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text('Preencha os dados abaixo para acessar o FastMap', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),

                // Campo: Nome
                CadastroInputField(
                  controller: _nomeController,
                  label: 'Nome Completo',
                  prefixIcon: Icons.person_outline,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Por favor, insira seu nome completo' : null,
                ),
                const SizedBox(height: 16),

                // Campo: E-mail
                CadastroInputField(
                  controller: _emailController,
                  label: 'E-mail',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Por favor, insira seu e-mail';
                    if (!value.contains('@') || !value.contains('.')) return 'Insira um formato de e-mail válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo: Senha
                CadastroInputField(
                  controller: _senhaController,
                  label: 'Senha',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureText,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor, insira uma senha';
                    if (value.length < 6) return 'A senha deve ter no mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('FINALIZAR CADASTRO', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white
                  ),
                  onPressed: _onCadastrarPressed,
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const FormularioLoginScreen()
                      ),
                    );
                  },
                  child: Text('Já tenho uma conta. Entrar.', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}