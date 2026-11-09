import '../models/item_model.dart';

abstract class ItemService {
  Future<List<ItemModel>> fetchItems();

  Future<void> createItem(ItemDraft draft);

  Future<void> updateItem(String id, ItemDraft draft);

  Future<void> deleteItem(String id);
}

class ItemServiceException implements Exception {
  const ItemServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
