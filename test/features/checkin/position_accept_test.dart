import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pm_app/app/features/ui/checkin/bloc/check_in_cubit.dart';

void main() {
  final now = DateTime(2026, 10, 16, 8, 30);

  // ~0.001 độ vĩ ≈ 111 m
  Position pos({
    double lat = 21.0,
    double lng = 105.8,
    required int ageSec,
    required double acc,
  }) =>
      Position(
        latitude: lat,
        longitude: lng,
        timestamp: now.subtract(Duration(seconds: ageSec)),
        accuracy: acc,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

  bool accept(Position? current, Position next) =>
      CheckInCubit.shouldAcceptPosition(current: current, next: next, now: now);

  test('chưa có vị trí: nhận cả vị trí lưu sẵn ≤ 5 phút, bỏ vị trí quá cũ', () {
    expect(accept(null, pos(ageSec: 240, acc: 500)), isTrue);
    expect(accept(null, pos(ageSec: 400, acc: 10)), isFalse);
  });

  test('vị trí lưu sẵn từ chỗ khác (cũ) được thay bằng vị trí mới dù sai số 150 m', () {
    final cached = pos(lat: 21.03, ageSec: 240, acc: 20); // cách ~3 km, 4 phút trước
    expect(accept(cached, pos(ageSec: 2, acc: 150)), isTrue);
  });

  test('đứng yên > 60 giây (stream im lặng): vị trí mới lúc bấm được nhận', () {
    final stillOld = pos(ageSec: 90, acc: 30);
    expect(accept(stillOld, pos(ageSec: 1, acc: 25)), isTrue);
  });

  test('vị trí cũ chỉ bị thay khi vị trí mới không quá tệ', () {
    final cached = pos(ageSec: 120, acc: 50);
    expect(accept(cached, pos(ageSec: 1, acc: 1500)), isFalse); // vd iPhone để "vị trí xấp xỉ"
    final cachedBad = pos(ageSec: 120, acc: 2000);
    expect(accept(cachedBad, pos(ageSec: 1, acc: 1500)), isTrue); // không tệ hơn
  });

  test('vị trí hiện tại còn mới: giữ quy tắc cũ (≤ 100 m và có thay đổi đáng kể)', () {
    final fresh = pos(ageSec: 10, acc: 30);
    expect(accept(fresh, pos(ageSec: 1, acc: 150)), isFalse);
    expect(accept(fresh, pos(lat: 21.00002, ageSec: 1, acc: 28)), isFalse); // ~2 m, không tốt hơn
    expect(accept(fresh, pos(lat: 21.001, ageSec: 1, acc: 30)), isTrue); // ~111 m
    expect(accept(fresh, pos(ageSec: 1, acc: 10)), isTrue); // chính xác hơn 20 m
  });

  test('không nhận vị trí cũ khi đã có vị trí', () {
    expect(accept(pos(ageSec: 10, acc: 30), pos(ageSec: 120, acc: 5)), isFalse);
  });
}
