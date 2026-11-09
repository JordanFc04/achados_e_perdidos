import 'package:achados_e_perdidos/models/item_model.dart';
import 'package:achados_e_perdidos/services/item_service.dart';
import 'package:achados_e_perdidos/state/item_store.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeItemService implements ItemService {
  _FakeItemService({
    this.items = const [],
    this.loadError,
    this.createError,
    this.updateError,
    this.deleteError,
  });

  List<ItemModel> items;
  final ItemServiceException? loadError;
  final ItemServiceException? createError;
  final ItemServiceException? updateError;
  final ItemServiceException? deleteError;
  final List<ItemDraft> createdDrafts = [];
  final List<String> updatedIds = [];
  final List<ItemDraft> updatedDrafts = [];
  final List<String> deletedIds = [];
  int fetchCalls = 0;

  @override
  Future<List<ItemModel>> fetchItems() async {
    fetchCalls++;
    if (loadError != null) {
      throw loadError!;
    }
    return items;
  }

  @override
  Future<void> createItem(ItemDraft draft) async {
    if (createError != null) {
      throw createError!;
    }

    createdDrafts.add(draft);
    items = [
      ItemModel(
        id: 'new',
        name: draft.name,
        description: draft.description,
        location: draft.location,
        status: draft.status,
        createdAt: DateTime.now(),
      ),
      ...items,
    ];
  }

  @override
  Future<void> updateItem(String id, ItemDraft draft) async {
    if (updateError != null) {
      throw updateError!;
    }

    updatedIds.add(id);
    updatedDrafts.add(draft);
    items = items
        .map(
          (item) => item.id != id
              ? item
              : ItemModel(
                  id: item.id,
                  name: draft.name,
                  description: draft.description,
                  location: draft.location,
                  status: draft.status,
                  createdAt: item.createdAt,
                ),
        )
        .toList();
  }

  @override
  Future<void> deleteItem(String id) async {
    if (deleteError != null) {
      throw deleteError!;
    }

    deletedIds.add(id);
    items = items.where((item) => item.id != id).toList();
  }
}

ItemModel _item({String id = '1', String name = 'Carteira'}) {
  return ItemModel(
    id: id,
    name: name,
    description: 'Marrom',
    location: 'Biblioteca',
    status: ItemModel.foundStatus,
    createdAt: DateTime(2026, 11, 7),
  );
}

void main() {
  test('load fills items and clears loading state', () async {
    final service = _FakeItemService(items: [_item()]);
    final store = ItemStore(service);

    await store.load();

    expect(store.items, hasLength(1));
    expect(store.items.single.name, 'Carteira');
    expect(store.isLoading, isFalse);
    expect(store.errorMessage, isNull);
  });

  test('load exposes a friendly error when the service fails', () async {
    final service = _FakeItemService(
      loadError: const ItemServiceException('Falha de teste'),
    );
    final store = ItemStore(service);

    await store.load();

    expect(store.items, isEmpty);
    expect(store.errorMessage, 'Falha de teste');
    expect(store.isLoading, isFalse);
  });

  test('create saves the draft and reloads the list', () async {
    final service = _FakeItemService();
    final store = ItemStore(service);

    final success = await store.create(
      const ItemDraft(
        name: 'Carteira',
        description: 'Marrom',
        location: 'Biblioteca',
        status: ItemModel.foundStatus,
      ),
    );

    expect(success, isTrue);
    expect(service.createdDrafts, hasLength(1));
    expect(service.fetchCalls, 1);
    expect(store.items.single.name, 'Carteira');
    expect(store.isSaving, isFalse);
    expect(store.errorMessage, isNull);
  });

  test('create reports an error and keeps the form data', () async {
    final service = _FakeItemService(
      createError: const ItemServiceException('Sem conexão'),
    );
    final store = ItemStore(service);

    final success = await store.create(
      const ItemDraft(
        name: 'Carteira',
        description: 'Marrom',
        location: 'Biblioteca',
        status: ItemModel.foundStatus,
      ),
    );

    expect(success, isFalse);
    expect(store.errorMessage, 'Sem conexão');
    expect(store.isSaving, isFalse);
    expect(service.createdDrafts, isEmpty);
    expect(service.fetchCalls, 0);
  });

  test('update saves the draft and reloads the list', () async {
    final service = _FakeItemService(items: [_item()]);
    final store = ItemStore(service);

    final success = await store.update(
      '1',
      const ItemDraft(
        name: 'Carteira azul',
        description: 'Azul com documentos',
        location: 'Bloco B',
        status: ItemModel.lostStatus,
      ),
    );

    expect(success, isTrue);
    expect(service.updatedIds, ['1']);
    expect(service.updatedDrafts.single.name, 'Carteira azul');
    expect(service.fetchCalls, 1);
    expect(store.items.single.name, 'Carteira azul');
    expect(store.items.single.status, ItemModel.lostStatus);
    expect(store.isSaving, isFalse);
    expect(store.errorMessage, isNull);
  });

  test('update reports an error and keeps the list unchanged', () async {
    final service = _FakeItemService(
      items: [_item()],
      updateError: const ItemServiceException('Sem permissão'),
    );
    final store = ItemStore(service);
    await store.load();

    final success = await store.update(
      '1',
      const ItemDraft(
        name: 'Carteira azul',
        description: 'Azul com documentos',
        location: 'Bloco B',
        status: ItemModel.lostStatus,
      ),
    );

    expect(success, isFalse);
    expect(store.errorMessage, 'Sem permissão');
    expect(store.isSaving, isFalse);
    expect(store.items.single.name, 'Carteira');
    expect(service.updatedIds, isEmpty);
    expect(service.fetchCalls, 1);
  });

  test('delete removes the item and reloads the list', () async {
    final service = _FakeItemService(items: [_item()]);
    final store = ItemStore(service);

    final success = await store.delete('1');

    expect(success, isTrue);
    expect(service.deletedIds, ['1']);
    expect(service.fetchCalls, 1);
    expect(store.items, isEmpty);
    expect(store.isDeleting, isFalse);
    expect(store.errorMessage, isNull);
  });

  test('delete reports an error and keeps the item', () async {
    final service = _FakeItemService(
      items: [_item()],
      deleteError: const ItemServiceException('Sem permissão'),
    );
    final store = ItemStore(service);
    await store.load();

    final success = await store.delete('1');

    expect(success, isFalse);
    expect(store.errorMessage, 'Sem permissão');
    expect(store.isDeleting, isFalse);
    expect(store.items, hasLength(1));
    expect(service.deletedIds, isEmpty);
    expect(service.fetchCalls, 1);
  });
}
