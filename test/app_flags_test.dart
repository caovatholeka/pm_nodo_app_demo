import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/app/core/commons/app_flags.dart';

void main() {
  group('AppFlags.isBetaUiEmail', () {
    test('trả true cho email beta (không phân biệt hoa/thường, có khoảng trắng)', () {
      expect(AppFlags.isBetaUiEmail('anhpt@nodo.vn'), isTrue);
      expect(AppFlags.isBetaUiEmail('  ANHPT@Nodo.VN '), isTrue);
    });
    test('trả false cho email khác hoặc null', () {
      expect(AppFlags.isBetaUiEmail('someone@nodo.vn'), isFalse);
      expect(AppFlags.isBetaUiEmail(null), isFalse);
      expect(AppFlags.isBetaUiEmail(''), isFalse);
    });
  });

  group('AppFlags.currentEmail / isBetaUiActive', () {
    tearDown(() => AppFlags.cachedLoginEmail = null);

    test('isBetaUiActive luôn trả về true cho mọi người dùng', () {
      AppFlags.cachedLoginEmail = null;
      expect(AppFlags.isBetaUiActive(), isTrue);

      AppFlags.cachedLoginEmail = 'someone@nodo.vn';
      expect(AppFlags.isBetaUiActive(), isTrue);

      AppFlags.cachedLoginEmail = 'anhpt@nodo.vn';
      expect(AppFlags.isBetaUiActive(), isTrue);
    });
  });
}
