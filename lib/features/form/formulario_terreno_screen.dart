import 'package:flutter/material.dart';
// Importamos a tela 2 para poder navegar até ela
import '../map/coleta_mapa_screen.dart';
import '../../../core/models/terreno_model.dart';

class FormularioTerrenoScreen extends StatefulWidget {
  const FormularioTerrenoScreen({super.key});

  @override
  State<FormularioTerrenoScreen> createState() =>
      _FormularioTerrenoScreenState();
}

class _FormularioTerrenoScreenState extends State<FormularioTerrenoScreen> {
  final _formKey = GlobalKey<FormState>();

  String nomeProjeto = '';
  String proprietario = '';
  String cidade = '';
  String uf = '';
  String bairro = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Novo Projeto',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),

      body: SingleChildScrollView(
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
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome do Projeto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.folder),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
                onSaved: (value) => nomeProjeto = value!,
              ),
              const SizedBox(height: 16),

              TextFormField(
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Proprietário',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
                onSaved: (value) => proprietario = value!,
              ),
              const SizedBox(height: 16),

              // transformar cidade e uf em uma linha única
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Cidade',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo obrigatório' : null,
                      onSaved: (value) => cidade = value!,
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'UF',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map),
                      ),
                      validator: (value) =>
                          value!.isEmpty || value.length > 2 ? 'Sigla do estado' : null,
                      onSaved: (value) => uf = value!.toLowerCase(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Bairro ou Bairro Rural (Sítio)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.landscape),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
                onSaved: (value) => bairro = value!,
              ),

              const SizedBox(height: 32),

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

                    // Epacotamento das 5 variáveis inciais do terreno
                    TerrenoModel novoTerreno = TerrenoModel(
                      nomeProjeto: nomeProjeto,
                      proprietario: proprietario,
                      cidade: cidade,
                      uf: uf,
                      bairro: bairro,
                    );

                    // Enia o terreno para a próxima página e icrementa com os pontos coletados
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ColetaMapaScreen(terreno: novoTerreno),
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
