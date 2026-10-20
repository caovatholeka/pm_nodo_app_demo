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

    test('chưa đăng nhập, chưa có cache -> không bật UI mới', () {
      AppFlags.cachedLoginEmail = null;
      expect(AppFlags.currentEmail, isNull);
      expect(AppFlags.isBetaUiActive(), isFalse);
    });

    test('dùng email đã lưu khi chưa có profile (lúc splash/login)', () {
      AppFlags.cachedLoginEmail = 'anhpt@nodo.vn';
      expect(AppFlags.currentEmail, 'anhpt@nodo.vn');
      expect(AppFlags.isBetaUiActive(), isTrue);
    });

    test('email đã lưu không thuộc danh sách beta -> không bật', () {
      AppFlags.cachedLoginEmail = 'someone@nodo.vn';
      expect(AppFlags.isBetaUiActive(), isFalse);
    });
  });
}
