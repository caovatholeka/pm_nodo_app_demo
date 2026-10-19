import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/app/data/models/entities/profile_entity.dart';

void main() {
  group('ProfileEntity.phone', () {
    test('Odoo trả false khi rỗng -> null', () {
      final p = ProfileEntity.fromJson({'id': 1, 'phone': false});
      expect(p.phone, isNull);
    });

    test('thiếu field / null -> null', () {
      expect(ProfileEntity.fromJson({'id': 1}).phone, isNull);
      expect(ProfileEntity.fromJson({'id': 1, 'phone': null}).phone, isNull);
    });

    test('chuỗi rỗng -> null', () {
      expect(ProfileEntity.fromJson({'id': 1, 'phone': '  '}).phone, isNull);
    });

    test('có số điện thoại -> giữ nguyên chuỗi', () {
      final p = ProfileEntity.fromJson({'id': 1, 'phone': '0912345678'});
      expect(p.phone, '0912345678');
    });

    test('server trả kiểu số -> ép về chuỗi', () {
      final p = ProfileEntity.fromJson({'id': 1, 'phone': 912345678});
      expect(p.phone, '912345678');
    });
  });
}
