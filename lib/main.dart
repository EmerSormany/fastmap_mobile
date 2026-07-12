import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'core/constants/environment.dart';
import 'core/models/fast_map_app.dart';

void main() async {
  // Garante que os componentes do Flutter carreguem antes do banco
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Supabase usando as variáveis do arquivo centralizado
  await Supabase.initialize(
    url: Environment.supabaseUrl, 
    anonKey: Environment.supabaseAnonKey,
  );

  runApp(const FastMapApp());
}