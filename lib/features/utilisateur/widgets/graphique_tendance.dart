import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Graphique en courbes minimaliste (CustomPainter, aucune dépendance).
/// Une courbe par série, une couleur par série.
class GraphiqueTendance extends StatelessWidget {
  final List<String> etiquettes;
  final Map<String, List<double>> series;
  final List<Color> couleurs;

  const GraphiqueTendance({
    super.key,
    required this.etiquettes,
    required this.series,
    required this.couleurs,
  });

  @override
  Widget build(BuildContext context) {
    final noms = series.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            for (int i = 0; i < noms.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: couleurs[i % couleurs.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    noms[i],
                    style: const TextStyle(fontSize: 12, color: Color(0xFF14532D)),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          width: double.infinity,
          child: CustomPaint(
            painter: _TendancePainter(
              etiquettes: etiquettes,
              series: series,
              couleurs: couleurs,
            ),
          ),
        ),
      ],
    );
  }
}

class _TendancePainter extends CustomPainter {
  final List<String> etiquettes;
  final Map<String, List<double>> series;
  final List<Color> couleurs;

  _TendancePainter({
    required this.etiquettes,
    required this.series,
    required this.couleurs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const gauche = 32.0;
    const bas = 24.0;
    const haut = 8.0;
    const droite = 12.0;

    final largeurZone = size.width - gauche - droite;
    final hauteurZone = size.height - bas - haut;

    final toutesValeurs = series.values.expand((v) => v).toList();
    final maxBrut = toutesValeurs.isEmpty ? 1.0 : toutesValeurs.reduce(math.max);
    final maxVal = math.max(1.0, (maxBrut * 1.15).ceilToDouble());

    final grille = Paint()
      ..color = const Color(0xFFE5E9E7)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = haut + hauteurZone * (1 - i / 4);
      canvas.drawLine(Offset(gauche, y), Offset(size.width - droite, y), grille);
      _dessinerTexte(
        canvas,
        (maxVal * i / 4).round().toString(),
        Offset(gauche - 6, y),
        alignDroite: true,
      );
    }

    final n = etiquettes.length;
    double xPour(int i) =>
        n <= 1 ? gauche + largeurZone / 2 : gauche + largeurZone * i / (n - 1);

    for (int i = 0; i < n; i++) {
      _dessinerTexte(
        canvas,
        etiquettes[i],
        Offset(xPour(i), size.height - bas + 6),
        centre: true,
      );
    }

    int indexSerie = 0;
    series.forEach((nom, valeurs) {
      final couleur = couleurs[indexSerie % couleurs.length];

      final trait = Paint()
        ..color = couleur
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final chemin = Path();
      final points = <Offset>[];

      for (int i = 0; i < valeurs.length; i++) {
        final point = Offset(xPour(i), haut + hauteurZone * (1 - valeurs[i] / maxVal));
        points.add(point);
        if (i == 0) {
          chemin.moveTo(point.dx, point.dy);
        } else {
          chemin.lineTo(point.dx, point.dy);
        }
      }

      canvas.drawPath(chemin, trait);

      final pointPlein = Paint()..color = couleur;
      final pointCentre = Paint()..color = Colors.white;
      for (final point in points) {
        canvas.drawCircle(point, 4, pointPlein);
        canvas.drawCircle(point, 2, pointCentre);
      }

      indexSerie++;
    });
  }

  void _dessinerTexte(
    Canvas canvas,
    String texte,
    Offset ancre, {
    bool centre = false,
    bool alignDroite = false,
  }) {
    final peintre = TextPainter(
      text: TextSpan(
        text: texte,
        style: const TextStyle(color: Color(0xFF7F8C8D), fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    double dx = ancre.dx;
    if (centre) dx -= peintre.width / 2;
    if (alignDroite) dx -= peintre.width;
    final dy = alignDroite ? ancre.dy - peintre.height / 2 : ancre.dy;

    peintre.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _TendancePainter ancien) => true;
}