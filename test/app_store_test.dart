import 'package:flutter_test/flutter_test.dart';
import 'package:potentiel/services/app_store.dart';

void main() {
  group('AppStore calendar logic', () {
    test('formats ISO week keys across year boundaries', () {
      expect(AppStore.weekKey(DateTime(2021, 1, 1)), '2020-W53');
      expect(AppStore.weekKey(DateTime(2021, 1, 4)), '2021-W01');
      expect(AppStore.weekKey(DateTime(2024, 12, 30)), '2025-W01');
    });

    test('cycles gym routines in four-week rotation', () {
      expect(AppStore.rotationFor(DateTime(2024, 1, 1)), 1);
      expect(AppStore.rotationFor(DateTime(2024, 1, 8)), 2);
      expect(AppStore.rotationFor(DateTime(2024, 1, 15)), 3);
      expect(AppStore.rotationFor(DateTime(2024, 1, 22)), 4);
      expect(AppStore.rotationFor(DateTime(2024, 1, 29)), 1);
    });
  });
}
