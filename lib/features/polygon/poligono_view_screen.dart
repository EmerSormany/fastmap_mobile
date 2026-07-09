import 'package:flutter/material.dart';
import '../../core/widgets/grid_painter.dart';
// Importamos a tela 4 para navegação final
import '../report/detalhes_screen.dart';

class PoligonoViewScreen extends StatelessWidget {
  final List<Offset> pontos; // Recebe os pontos da Tela 2
  const PoligonoViewScreen({super.key, required this.pontos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terreno Finalizado'),
      ),
      body: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: GridPainter(pontos: pontos, fecharPoligono: true),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Column(
                children: [
                  Text('N', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  Icon(Icons.explore, size: 32),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: Colors.white.withOpacity(0.8),
              child: const Row(
                children: [
                  Icon(Icons.straighten, size: 16),
                  SizedBox(width: 8),
                  Text('Escala: 1:500 (Simulada)'),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'btnDetalhes',
        onPressed: () {
          // LÓGICA DE NAVEGAÇÃO: Vai para a Tela 4 enviando os mesmos pontos
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalhesScreen(pontos: pontos),
            ),
          );
        },
        icon: const Icon(Icons.analytics),
        label: const Text('GERAR RELATÓRIO'),
      ),
    );
  }
}