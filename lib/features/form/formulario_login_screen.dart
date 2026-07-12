import 'package:flutter/material.dart';
import 'formulario_terreno_screen.dart'; // Importa a próxima tela

class FormularioLoginScreen extends StatefulWidget {
  const FormularioLoginScreen({super.key});

  @override
  State<FormularioLoginScreen> createState() => _FormularioLoginScreenState();
}

class _FormularioLoginScreenState extends State<FormularioLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String senha = '';
  bool _senhaOculta = true; // Controla se a senha aparece ou fica com bolinhas

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
                    // Botão de "olhinho" para mostrar/esconder a senha
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

                // Botão de Entrar
                ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('ENTRAR'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      // Navegação para a tela de Novo Projeto do seu colega
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FormularioTerrenoScreen(),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Botão para ir para a tela de Cadastro
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tela de cadastro em desenvolvimento...'),
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