import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/network/api_client.dart';
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/app/data/models/entities/token_entity.dart';
import 'package:pm_app/app/data/models/entities/work_entry_entity.dart';
import 'package:pm_app/app/features/ui/attendance/explanation/explanation_list_state.dart';
import 'package:pm_app/di/di.dart';
class WorkEntryCubit extends Cubit<WorkEntryState> {
  WorkEntryCubit() : super(const WorkEntryState());

Future<void> loadWorkEntries() async {
  emit(state.copyWith(isLoading: true, error: null));

  try {

    final TokenEntity? token = await SharedPrefsHelper.getToken();
    final accessToken = token?.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      emit(state.copyWith(isLoading: false, error: "Không tìm thấy token"));
      return;
    }

    final parts = accessToken.split('.');
    final payloadPart = parts[0];
    final decodedPayload =
        utf8.decode(base64Url.decode(base64Url.normalize(payloadPart)));
    final data = json.decode(decodedPayload);

    final int? userId = data["uid"];
    if (userId == null) {
      emit(state.copyWith(isLoading: false, error: "Không tìm thấy uid trong token"));
      return;
    }

    //final now = DateTime.now();
    ///final date = "${now.year}-${_two(now.month)}-${_two(now.day)}";

    final body = {
      "limit": 20,
      "offset": 0,
      "date_from": "2025-09-01",
      "date_to": "2025-09-30",
    };

    final api = sl<ApiClient>();
    final response = await api.getListWorkEntry(body);

    final code = response.code;
    final msg = response.message;

    if (code != 200) {
      emit(state.copyWith(isLoading: false, error: msg));
      return;
    }

    if (response.data == null) {
      emit(state.copyWith(isLoading: false, list: []));
      return;
    }

    final rawList = response.data["data"] as List<dynamic>? ?? [];

    final list = rawList
        .map((e) => WorkEntryEntity.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    emit(state.copyWith(isLoading: false, list: list));
  } catch (e) {
    emit(state.copyWith(isLoading: false, error: e.toString()));
  }
}

String _two(int n) => n < 10 ? "0$n" : "$n";

}
