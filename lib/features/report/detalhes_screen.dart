import 'package:fastmap_mobile/core/utils/croqui_pintos.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:utm/utm.dart';
import '../../../core/models/terreno_model.dart';
import 'package:flutter_map/flutter_map.dart';

class DetalhesScreen extends StatelessWidget {
  final TerrenoModel terreno; // Recebe o modelo completo em vez de apenas os pontos

  const DetalhesScreen({super.key, required this.terreno});

  @override
  Widget build(BuildContext context) {
    final pontos = terreno.pontos;
    final distance = const Distance();

    // Converter todas as Lat/Lng para UTM
    final utmPoints = pontos.map((p) => UTM.fromLatLon(lat: p.latitude, lon: p.longitude)).toList();

    // Calcular Área Exata 
    double area = 0;
    if (utmPoints.length >= 3) {
      for (int i = 0; i < utmPoints.length; i++) {
        int next = (i + 1) % utmPoints.length;
        area += (utmPoints[i].easting * utmPoints[next].northing) -
                (utmPoints[next].easting * utmPoints[i].northing);
      }
      area = (area.abs() / 2.0);
    }
    double hectares = area / 10000;

    // Calcular Distâncias dos Segmentos e o Perímetro
    double perimetro = 0;
    List<Widget> listaSegmentos = [];
    
    for (int i = 0; i < pontos.length; i++) {
      int next = (i + 1) % pontos.length;
      double dist = distance.distance(pontos[i], pontos[next]);
      perimetro += dist;

      listaSegmentos.add(
        ListTile(
          dense: true,
          leading: const Icon(Icons.linear_scale, color: Colors.teal),
          title: Text('Segmento P${i + 1} ➔ P${next + 1}'),
          trailing: Text('${dist.toStringAsFixed(2)} m', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Croqui e Dados Técnicos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // cabeçalho do do terreno
          Card(
            color: Colors.white,
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.person_pin, color: Colors.teal),
                      SizedBox(width: 8),
                      Text('DADOS DO PROJETO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const Divider(),
                  _buildInfoRow('Projeto:', terreno.nomeProjeto),
                  _buildInfoRow('Proprietário:', terreno.proprietario),
                  _buildInfoRow('Localidade:', '${terreno.cidade} - ${terreno.uf}'),
                  _buildInfoRow('Bairro/Sítio:', terreno.bairro),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // áreas em hectare, metros quadrados e perímetro
          Card(
            elevation: 3,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('MEMORIAL DESCRITIVO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.square_foot),
                    title: const Text('Área Total'),
                    trailing: Text('${area.toStringAsFixed(2)} m²', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.landscape),
                    title: const Text('Área em Hectares'),
                    trailing: Text('${hectares.toStringAsFixed(4)} ha', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.timeline),
                    title: const Text('Perímetro Total'),
                    trailing: Text('${perimetro.toStringAsFixed(2)} m', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // segmentos entre cada ponto
          Card(
            color: Colors.white,
            elevation: 3,
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile( 
              title: const Text('Distâncias entre Pontos', style: TextStyle(fontWeight: FontWeight.bold)),
              leading: const Icon(Icons.straighten),
              shape: const Border(),
              collapsedShape: const Border(),
              children: listaSegmentos,
            ),
          ),
          const SizedBox(height: 16),

          // lista de coordenadas lat long e utm x e utm y
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text('COORDENADAS DOS VÉRTICES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ...pontos.asMap().entries.map((entry) {
            int idx = entry.key + 1;
            LatLng latLng = entry.value;
            final utm = utmPoints[entry.key];

            // Verifica o hemisfério usando a latitude
            final String hemisferio = latLng.latitude >= 0 ? 'N' : 'S';
            
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(backgroundColor: Colors.teal, child: Text('P$idx', style: const TextStyle(color: Colors.white))),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Lat: ${latLng.latitude.toStringAsFixed(6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Lng: ${latLng.longitude.toStringAsFixed(6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Text('UTM X (Easting): ${utm.easting.toStringAsFixed(2)} m', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    Text('UTM Y (Northing): ${utm.northing.toStringAsFixed(2)} m', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    Text('Zona: ${utm.zone}$hemisferio', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  ],
                ),
              ),
            );
          }),

          // polígono do terreno (croqui)
          Card(
            color: Colors.white,
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('CROQUI DO TERRENO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    // Pintor Matemático que usa o UTM para desenho perfeitamente proporcional
                    child: CustomPaint(
                      painter: CroquiPainter(utmPoints: utmPoints),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // mapa estático para ser impresso no documento pdf
          Card(
            color: Colors.white,
            elevation: 3,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('MAPA DE LOCALIZAÇÃO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const Divider(height: 1),
                SizedBox(
                  height: 250,
                  // IgnorePointer bloqueia o toque para agir como uma imagem impressa (print)
                  child: IgnorePointer(
                    child: FlutterMap(
                      options: MapOptions(
                        maxZoom: 18,
                        // O CameraFit.bounds garante que o mapa foque perfeitamente nos pontos simulando o zoom ideal
                        initialCameraFit: CameraFit.bounds(
                          bounds: LatLngBounds.fromPoints(pontos),
                          padding: const EdgeInsets.all(40.0),
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                          userAgentPackageName: 'com.fastmap.mobile',
                        ),
                        PolygonLayer(
                          polygons: [
                            Polygon(
                              points: pontos,
                              color: Colors.teal.withOpacity(0.3),
                              borderColor: Colors.teal,
                              borderStrokeWidth: 3.0,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: pontos.asMap().entries.map((entry) {
                            return Marker(
                              point: entry.value,
                              width: 30,
                              height: 30,
                              alignment: Alignment.topCenter,
                              child: const Icon(Icons.location_on, color: Colors.red, size: 30),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // assinatura do tecnoco
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                Container(height: 1.5, color: Colors.black87),
                const SizedBox(height: 8),
                const Text(
                  'Assinatura do Técnico Responsável',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'CREA/CAU: _______________________',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),

      // botão de gerar pdf
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('GERAR CROQUI EM PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // TODO: Implementar a geração real do PDF nas próximas etapas
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Preparando geração do PDF... Em breve!'),
                  backgroundColor: Colors.teal,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Função auxiliar (Widget) para criar as linhas de texto do proprietário
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}