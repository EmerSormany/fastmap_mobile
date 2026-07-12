import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'core/models/fast_map_app.dart';
import 'dart:convert'; // Para converter o JSON
import 'package:flutter/services.dart';

void main() async {
  // Garante que os componentes do Flutter carreguem antes do banco
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Lê o arquivo config.json como texto
  final configString = await rootBundle.loadString('config.json');
  
  // 2. Converte o texto para um Mapa (Objeto JSON)
  final configData = jsonDecode(configString);

  // 3. Inicializa o Supabase pegando os dados diretamente do JSON
  await Supabase.initialize(
    url: configData['SUPABASE_URL'], 
    anonKey: configData['SUPABASE_ANON_KEY'],
  );

  runApp(const FastMapApp());
}