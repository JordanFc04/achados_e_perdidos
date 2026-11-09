import 'package:achados_e_perdidos/models/item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromMap reads and normalizes fields', () {
    final createdAt = DateTime(2026, 11, 7, 12, 30);

    final item = ItemModel.fromMap('abc', {
      'name': '  Mochila  ',
      'description': '  Preta  ',
      'location': '  Bloco A  ',
      'status': ItemModel.foundStatus,
      'createdAt': createdAt,
    });

    expect(item.id, 'abc');
    expect(item.name, 'Mochila');
    expect(item.description, 'Preta');
    expect(item.location, 'Bloco A');
    expect(item.status, ItemModel.foundStatus);
    expect(item.isLost, isFalse);
    expect(item.createdAt, createdAt);
  });

  test('fromMap defaults to lost and current date when values are missing', () {
    final before = DateTime.now();

    final item = ItemModel.fromMap('abc', {});

    final after = DateTime.now();

    expect(item.name, isEmpty);
    expect(item.description, isEmpty);
    expect(item.location, isEmpty);
    expect(item.status, ItemModel.lostStatus);
    expect(item.isLost, isTrue);
    expect(item.createdAt.isBefore(before), isFalse);
    expect(item.createdAt.isAfter(after), isFalse);
  });

  test('fromMap normalizes an unknown status to lost', () {
    final item = ItemModel.fromMap('abc', {'status': 'Indefinido'});

    expect(item.status, ItemModel.lostStatus);
  });
}
