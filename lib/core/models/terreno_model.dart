import 'package:latlong2/latlong.dart';

class TerrenoModel {
  String? id;
  String nomeProjeto;
  String proprietario;
  String cidade;
  String uf;
  String bairro;
  String numero;
  String telefone;

  // lista de pontos preparada para receber as coordenadas
  List<LatLng> pontos;

  TerrenoModel({
    this.id,
    required this.nomeProjeto,
    required this.proprietario,
    required this.cidade,
    required this.uf,
    required this.bairro,
    required this.numero,
    required this.telefone,

    this.pontos = const [], // inicializa vazia
  });

  // transofrma dados supabase em objeto flutter
  factory TerrenoModel.fromMap(Map<String, dynamic> map) {
    String enderecoCompleto = map['endereco'];
    List<String> enderecoPartes = enderecoCompleto.split(',');

    String cidade = enderecoPartes[0].trim();
    String uf = enderecoPartes[1].trim();
    String bairro = enderecoPartes[2].trim();
    String numero = enderecoPartes[3].trim();

    // Tratamento da lista de pontos
    List<LatLng> pontosExtraidos = [];
    if (map['pontos'] != null) {
      final List<dynamic> pontosLista = map['pontos'];
      pontosExtraidos = pontosLista
          .map((p) => LatLng(p['lat'], p['lng']))
          .toList();
    }

    return TerrenoModel(
      id: map['id'].toString(),
      nomeProjeto: map['nome_projeto'],
      proprietario: map['proprietario'],
      telefone: map['telefone'],
      cidade: cidade,
      bairro: bairro,
      uf: uf,
      numero: numero,
      pontos: pontosExtraidos,
    );
  }

  // transforma objeto flutter em dados supabase
  Map<String, dynamic> toMap() {
    String numFormatado = numero.trim().isEmpty ? 'sem número' : numero.trim();

    String enderecoUnificado =
        '${cidade.trim()}, ${uf.trim()}, ${bairro.trim()}, $numFormatado';

    return {
      'nome_projeto': nomeProjeto,
      'proprietario': proprietario,
      'endereco': enderecoUnificado,
      'telefone': telefone,
      'pontos': pontos
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(), // trasnforma lista flutter em array de com
    };
  }
}
