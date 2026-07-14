import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/terreno_model.dart';
import '../../map/coleta_mapa_screen.dart';

class FormularioTerrenoController {
  
  // Função 1: Apenas atualiza os dados textuais no banco e volta pra Home
  Future<bool> atualizarApenasDados(BuildContext context, TerrenoModel terrenoAtualizado) async {
    try {
      // Faz o update no Supabase
      await Supabase.instance.client
          .from('projetos')
          .update(terrenoAtualizado.toMap())
          .eq('id', terrenoAtualizado.id!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados atualizados com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Volta para a HomeScreen
      }
      return true; // Retorna sucesso
    } catch (e) {
      debugPrint('Erro ao atualizar: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar. Tente novamente.'), backgroundColor: Colors.red),
        );
      }
      return false; // Retorna falha
    }
  }

  // Função 2: Segue para a tela do Mapa
  void irParaMapa(BuildContext context, TerrenoModel terrenoAtual) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ColetaMapaScreen(terreno: terrenoAtual),
      ),
    );
  }
}