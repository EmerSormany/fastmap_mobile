import 'package:fastmap_mobile/features/form/controllers/formulario_terreno_controller.dart';
import 'package:flutter/material.dart';
import '../../../core/models/terreno_model.dart';

class FormularioTerrenoScreen extends StatefulWidget {
  final TerrenoModel? editandoProjeto;

  const FormularioTerrenoScreen({super.key, this.editandoProjeto});

  @override
  State<FormularioTerrenoScreen> createState() =>
      _FormularioTerrenoScreenState();
}

class _FormularioTerrenoScreenState extends State<FormularioTerrenoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = FormularioTerrenoController();

  String nomeProjeto = '';
  String proprietario = '';
  String cidade = '';
  String uf = '';
  String bairro = '';
  String numero = '';
  String telefone = '';

  bool _isSaving = false;

  // Função 1: Apenas atualiza os dados textuais no banco e volta pra Home
  Future<void> _atualizarApenasDados() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isSaving = true);

      TerrenoModel terrenoAtualizado = TerrenoModel(
        id: widget.editandoProjeto!.id,
        nomeProjeto: nomeProjeto.trim(),
        proprietario: proprietario.trim(),
        telefone: telefone.trim(),
        cidade: cidade.trim(),
        uf: uf.toUpperCase().trim(),
        bairro: bairro.trim(),
        numero: numero.trim(),
        pontos: widget.editandoProjeto!.pontos,
      );

      // chama controller do banco de dados
      await _controller.atualizarApenasDados(context, terrenoAtualizado);

      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Função 2: Segue para a tela do Mapa (seja para criar um novo ou editar os pontos de um existente)
  void _irParaMapa() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      TerrenoModel terrenoAtual = TerrenoModel(
        id: widget.editandoProjeto?.id,
        nomeProjeto: nomeProjeto.trim(),
        proprietario: proprietario.trim(),
        telefone: telefone.trim(),
        cidade: cidade.trim(),
        uf: uf.toUpperCase().trim(),
        bairro: bairro.trim(),
        numero: numero.trim(),
        pontos: widget.editandoProjeto?.pontos ?? [], // passa lista vazia se não houver pontos
      );

      // chama controller do banco de dados
      _controller.irParaMapa(context, terrenoAtual);
    }
  }

  @override
  Widget build(BuildContext context) {
    final estaEditando = widget.editandoProjeto != null;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          estaEditando ? 'Editar Projeto' : 'Novo Projeto',
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
                initialValue: widget.editandoProjeto?.nomeProjeto ?? '',
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
                initialValue: widget.editandoProjeto?.proprietario ?? '',
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

              TextFormField(
                initialValue: widget.editandoProjeto?.telefone ?? '',
                keyboardType: TextInputType.phone,

                decoration: const InputDecoration(
                  labelText: 'Telefone / WhatsApp',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),

                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
                onSaved: (value) => telefone = value!,
              ),
              const SizedBox(height: 16),

              // transformar cidade e uf em uma linha única
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: widget.editandoProjeto?.cidade ?? '',
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
                      initialValue: widget.editandoProjeto?.uf ?? '',
                      textCapitalization: TextCapitalization.characters,

                      decoration: const InputDecoration(
                        labelText: 'UF',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map),
                      ),

                      validator: (value) =>
                          value!.isEmpty ||
                              value.length !=
                                  2 // força usuário a digitar sigla
                          ? 'Sigla do estado'
                          : null,
                      onSaved: (value) => uf = value!.toLowerCase(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: widget.editandoProjeto?.bairro ?? '',
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
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: widget.editandoProjeto?.numero ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Número',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) => numero = value ?? '',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // seleciona botões de edição ou de novo projeto
              if (estaEditando) ...[
                // Botão Primário: Salvar os textos e voltar
                ElevatedButton.icon(
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),

                  label: Text(_isSaving ? 'ATUALIZANDO...' : 'ATUALIZAR DADOS'),

                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),

                  onPressed: _isSaving ? null : _atualizarApenasDados,
                ),

                const SizedBox(height: 12),

                // Botão Secundário: Continuar para alterar os pontos no mapa
                OutlinedButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text('EDITAR MAPA DO TERRENO'),

                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.teal,
                    side: const BorderSide(color: Colors.teal, width: 2),
                  ),

                  onPressed: _isSaving ? null : _irParaMapa,
                ),
              ] else ...[
                // Botão de fluxo normal para novos projetos
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('INICIAR MAPEAMENTO'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _irParaMapa,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
