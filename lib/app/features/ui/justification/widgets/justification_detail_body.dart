import 'package:flutter/material.dart';

class JustificationDetailBody extends StatelessWidget {
  final int statusId;

  const JustificationDetailBody({
    super.key,
    required this.statusId,
  });

  Color _statusColor(int id) {
    switch (id) {
      case 1:
        return Colors.orange;
      case 14:
        return Colors.blue;
      case 11:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _statusBg(int id) {
    return _statusColor(id).withOpacity(0.15);
  }

  String _statusTitle(int id) {
    switch (id) {
      case 1:
        return "Nháp";
      case 14:
        return "Trưởng phòng duyệt";
      case 11:
        return "Hoàn thành";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _row("Nhân viên", "Tét"),
          _dash(),
          _row("Phòng ban", "Phòng sản xuất"),
          _dash(),
          _row("Loại nghỉ", "Nghỉ có lương"),
          _dash(),
          _row("Từ ngày", "05/01/2026"),
          _dash(),
          _row("Đến ngày", "07/01/2026"),
          _dash(),
          _row("Lý do", "Tét"),
          _dash(),
          _statusRow(statusId),
          _dash(),
          _row("Người duyệt", "Tét"),
          _dash(),
          _row("Người follow", "Tét"),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusRow(int id) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(
            flex: 4,
            child: Text(
              "Trạng thái",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusBg(id),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _statusColor(id),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _statusTitle(id),
                      style: TextStyle(
                        fontSize: 12,
                        color: _statusColor(id),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dash() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
    );
  }
}
