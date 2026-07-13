import 'package:fastmap_mobile/features/form/formulario_terreno_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/terreno_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = Supabase.instance.client;
  List<TerrenoModel> _projetos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _buscarProjetos();
  }

  // Função que vai na nuvem buscar os dados da tabela 'projetos'
  Future<void> _buscarProjetos() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase.from('projetos').select().order('id', ascending: false);
      
      setState(() {
        _projetos = response.map((item) => TerrenoModel.fromMap(item)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao buscar projetos: $e');
      setState(() => _isLoading = false);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar os projetos. Verifique a internet.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Função para deletar com caixa de confirmação
  Future<void> _deletarProjeto(String id) async {
    bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Projeto?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Deletar', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirmar) {
      try {
        await _supabase.from('projetos').delete().eq('id', id);
        _buscarProjetos(); // Recarrega a lista após deletar
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Projeto excluído com sucesso.'), backgroundColor: Colors.teal));
        }
      } catch (e) {
        debugPrint('Erro ao deletar: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Projetos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _buscarProjetos, // Botão de atualizar manual
          )
        ],
      ),
      
      body: RefreshIndicator(
        onRefresh: _buscarProjetos,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _projetos.isEmpty
                ? ListView( 
                    children: const [
                      SizedBox(height: 100),
                      Center(
                        child: Text(
                          'Nenhum projeto encontrado.\nToque no + para criar o primeiro!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _projetos.length,
                    itemBuilder: (context, index) {
                      final projeto = _projetos[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade100,
                            child: const Icon(Icons.map, color: Colors.teal),
                          ),
                          title: Text(projeto.nomeProjeto, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${projeto.proprietario}\n${projeto.cidade} - ${projeto.uf}'),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _deletarProjeto(projeto.id!),
                          ),
                          onTap: () async {
                            // Ao clicar, envia o projeto para a tela de Formulário para ser Editado
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FormularioTerrenoScreen(editandoProjeto: projeto),
                              ),
                            );
                            _buscarProjetos(); // Recarrega a lista quando voltar da edição
                          },
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('NOVO PROJETO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: () async {
          // Vai para a tela de Formulário sem passar nenhum projeto (Modo Criação)
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormularioTerrenoScreen()),
          );
          _buscarProjetos(); // Recarrega a lista quando voltar
        },
      ),
    );
  }
}