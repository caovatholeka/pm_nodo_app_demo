import 'package:pm_app/app/data/models/entities/job_title_entity.dart';

class JobTitleListEntity {
  final List<JobTitleEntity> data;

  const JobTitleListEntity({required this.data});

  factory JobTitleListEntity.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    if (rawData is! List) {
      return const JobTitleListEntity(data: []);
    }

    return JobTitleListEntity(
      data:
          rawData
              .whereType<Map>()
              .map(
                (item) =>
                    JobTitleEntity.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data.map((item) => item.toJson()).toList()};
  }
}
