import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:flutter/material.dart';

class KurbaniAvatar extends StatelessWidget {
  const KurbaniAvatar({
    super.key,
    required this.id,
    required this.name,
    required this.photoUrl,
    this.size = 46,
  });

  final String id;
  final String name;
  final String photoUrl;
  final double size;

  static const _gradients = <List<Color>>[
    [KurbaniPalette.emerald, KurbaniPalette.cyan],
    [KurbaniPalette.violet, KurbaniPalette.rose],
    [KurbaniPalette.gold, KurbaniPalette.rose],
    [Color(0xFF2563EB), KurbaniPalette.violet],
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[id.hashCode.abs() % _gradients.length];
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: gradient),
        border: Border.all(color: Colors.white.withValues(alpha: .3)),
      ),
      child: photoUrl.isEmpty
          ? Center(
              child: Text(
                _initials(name),
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: MyString.poppinsBold,
                  fontSize: size * .28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Center(
                child: Text(
                  _initials(name),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: MyString.poppinsBold,
                    fontSize: size * .28,
                  ),
                ),
              ),
            ),
    );
  }

  String _initials(String value) {
    final words = value.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }
}
