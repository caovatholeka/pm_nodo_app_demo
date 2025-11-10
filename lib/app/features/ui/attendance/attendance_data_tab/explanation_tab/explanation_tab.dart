import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/app/data/models/entities/profile_entity.dart';
import 'package:pm_app/app/data/models/entities/token_entity.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';
import 'package:pm_app/di/di.dart';

class ExplanationTab extends StatefulWidget {
  const ExplanationTab({super.key});

  @override
  State<ExplanationTab> createState() => _ExplanationTabState();
}

class _ExplanationTabState extends State<ExplanationTab> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isReasonFilled = false;

  ProfileEntity? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _reasonController.addListener(() {
      setState(() => _isReasonFilled = _reasonController.text.trim().isNotEmpty);
    });
  }

  Future<void> _loadProfile() async {
    try {
      final TokenEntity? tokenEntity = await SharedPrefsHelper.getToken();
      final accessToken = tokenEntity?.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final parts = accessToken.split('.');
      if (parts.length != 3) {
        setState(() => _isLoading = false);
        return;
      }

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final data = json.decode(payload);
      final userId = data['id'] ?? data['sub'] ?? data['user_id'];
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final repo = sl<UserRepository>();
      final response = await repo.getUserProfile({"id": userId});

      if (response.data != null) {
        final Map<String, dynamic> jsonData =
            response.data is Map<String, dynamic> ? response.data : json.decode(json.encode(response.data));

        setState(() {
          _profile = ProfileEntity.fromJson(jsonData);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final name = _profile?.name ?? "Không xác định";
    final department = _profile?.code ?? "Không xác định";

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReadOnlyField("Nhân viên", name),
          const SizedBox(height: 10),
          _buildReadOnlyField("Phòng ban", department),
          const SizedBox(height: 10),
          _buildReadOnlyField("Giờ đến", "08:30"),
          const SizedBox(height: 10),
          _buildReadOnlyField("Giờ về", "18:00"),
          const SizedBox(height: 10),
          const Text.rich(
            TextSpan(
              text: "Lý do ",
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 15),
              children: [
                TextSpan(text: "*", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Nhập lý do nghỉ",
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.colorPrimary50, width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            mainText: "Xác nhận",
            enable: _isReasonFilled,
            callback: () {
              if (_isReasonFilled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã gửi giải trình thành công!")),
                );
              }
            },
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            borderRadius: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87, fontSize: 15)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87)),
        ),
      ],
    );
  }
}
