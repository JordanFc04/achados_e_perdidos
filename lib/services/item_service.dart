import '../models/item_model.dart';

abstract class ItemService {
  Future<List<ItemModel>> fetchItems();

  Future<void> createItem(ItemDraft draft);
}

class ItemServiceException implements Exception {
  const ItemServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
