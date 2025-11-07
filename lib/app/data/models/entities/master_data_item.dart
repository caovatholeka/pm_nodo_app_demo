class MasterDataItem {
  final int? id;
  final String? name;
  final String? text;
  final String? code;

  const MasterDataItem({
    this.id,
    this.name,
    this.text,
    this.code,
  });

  factory MasterDataItem.fromJson(Map<String, dynamic> json) {
    return MasterDataItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name'] ?? json['departmentName'] ?? json['text'] ?? '',
      text: json['text'] ?? json['name'] ?? '',
      code: json['code']?.toString(),
    );
  }

  @override
  String toString() => name ?? text ?? '';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MasterDataItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          text == other.text &&
          code == other.code;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ text.hashCode ^ code.hashCode;
}
