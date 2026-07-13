import 'package:flutter/material.dart';
import 'package:utm/utm.dart';

// classe auxiliar que desenha o croqui
class CroquiPainter extends CustomPainter {
  final List<UtmCoordinate> utmPoints;

  CroquiPainter({required this.utmPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (utmPoints.isEmpty) return;

    // Encontrar a Bounding Box (Limites X e Y extremos em metros reais)
    double minX = utmPoints.first.easting;
    double maxX = utmPoints.first.easting;
    double minY = utmPoints.first.northing;
    double maxY = utmPoints.first.northing;

    for (var p in utmPoints) {
      if (p.easting < minX) minX = p.easting;
      if (p.easting > maxX) maxX = p.easting;
      if (p.northing < minY) minY = p.northing;
      if (p.northing > maxY) maxY = p.northing;
    }

    double widthReais = maxX - minX;
    double heightReais = maxY - minY;
    if (widthReais == 0) widthReais = 1;
    if (heightReais == 0) heightReais = 1;

    // Calcular a Escala Dinâmica para caber no Canvas perfeitamente
    double padding = 30.0;
    double scaleX = (size.width - padding * 2) / widthReais;
    double scaleY = (size.height - padding * 2) / heightReais;
    double scale = scaleX < scaleY ? scaleX : scaleY; 

    double offsetX = (size.width - (widthReais * scale)) / 2;
    double offsetY = (size.height - (heightReais * scale)) / 2;

    // Desenhar o Polígono
    final path = Path();
    for (int i = 0; i < utmPoints.length; i++) {
      double px = offsetX + ((utmPoints[i].easting - minX) * scale);
      double py = size.height - offsetY - ((utmPoints[i].northing - minY) * scale);
      
      if (i == 0) path.moveTo(px, py);
      else path.lineTo(px, py);
    }
    path.close();

    final paintLinha = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, paintLinha);

    // Desenhar os Pontos Vermelhos e Nomes (P1, P2...)
    final paintPonto = Paint()..color = Colors.red..style = PaintingStyle.fill;
    for (int i = 0; i < utmPoints.length; i++) {
      double px = offsetX + ((utmPoints[i].easting - minX) * scale);
      double py = size.height - offsetY - ((utmPoints[i].northing - minY) * scale);
      canvas.drawCircle(Offset(px, py), 4, paintPonto);
      
      final textPainter = TextPainter(
        text: TextSpan(text: 'P${i+1}', style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(px + 6, py - 6));
    }

    // Bússola (Norte Verdadeiro Sempre Apontando para Cima)
    final paintSeta = Paint()..color = Colors.red..strokeWidth = 2..style = PaintingStyle.stroke;
    double bx = size.width - 20;
    double by = 25;
    
    // Letra N de orientação
    final textN = TextPainter(
      text: const TextSpan(text: 'N', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
      textDirection: TextDirection.ltr,
    );
    textN.layout();
    textN.paint(canvas, Offset(bx - 5, by - 20));
    
    // Desenho da Setinha da Bússola
    canvas.drawLine(Offset(bx, by), Offset(bx, by + 15), paintSeta);
    canvas.drawLine(Offset(bx, by), Offset(bx - 4, by + 5), paintSeta);
    canvas.drawLine(Offset(bx, by), Offset(bx + 4, by + 5), paintSeta);

    // Escala Gráfica Dinâmica
    double barraPixels = 60.0; // Tamanho visual fixo da régua
    double metrosReais = barraPixels / scale; // Quantos metros cabem nesses 60 pixels
    
    double ex = 10;
    double ey = size.height - 15;
    canvas.drawLine(Offset(ex, ey), Offset(ex + barraPixels, ey), paintLinha); 
    canvas.drawLine(Offset(ex, ey - 3), Offset(ex, ey + 3), paintLinha); 
    canvas.drawLine(Offset(ex + barraPixels, ey - 3), Offset(ex + barraPixels, ey + 3), paintLinha);
    
    final textEscala = TextPainter(
      text: TextSpan(text: '${metrosReais.toStringAsFixed(1)} m', style: const TextStyle(color: Colors.black, fontSize: 10)),
      textDirection: TextDirection.ltr,
    );
    textEscala.layout();
    textEscala.paint(canvas, Offset(ex, ey - 15)); // Escreve o valor real da escala em cima da barra
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}