/// Giới hạn số ký tự các ô nhập chữ — khớp với backend
/// (nodo_hr_api/handler/input_limits.py). Ô nhập không cho gõ quá và hiện bộ đếm "n/max".
class InputLimits {
  InputLimits._();

  /// Việc cần làm — Tiêu đề.
  static const int taskTitle = 255;

  /// Việc cần làm — Mô tả.
  static const int taskDescription = 2000;

  /// Ghi chú / lý do các đơn (đi muộn/về sớm, OT, nghỉ phép, công tác), giải trình công,
  /// lý do từ chối đơn.
  static const int requestNote = 1000;

  /// Công tác — Địa chỉ.
  static const int address = 255;

  /// Lý do chấm công sớm/muộn (popup sau khi chấm).
  static const int checkInReason = 500;

  /// Phiếu đánh giá — ô đầu mục: công việc đã thực hiện; dự án, công nghệ, quy mô nhân sự
  /// (QA 30/10).
  static const int appraisalTitle = 500;

  /// Phiếu đánh giá — ô nội dung dài: minh chứng/ghi chú, ý kiến điều chỉnh, mô tả công
  /// việc, ý kiến đề xuất, ý kiến duyệt.
  static const int appraisalNote = 5000;
}
