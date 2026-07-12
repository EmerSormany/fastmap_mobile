import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../polygon/poligono_view_screen.dart';
import '../../../core/models/terreno_model.dart';

class ColetaMapaScreen extends StatefulWidget {
  final TerrenoModel terreno;
  const ColetaMapaScreen({super.key, required this.terreno});

  @override
  State<ColetaMapaScreen> createState() => _ColetaMapaScreenState();
}

class _ColetaMapaScreenState extends State<ColetaMapaScreen> {
  List<LatLng> _pontosColetados = [];
  LatLng? _localizacaoAtual;

  double? _precisaoEmMetros = double.infinity; // variável para precisão do GPS
  final double _precisaoMinimaAceitavel = 10.0; 

  final MapController _mapController = MapController();
  bool _carregandoMapa = true;
  bool _isSatellite = false;
  int? _pontoSelecionado;

  @override
  void initState() {
    super.initState();
    _iniciarGeolocalizacao();
  }

  Future<void> _iniciarGeolocalizacao() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Os serviços de localização estão desativados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('As permissões de localização foram negadas');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permissões permanentemente negadas.');
    }

    // Pega a posição com melhor precisão possível do gps do dispotivo
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    setState(() {
      _localizacaoAtual = LatLng(position.latitude, position.longitude);
      _precisaoEmMetros = position.accuracy;
      _carregandoMapa = false;
    });

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1, // Atualiza a cada 1 metros para ser mais suave
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _localizacaoAtual = LatLng(position.latitude, position.longitude);
          _precisaoEmMetros =
              position.accuracy; // atualiza a precisão em tempo real
        });
      }
    });
  }

  void _coletarPontoAtual() {
    if (_localizacaoAtual != null) {
      setState(() {
        _pontosColetados.add(_localizacaoAtual!);
      });
    }
  }

  void _desfazerUltimoPonto() {
    if (_pontosColetados.isNotEmpty) {
      setState(() {
        _pontosColetados.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool precisaoBoa =
        _precisaoEmMetros! <=
        _precisaoMinimaAceitavel; // Verifica se o sinal é confiável

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Coleta de Pontos: ${widget.terreno.nomeProjeto}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: _carregandoMapa
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Buscando sinal de GPS...'),
                ],
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _localizacaoAtual!,
                    initialZoom: 18.0,
                    maxZoom: 18,
                    onTap: (_, __) => setState(() => _pontoSelecionado = null),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _isSatellite
                          ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                          : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.fastmap.mobile',
                    ),

                    if (_pontosColetados.isNotEmpty)
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: _pontosColetados,
                            color: Colors.teal.withOpacity(0.3),
                            borderColor: Colors.teal,
                            borderStrokeWidth: 3.0,
                          ),
                        ],
                      ),

                    MarkerLayer(
                      markers: [
                        ..._pontosColetados.asMap().entries.map((entry) {
                          int index = entry.key;
                          LatLng ponto = entry.value;

                          return Marker(
                            point: ponto,
                            width: 80,
                            height: 80,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _pontoSelecionado = _pontoSelecionado == index
                                      ? null
                                      : index;
                                });
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(
                                    Icons.my_location,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  if (_pontoSelecionado == index)
                                    Positioned(
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black87,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Ponto ${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),

                        // Bolinha azul fixa simbolizando o usuário
                        Marker(
                          point: _localizacaoAtual!,
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: const Center(
                              child: Icon(
                                Icons.my_location,
                                color: Colors.blueAccent,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Marcardor de precisã odo gps
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: precisaoBoa
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          precisaoBoa
                              ? Icons.satellite_alt
                              : Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Precisão: ± ${_precisaoEmMetros?.toStringAsFixed(1)}m',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Cnetralizar o usuário
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'btnCenter',
                    backgroundColor: Colors.white,
                    onPressed: () {
                      if (_localizacaoAtual != null) {
                        _mapController.move(_localizacaoAtual!, 18.0);
                      }
                    },
                    child: const Icon(Icons.my_location, color: Colors.black87),
                  ),
                ),

                // Botão de Satélite adicionado novamente
                Positioned(
                  top: 70,
                  right: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'btnSatellite',
                    backgroundColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        _isSatellite = !_isSatellite;
                      });
                    },
                    child: Icon(
                      _isSatellite ? Icons.map : Icons.satellite_alt,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

      // Barra de botões inferior
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: _desfazerUltimoPonto,
                    tooltip: 'Desfazer',
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text('COLETAR PONTO'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _localizacaoAtual == null
                        ? null
                        : _coletarPontoAtual,
                  ),
                  FloatingActionButton.small(
                    heroTag: 'btnSalvar',
                    backgroundColor: _pontosColetados.length >= 3
                        ? Colors.green
                        : Colors.grey,
                    onPressed: _pontosColetados.length < 3
                        ? null
                        : () {
                            widget.terreno.pontos = _pontosColetados;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PoligonoViewScreen(
                                  pontos: _pontosColetados,
                                ),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Terreno fechado com sucesso!'),
                              ),
                            );
                          },
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                ],
              ),

              if (_pontosColetados.length < 3)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Caminhe e colete pelo menos 3 pontos para fechar a área.',
                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
