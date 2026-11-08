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
  bool _isDeleting = false;
  String? _errorMessage;

  UnmodifiableListView<ItemModel> get items => UnmodifiableListView(_items);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    if (_isLoading || _isSaving || _isDeleting) {
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

  Future<bool> create(ItemDraft draft) {
    return _save(
      action: () => _service.createItem(draft),
      fallbackError: 'Não foi possível salvar o objeto. Tente novamente.',
      reloadError: 'O objeto foi salvo, mas não foi possível atualizar a lista. Puxe para atualizar.',
    );
  }

  Future<bool> update(String id, ItemDraft draft) {
    return _save(
      action: () => _service.updateItem(id, draft),
      fallbackError: 'Não foi possível atualizar o objeto. Tente novamente.',
      reloadError: 'O objeto foi atualizado, mas não foi possível atualizar a lista. Puxe para atualizar.',
    );
  }

  Future<bool> delete(String id) async {
    if (_isDeleting || _isSaving) {
      return false;
    }

    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteItem(id);
    } on ItemServiceException catch (error) {
      _errorMessage = error.message;
      _isDeleting = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Não foi possível excluir o objeto. Tente novamente.';
      _isDeleting = false;
      notifyListeners();
      return false;
    }

    // Remove localmente antes da recarga para o card sumir mesmo se a
    // atualização da lista falhar.
    _items = _items.where((item) => item.id != id).toList(growable: false);

    // Mantém isDeleting ativo durante a recarga para impedir ações repetidas.
    try {
      _items = await _service.fetchItems();
    } on ItemServiceException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'O objeto foi excluído, mas não foi possível atualizar a lista. Puxe para atualizar.';
    } finally {
      _isDeleting = false;
      notifyListeners();
    }

    return true;
  }

  Future<bool> _save({
    required Future<void> Function() action,
    required String fallbackError,
    required String reloadError,
  }) async {
    if (_isSaving || _isDeleting) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
    } on ItemServiceException catch (error) {
      _errorMessage = error.message;
      _isSaving = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = fallbackError;
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
      _errorMessage = reloadError;
    } finally {
      _isSaving = false;
      notifyListeners();
    }

    return true;
  }
}
