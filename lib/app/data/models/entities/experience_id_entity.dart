import 'package:json_annotation/json_annotation.dart';

part 'experience_id_entity.g.dart';

@JsonSerializable()
class ExperienceIdEntity {
    @JsonKey(name: "date_from")
    String? dateFrom;

    @JsonKey(name:"date_to")
    String? dateTo;

    @JsonKey(name: "technique_name")
    String? techniqueName;

    @JsonKey(name: "number_people")
    String? numberPeople;

    @JsonKey(name: "position_id")
    int? positionId;

    @JsonKey()
    String? name;

    @JsonKey()
    String? note;

    ExperienceIdEntity({
        this.dateFrom,
        this.dateTo,
        this.techniqueName,
        this.numberPeople,
        this.positionId,
        this.name,
        this.note,
    });


    ExperienceIdEntity copyWith({
        String? dateFrom,
        String? dateTo,
        String? techniqueName,
        String? numberPeople,
        int? positionId,
        String? name,
        String? note,
    }) => 
        ExperienceIdEntity(
            dateFrom: dateFrom ?? this.dateFrom,
            dateTo: dateTo ?? this.dateTo,
            techniqueName: techniqueName ?? this.techniqueName,
            numberPeople: numberPeople ?? this.numberPeople,
            positionId: positionId ?? this.positionId,
            name: name ?? this.name,
            note: note ?? this.note,
        );

    factory ExperienceIdEntity.fromJson(Map<String, dynamic> json) => _$ExperienceIdEntityFromJson(json);
    Map<String, dynamic> toJson() => _$ExperienceIdEntityToJson(this);
}