import 'package:flutter/material.dart';
import '../../core/widgets/grid_painter.dart';
// Importamos a tela 3 para navegação
import '../polygon/poligono_view_screen.dart';

class ColetaMapaScreen extends StatefulWidget {
  final String nomeProjeto; // Recebe o dado da Tela 1
  const ColetaMapaScreen({super.key, required this.nomeProjeto});

  @override
  State<ColetaMapaScreen> createState() => _ColetaMapaScreenState();
}

class _ColetaMapaScreenState extends State<ColetaMapaScreen> {
  List<Offset> pontos = [];

  void _adicionarPonto(TapUpDetails details) {
    setState(() {
      pontos.add(details.localPosition);
    });
  }

  void _desfazerUltimoPonto() {
    if (pontos.isNotEmpty) {
      setState(() {
        pontos.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coleta: ${widget.nomeProjeto}', style: const TextStyle(fontSize: 16)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.amber.shade100,
            width: double.infinity,
            child: const Text(
              '📍 Toque na área quadriculada para marcar os vértices do terreno.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTapUp: _adicionarPonto,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size.infinite,
                    painter: GridPainter(pontos: pontos, fecharPoligono: false),
                  ),
                  const Center(
                    child: Icon(Icons.navigation, color: Colors.blue, size: 32),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: _desfazerUltimoPonto,
                  tooltip: 'Desfazer último',
                ),
                FloatingActionButton.extended(
                  heroTag: 'btnSalvar',
                  icon: const Icon(Icons.check),
                  label: const Text('SALVAR POLÍGONO'),
                  onPressed: pontos.length < 3
                      ? null 
                      : () {
                          // LÓGICA DE NAVEGAÇÃO: Vai para a Tela 3 enviando a lista de pontos
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PoligonoViewScreen(pontos: pontos),
                            ),
                          );
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}