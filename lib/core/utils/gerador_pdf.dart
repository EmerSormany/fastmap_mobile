import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:latlong2/latlong.dart';
import 'package:utm/utm.dart';
import '../models/terreno_model.dart';

class GeradorPdf {
  /// Gera e compartilha o PDF recebendo os dados do terreno e as "fotos" (prints) dos mapas da tela
  static Future<void> gerarRelatorio({
    required TerrenoModel terreno,
    required Uint8List mapaBytes,
    required Uint8List croquiBytes,
  }) async {
    final pdf = pw.Document();

    // 1. Cálculos Matemáticos (Área, Perímetro, UTM)
    final distance = const Distance();
    final pontos = terreno.pontos;
    final utmPoints = pontos.map((p) => UTM.fromLatLon(lat: p.latitude, lon: p.longitude)).toList();

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

    double perimetro = 0;
    for (int i = 0; i < pontos.length; i++) {
      int next = (i + 1) % pontos.length;
      perimetro += distance.distance(pontos[i], pontos[next]);
    }

    // 2. Preparação das Imagens capturadas da tela
    final mapImage = pw.MemoryImage(mapaBytes);
    final croquiImage = pw.MemoryImage(croquiBytes);

    // 3. Construção das Páginas do PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // CABEÇALHO
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('RELATÓRIO TOPOGRÁFICO', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
                  pw.Text('FastMap', style: pw.TextStyle(fontSize: 18, color: PdfColors.grey600)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // DADOS DO PROJETO E RESUMO LADO A LADO
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('DADOS DO PROJETO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
                      pw.Divider(),
                      _buildInfoRow('Projeto:', terreno.nomeProjeto),
                      _buildInfoRow('Proprietário:', terreno.proprietario),
                      _buildInfoRow('Telefone:', terreno.telefone),
                      _buildInfoRow('Localidade:', '${terreno.cidade} - ${terreno.uf}'),
                      _buildInfoRow('Bairro:', terreno.bairro),
                    ],
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('MEMORIAL DESCRITIVO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
                      pw.Divider(),
                      _buildInfoRow('Área Total:', '${area.toStringAsFixed(2)} m²'),
                      _buildInfoRow('Hectares:', '${hectares.toStringAsFixed(4)} ha'),
                      _buildInfoRow('Perímetro:', '${perimetro.toStringAsFixed(2)} m'),
                      _buildInfoRow('Vértices:', '${pontos.length} pontos'),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // IMAGENS (MAPA E CROQUI)
            pw.Text('REPRESENTAÇÃO GRÁFICA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      pw.Text('Mapa de Localização (Satélite)', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 5),
                      pw.Container(
                        height: 200,
                        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
                        child: pw.Image(mapImage, fit: pw.BoxFit.cover),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      pw.Text('Croqui Geométrico', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 5),
                      pw.Container(
                        height: 200,
                        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
                        child: pw.Image(croquiImage, fit: pw.BoxFit.contain),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // TABELA DE COORDENADAS
            pw.Text('COORDENADAS DOS VÉRTICES (WGS 84 / UTM)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
              cellAlignment: pw.Alignment.center,
              data: [
                ['Ponto', 'Latitude', 'Longitude', 'UTM Easting (X)', 'UTM Northing (Y)', 'Zona'],
                ...pontos.asMap().entries.map((entry) {
                  int idx = entry.key + 1;
                  LatLng latLng = entry.value;
                  final utm = utmPoints[entry.key];
                  final String hemisferio = latLng.latitude >= 0 ? 'N' : 'S';
                  
                  return [
                    'P$idx',
                    latLng.latitude.toStringAsFixed(6),
                    latLng.longitude.toStringAsFixed(6),
                    utm.easting.toStringAsFixed(2),
                    utm.northing.toStringAsFixed(2),
                    '${utm.zone}$hemisferio',
                  ];
                }),
              ],
            ),
            pw.SizedBox(height: 50),

            pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Column(
                children: [
                  pw.Container(width: 250, height: 1, color: PdfColors.black),
                  pw.SizedBox(height: 5),
                  pw.Text('Assinatura do Técnico Responsável', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('CREA/CAU: _______________________', style: const pw.TextStyle(color: PdfColors.grey)),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // 4. Compartilha / Imprime o PDF nativamente
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Relatorio_${terreno.nomeProjeto.replaceAll(' ', '_')}.pdf',
    );
  }

  // Helper para criar as linhas de texto
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
          pw.SizedBox(width: 5),
          pw.Text(value),
        ],
      ),
    );
  }
}