import 'package:flutter/material.dart';
import 'controllers/login_controller.dart';
import 'formulario_cadastro_screen.dart'; // Importa a tela do seu colega

class FormularioLoginScreen extends StatefulWidget {
  const FormularioLoginScreen({super.key});

  @override
  State<FormularioLoginScreen> createState() => _FormularioLoginScreenState();
}

class _FormularioLoginScreenState extends State<FormularioLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = LoginController(); // Instancia o controlador de login

  String email = '';
  String senha = '';
  bool _senhaOculta = true;

  void _onEntrarPressed() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Executa o login seguro através do controller
      _controller.logarUsuario(
        context: context,
        email: email,
        senha: senha,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 1),

                // Ícone do app seguindo a cor do projeto
                Icon(
                  Icons.location_on_rounded,
                  size: 90,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),

                // Título principal
                Text(
                  'FastMap Mobile',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  'Faça login para começar o mapeamento',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Campo de E-mail
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu e-mail';
                    }
                    if (!value.contains('@')) {
                      return 'Insira um e-mail válido';
                    }
                    return null;
                  },
                  onSaved: (value) => email = value!,
                ),
                const SizedBox(height: 16),

                // Campo de Senha
                TextFormField(
                  obscureText: _senhaOculta,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _senhaOculta ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _senhaOculta = !_senhaOculta;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                  onSaved: (value) => senha = value!,
                ),

                const Spacer(flex: 2),

                // Botão de Entrar conectado ao Controller
                ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('ENTRAR'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _onEntrarPressed,
                ),
                const SizedBox(height: 16),

                // Botão para ir para a tela de Cadastro do seu amigo
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CadastroTerrenoScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Não tem uma conta? Cadastre-se',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}