// import 'package:flutter/material.dart';

// class GridPainter extends CustomPainter {
//   final List<Offset> pontos;
//   final bool fecharPoligono;

//   GridPainter({required this.pontos, required this.fecharPoligono});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final gridPaint = Paint()
//       ..color = Colors.grey.shade300
//       ..strokeWidth = 1.0;

//     const double gridSize = 40.0;
//     for (double i = 0; i < size.width; i += gridSize) {
//       canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
//     }
//     for (double i = 0; i < size.height; i += gridSize) {
//       canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
//     }

//     if (pontos.isEmpty) return;

//     final linePaint = Paint()
//       ..color = Colors.teal
//       ..strokeWidth = 3.0
//       ..style = PaintingStyle.stroke;

//     final fillPaint = Paint()
//       ..color = Colors.teal.withOpacity(0.3)
//       ..style = PaintingStyle.fill;

//     Path path = Path();
//     path.moveTo(pontos[0].dx, pontos[0].dy);

//     for (int i = 1; i < pontos.length; i++) {
//       path.lineTo(pontos[i].dx, pontos[i].dy);
//     }

//     if (fecharPoligono && pontos.length >= 3) {
//       path.close();
//       canvas.drawPath(path, fillPaint);
//     }

//     canvas.drawPath(path, linePaint);

//     final pointPaint = Paint()
//       ..color = Colors.red
//       ..style = PaintingStyle.fill;

//     for (var ponto in pontos) {
//       canvas.drawCircle(ponto, 6.0, pointPaint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant GridPainter oldDelegate) {
//     return oldDelegate.pontos.length != pontos.length || 
//            oldDelegate.fecharPoligono != fecharPoligono;
//   }
// }