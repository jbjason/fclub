import 'dart:math';

abstract final class GroupPinGenerator {
  static const _characters = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static String generate() {
    final random = Random.secure();
    final first = List.generate(
      4,
      (_) => _characters[random.nextInt(_characters.length)],
    ).join();
    final second = List.generate(
      3,
      (_) => _characters[random.nextInt(_characters.length)],
    ).join();
    return '$first-$second';
  }
}
