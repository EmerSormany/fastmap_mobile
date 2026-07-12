import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// O import da Tela 4 está comentado para não dar erro até criarmos ela
// import '../../report/screens/detalhes_screen.dart';
import 'dart:math' as math;

class PoligonoViewScreen extends StatefulWidget {
  final List<LatLng> pontos;
  
  const PoligonoViewScreen({super.key, required this.pontos});

  @override
  State<PoligonoViewScreen> createState() => _PoligonoViewScreenState();
}

class _PoligonoViewScreenState extends State<PoligonoViewScreen> {
  bool _isSatellite = true; // Por padrão, vamos mostrar o satélite nesta tela
  final Distance _distanceCalculator = const Distance();
  String _textoEscala = "Calculando...";

  // Função que converte o zoom do mapa em metros na vida real
  void _atualizarEscala(double lat, double zoom) {
    // 156543.03392 é a circunferência do Equador dividida pelo tamanho do bloco do mapa (256)
    double metrosPorPixel = 156543.03392 * math.cos(lat * math.pi / 180) / math.pow(2, zoom);
    
    double distanciaNaBarra = metrosPorPixel * 80.0; 
    
    String texto;
    if (distanciaNaBarra >= 1000) {
      texto = '${(distanciaNaBarra / 1000).toStringAsFixed(2)} km';
    } else {
      texto = '${distanciaNaBarra.toStringAsFixed(1)} m';
    }

    // Evita loop de atualização desnecessário e atualiza a tela
    if (_textoEscala != texto && mounted) {
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _textoEscala = texto;
          });
        }
      });
    }
  }

  // calcula o ponto central entre dois vértices para desenhar a legenda da distância
  LatLng _calcularPontoMedio(LatLng p1, LatLng p2) {
    return LatLng(
      (p1.latitude + p2.latitude) / 2,
      (p1.longitude + p2.longitude) / 2,
    );
  }

  // Gera os marcadores das distâncias de cada lado do terreno
  List<Marker> _gerarMarcadoresDeSegmento() {
    List<Marker> marcadores = [];
    
    if (widget.pontos.length < 3) return marcadores;

    for (int i = 0; i < widget.pontos.length; i++) {
      // Pega o ponto atual e o próximo (se for o último, liga com o primeiro para fechar o polígono)
      int nextIndex = (i + 1) % widget.pontos.length;
      LatLng p1 = widget.pontos[i];
      LatLng p2 = widget.pontos[nextIndex];

      LatLng pontoMedio = _calcularPontoMedio(p1, p2);
      double distanciaMetros = _distanceCalculator.as(LengthUnit.Meter, p1, p2);

      marcadores.add(
        Marker(
          point: pontoMedio,
          width: 80,
          height: 30,
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal, width: 1),
            ),
            child: Center(
              child: Text(
                '${distanciaMetros.toStringAsFixed(1)} m',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.teal),
              ),
            ),
          ),
        ),
      );
    }
    return marcadores;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processamento do Terreno', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isSatellite ? Icons.map : Icons.satellite_alt),
            onPressed: () {
              setState(() {
                _isSatellite = !_isSatellite;
              });
            },
            tooltip: 'Alternar Mapa',
          ),
        ],
      ),
      body: Stack(
        children: [

          FlutterMap(
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(
                bounds: LatLngBounds.fromPoints(widget.pontos),
                padding: const EdgeInsets.all(60.0), 
              ),
              maxZoom: 18,
              onPositionChanged: (camera, hasGesture) {
                _atualizarEscala(camera.center.latitude, camera.zoom);
              },
              interactionOptions: const InteractionOptions(
                // garante que o Norte fique sempre para cima
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate, 
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _isSatellite  
                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.fastmap.mobile',
              ),
              
              // O Polígono Preenchido
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: widget.pontos,
                    color: Colors.teal.withOpacity(0.2),
                    borderColor: Colors.tealAccent,
                    borderStrokeWidth: 4.0,
                  ),
                ],
              ),

              // Marcadores de Vértices (P1, P2...) e Segmentos (Medidas em Metros)
              MarkerLayer(
                markers: [
                  // 1. As legendas de distância nas linhas
                  ..._gerarMarcadoresDeSegmento(),

                  // 2. As bolinhas indicando cada vértice com seu número
                  ...widget.pontos.asMap().entries.map((entry) {
                    int index = entry.key;
                    LatLng ponto = entry.value;
                    return Marker(
                      point: ponto,
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            'P${index + 1}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Bússola (Orientação ao Polo Norte)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('N', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
                  Icon(Icons.arrow_upward, size: 24, color: Colors.black87),
                ],
              ),
            ),
          ),

          // Indicador Visual de Escala e Resumo
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Projeção Base:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const Text('UTM / WGS 84', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(width: 40, height: 4, color: Colors.black87),
                      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black87, width: 1))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(_textoEscala, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: SafeArea(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.analytics),
            label: const Text('GERAR RELATÓRIO FINAL'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            onPressed: () {
              // TODO: Descomentar quando a Tela 4 estiver pronta
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => DetalhesScreen(pontos: widget.pontos),
              //   ),
              // );
            },
          ),
        ),
      ),
    );
  }
}