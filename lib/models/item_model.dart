class ItemModel {
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
}
