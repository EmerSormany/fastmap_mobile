import 'package:latlong2/latlong.dart';

class TerrenoModel {
  String nomeProjeto;
  String proprietario;
  String cidade;
  String uf;
  String bairro;
  
  // lista de pontos preparada para receber as coordenadas
  List<LatLng> pontos;

  TerrenoModel({
    required this.nomeProjeto,
    required this.proprietario,
    required this.cidade,
    required this.uf,
    required this.bairro,
    this.pontos = const [], // inicializa vazia por padrão
  });
}