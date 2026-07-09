import 'package:flutter/material.dart';
// Importamos a tela 2 para poder navegar até ela
import '../map/coleta_mapa_screen.dart';

class FormularioTerrenoScreen extends StatefulWidget {
  const FormularioTerrenoScreen({super.key});

  @override
  State<FormularioTerrenoScreen> createState() => _FormularioTerrenoScreenState();
}

class _FormularioTerrenoScreenState extends State<FormularioTerrenoScreen> {
  final _formKey = GlobalKey<FormState>();
  String nomeProjeto = '';
  String proprietario = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Projeto', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.map_outlined, size: 80, color: Colors.teal),
              const SizedBox(height: 24),
              Text(
                'Informações do Terreno',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nome do Projeto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.folder),
                ),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                onSaved: (value) => nomeProjeto = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Proprietário',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                onSaved: (value) => proprietario = value!,
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('INICIAR MAPEAMENTO'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    
                    // LÓGICA DE NAVEGAÇÃO: Vai para a Tela 2 e envia o 'nomeProjeto'
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ColetaMapaScreen(
                          nomeProjeto: nomeProjeto,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}