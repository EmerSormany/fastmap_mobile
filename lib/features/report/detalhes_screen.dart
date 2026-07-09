import 'package:flutter/material.dart';

class DetalhesScreen extends StatelessWidget {
  final List<Offset> pontos; // Recebe os pontos da Tela 3
  const DetalhesScreen({super.key, required this.pontos});

  double calcularPerimetro() {
    double perimetro = 0;
    for (int i = 0; i < pontos.length; i++) {
      int next = (i + 1) % pontos.length;
      perimetro += (pontos[i] - pontos[next]).distance;
    }
    return perimetro * 1.5; 
  }

  double calcularArea() {
    double area = 0;
    for (int i = 0; i < pontos.length; i++) {
      int next = (i + 1) % pontos.length;
      area += (pontos[i].dx * pontos[next].dy) - (pontos[next].dx * pontos[i].dy);
    }
    return (area.abs() / 2.0) * 0.8;
  }

  @override
  Widget build(BuildContext context) {
    double area = calcularArea();
    double perimetro = calcularPerimetro();
    double hectares = area / 10000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Croqui e Dados Técnicos'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('RESUMO DO TERRENO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.square_foot),
                    title: const Text('Área Total'),
                    trailing: Text('${area.toStringAsFixed(2)} m²', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.landscape),
                    title: const Text('Hectares'),
                    trailing: Text('${hectares.toStringAsFixed(4)} ha', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.timeline),
                    title: const Text('Perímetro'),
                    trailing: Text('${perimetro.toStringAsFixed(2)} m', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('LISTA DE VÉRTICES (Simulação Lat/Lng/UTM)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...pontos.asMap().entries.map((entry) {
            int idx = entry.key + 1;
            Offset p = entry.value;
            double lat = -23.5505 + (p.dy / 10000);
            double lng = -46.6333 + (p.dx / 10000);
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text('P$idx')),
                title: Text('Lat: ${lat.toStringAsFixed(6)} \nLng: ${lng.toStringAsFixed(6)}'),
                subtitle: Text('X: ${p.dx.toStringAsFixed(1)} | Y: ${p.dy.toStringAsFixed(1)} (Coords da Tela)'),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: () {
            // LÓGICA DE NAVEGAÇÃO FINAL: Remove todas as telas da pilha e volta para a primeira
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: const Text('FINALIZAR E NOVO PROJETO'),
        ),
      ),
    );
  }
}