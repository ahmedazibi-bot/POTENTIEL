import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  const size = 1024;
  final image = img.Image(width: size, height: size);
  final navy = img.ColorRgb8(9, 15, 24);
  final mid = img.ColorRgb8(17, 29, 41);
  final gold = img.ColorRgb8(242, 190, 75);
  final bright = img.ColorRgb8(255, 226, 145);
  final pale = img.ColorRgb8(255, 246, 219);
  final darkGold = img.ColorRgb8(105, 73, 27);
  final teal = img.ColorRgb8(46, 132, 124);
  final ink = img.ColorRgb8(16, 24, 32);

  // Deep navy background with subtle gold radial rays.
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final dx = x - size / 2;
      final dy = y - size / 2;
      final r = math.sqrt(dx * dx + dy * dy) / (size * .71);
      final glow = (1 - r).clamp(0.0, 1.0);
      image.setPixelRgb(
          x, y, navy.r + 4 * glow, navy.g + 8 * glow, navy.b + 12 * glow);
    }
  }

  // Gold orbital marks and top/bottom player-card trim.
  for (var offset = -1; offset <= 1; offset++) {
    img.drawCircle(image,
        x: 512, y: 500, radius: 437 + offset, color: darkGold, antialias: true);
    img.drawCircle(image,
        x: 512, y: 500, radius: 422 + offset, color: gold, antialias: true);
  }
  img.drawLine(image,
      x1: 115, y1: 170, x2: 909, y2: 170, color: darkGold, thickness: 2);
  img.drawLine(image,
      x1: 115, y1: 855, x2: 909, y2: 855, color: darkGold, thickness: 2);

  // Stylized trophy shield: layered dark, antique gold, and luminous inner crest.
  final shield = <img.Point>[
    img.Point(512, 181),
    img.Point(766, 278),
    img.Point(733, 573),
    img.Point(655, 713),
    img.Point(512, 820),
    img.Point(369, 713),
    img.Point(291, 573),
    img.Point(258, 278),
  ];
  img.fillPolygon(image, vertices: shield, color: darkGold);
  img.drawPolygon(image,
      vertices: shield, color: bright, thickness: 11, antialias: true);
  final innerShield = shield
      .map((point) =>
          img.Point(512 + (point.x - 512) * .91, 500 + (point.y - 500) * .91))
      .toList();
  img.fillPolygon(image, vertices: innerShield, color: mid);
  img.drawPolygon(image,
      vertices: innerShield, color: gold, thickness: 4, antialias: true);

  // Faceted champion crest behind the bolt.
  final badge = <img.Point>[
    img.Point(512, 270),
    img.Point(706, 348),
    img.Point(675, 546),
    img.Point(512, 660),
    img.Point(349, 546),
    img.Point(318, 348),
  ];
  img.fillPolygon(image, vertices: badge, color: darkGold);
  img.drawPolygon(image,
      vertices: badge, color: gold, thickness: 5, antialias: true);
  img.fillPolygon(image,
      vertices: [
        img.Point(512, 295),
        img.Point(676, 362),
        img.Point(652, 525),
        img.Point(512, 625),
        img.Point(372, 525),
        img.Point(348, 362),
      ],
      color: teal);

  // High-energy lightning insignia.
  final bolt = <img.Point>[
    img.Point(545, 324),
    img.Point(418, 493),
    img.Point(501, 493),
    img.Point(466, 592),
    img.Point(609, 420),
    img.Point(526, 420),
  ];
  img.fillPolygon(image, vertices: bolt, color: ink);
  img.drawPolygon(image,
      vertices: bolt, color: pale, thickness: 4, antialias: true);

  // Four compact star sparks around the badge.
  for (final center in [
    img.Point(253, 316),
    img.Point(771, 316),
    img.Point(278, 687),
    img.Point(746, 687),
  ]) {
    final points = <img.Point>[];
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final radius = i.isEven ? 22.0 : 9.0;
      points.add(img.Point(center.x + math.cos(angle) * radius,
          center.y + math.sin(angle) * radius));
    }
    img.fillPolygon(image, vertices: points, color: bright);
  }

  // Original POTENTIEL monogram/nameplate, legible at launcher-icon scale.
  img.drawRect(image,
      x1: 203, y1: 744, x2: 821, y2: 833, color: darkGold, radius: 18);
  img.drawRect(image,
      x1: 211, y1: 752, x2: 813, y2: 825, color: gold, radius: 14);
  img.fillRect(image, x1: 218, y1: 759, x2: 806, y2: 818, color: navy);
  img.drawString(image, 'POTENTIEL', font: img.arial48, color: bright, y: 767);

  final output = File('assets/icons/app_icon.png');
  output.parent.createSync(recursive: true);
  output.writeAsBytesSync(img.encodePng(image, level: 9));
  stdout.writeln('Created ${output.path} (${output.lengthSync()} bytes)');
}
