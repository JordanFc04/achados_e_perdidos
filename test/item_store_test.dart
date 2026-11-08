import 'package:achados_e_perdidos/models/item_model.dart';
import 'package:achados_e_perdidos/services/item_service.dart';
import 'package:achados_e_perdidos/state/item_store.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeItemService implements ItemService {
  _FakeItemService({this.items = const [], this.loadError, this.createError});

  List<ItemModel> items;
  final ItemServiceException? loadError;
  final ItemServiceException? createError;
  final List<ItemDraft> createdDrafts = [];
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
}

void main() {
  test('load fills items and clears loading state', () async {
    final service = _FakeItemService(
      items: [
        ItemModel(
          id: '1',
          name: 'Carteira',
          description: 'Marrom',
          location: 'Biblioteca',
          status: ItemModel.foundStatus,
          createdAt: DateTime(2026, 11, 7),
        ),
      ],
    );
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
}
