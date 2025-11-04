import 'package:pm_app/app/data/models/entities/master_data_item.dart';

class LeaveDayEntity {
  String? date;
  MasterDataItem type;

  LeaveDayEntity({
    this.date,
    this.type = const MasterDataItem(text: "Cả ngày",code: "ALL"),
  });

  LeaveDayEntity copyWith({
    String? date,
    MasterDataItem? type,
  }) {
    return LeaveDayEntity(
        date: date ?? this.date,
        type: type ?? this.type,
    );
  }

}