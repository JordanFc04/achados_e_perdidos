import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/item_model.dart';
import 'item_service.dart';

class FirestoreItemService implements ItemService {
  FirestoreItemService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collectionName = 'items';
  static const Duration _timeout = Duration(seconds: 15);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _items =>
      _firestore.collection(_collectionName);

  @override
  Future<List<ItemModel>> fetchItems() async {
    try {
      final snapshot = await _items
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(_timeout);

      return snapshot.docs.map(_toModel).toList(growable: false);
    } on TimeoutException {
      throw const ItemServiceException(
        'A conexão demorou demais. Verifique sua internet e tente novamente.',
      );
    } on FirebaseException catch (error) {
      throw ItemServiceException(_messageFor(error));
    }
  }

  @override
  Future<void> createItem(ItemDraft draft) async {
    try {
      await _items
          .add({
            'name': draft.name.trim(),
            'description': draft.description.trim(),
            'location': draft.location.trim(),
            'status': draft.status,
            'createdAt': FieldValue.serverTimestamp(),
          })
          .timeout(_timeout);
    } on TimeoutException {
      throw const ItemServiceException(
        'A conexão demorou demais. Verifique sua internet e tente novamente.',
      );
    } on FirebaseException catch (error) {
      throw ItemServiceException(_messageFor(error));
    }
  }

  ItemModel _toModel(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = Map<String, dynamic>.from(document.data());
    final createdAt = data['createdAt'];

    if (createdAt is Timestamp) {
      data['createdAt'] = createdAt.toDate();
    }

    return ItemModel.fromMap(document.id, data);
  }

  String _messageFor(FirebaseException error) {
    switch (error.code) {
      case 'unavailable':
      case 'network-request-failed':
      case 'deadline-exceeded':
        return 'Sem conexão com o serviço. Verifique sua internet e tente novamente.';
      case 'permission-denied':
      case 'unauthenticated':
        return 'O serviço recusou a operação. Tente novamente mais tarde.';
      case 'failed-precondition':
        return 'O banco de dados ainda não está pronto. Tente novamente em instantes.';
      default:
        return 'Não foi possível concluir a operação. Tente novamente.';
    }
  }
}
