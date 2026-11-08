import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/item_model.dart';
import '../services/item_service.dart';

class ItemStore extends ChangeNotifier {
  ItemStore(this._service);

  final ItemService _service;

  List<ItemModel> _items = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  UnmodifiableListView<ItemModel> get items => UnmodifiableListView(_items);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _service.fetchItems();
    } on ItemServiceException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Não foi possível carregar os objetos. Verifique sua conexão e tente novamente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(ItemDraft draft) async {
    if (_isSaving) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.createItem(draft);
    } on ItemServiceException catch (error) {
      _errorMessage = error.message;
      _isSaving = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Não foi possível salvar o objeto. Tente novamente.';
      _isSaving = false;
      notifyListeners();
      return false;
    }

    // Mantém isSaving ativo durante a recarga para impedir envios repetidos.
    try {
      _items = await _service.fetchItems();
    } on ItemServiceException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'O objeto foi salvo, mas não foi possível atualizar a lista. Puxe para atualizar.';
    } finally {
      _isSaving = false;
      notifyListeners();
    }

    return true;
  }
}
