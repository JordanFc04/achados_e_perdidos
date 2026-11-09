class ItemModel {
  static const String lostStatus = 'Perdido';
  static const String foundStatus = 'Encontrado';
  static const List<String> statuses = [lostStatus, foundStatus];

  final String id;
  final String name;
  final String description;
  final String location;
  final String status;
  final DateTime createdAt;

  ItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.status,
    required this.createdAt,
  });

  bool get isLost => status == lostStatus;

  factory ItemModel.fromMap(String id, Map<String, dynamic> map) {
    final rawCreatedAt = map['createdAt'];

    return ItemModel(
      id: id,
      name: _asText(map['name']),
      description: _asText(map['description']),
      location: _asText(map['location']),
      status: normalizeStatus(map['status']),
      createdAt: _asDate(rawCreatedAt),
    );
  }

  static String normalizeStatus(Object? value) {
    return value == foundStatus ? foundStatus : lostStatus;
  }

  static String _asText(Object? value) {
    return value is String ? value.trim() : '';
  }

  static DateTime _asDate(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}

class ItemDraft {
  const ItemDraft({
    required this.name,
    required this.description,
    required this.location,
    required this.status,
  });

  final String name;
  final String description;
  final String location;
  final String status;
}
