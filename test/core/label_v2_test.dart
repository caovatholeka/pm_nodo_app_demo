import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/app/core/theme_v2/label_v2.dart';

void main() {
  test('bỏ dấu hai chấm / khoảng trắng ở cuối nhãn', () {
    expect(labelV2('Chức danh: '), 'Chức danh');
    expect(labelV2('Ngày gia nhập:'), 'Ngày gia nhập');
    expect(labelV2('Lý do:'), 'Lý do');
    expect(labelV2('Job Title: '), 'Job Title');
  });

  test('nhãn không có dấu hai chấm giữ nguyên; dấu hai chấm ở giữa không đụng tới', () {
    expect(labelV2('Phòng ban'), 'Phòng ban');
    expect(labelV2('Giờ: 08:30'), 'Giờ: 08:30');
    expect(labelV2(''), '');
  });
}
