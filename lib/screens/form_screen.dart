import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../state/item_store.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.store, this.item});

  final ItemStore store;
  final ItemModel? item;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _status = ItemModel.lostStatus;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();

    final item = widget.item;
    if (item == null) {
      return;
    }

    _nameController.text = item.name;
    _descriptionController.text = item.description;
    _locationController.text = item.location;
    _status = item.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (widget.store.isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final draft = ItemDraft(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      status: _status,
    );

    final success = _isEditing
        ? await widget.store.update(widget.item!.id, draft)
        : await widget.store.create(draft);

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.store.errorMessage ??
              (_isEditing
                  ? 'Não foi possível salvar as alterações. Tente novamente.'
                  : 'Não foi possível salvar. Tente novamente.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final isSaving = widget.store.isSaving;

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Editar Objeto' : 'Cadastrar Objeto'),
            centerTitle: true,
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        maxLength: 60,
                        enabled: !isSaving,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Nome do objeto',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Campo obrigatório';
                          }
                          if (value.trim().length > 60) {
                            return 'Máximo de 60 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        maxLength: 200,
                        maxLines: 3,
                        enabled: !isSaving,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Campo obrigatório';
                          }
                          if (value.trim().length > 200) {
                            return 'Máximo de 200 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        enabled: !isSaving,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Local',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: const InputDecoration(
                          labelText: 'Situação',
                          border: OutlineInputBorder(),
                        ),
                        items: ItemModel.statuses
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                        onChanged: isSaving
                            ? null
                            : (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  _status = value;
                                });
                              },
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: isSaving ? null : _saveItem,
                        child: isSaving
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary,
                                ),
                              )
                            : Text(_isEditing ? 'Salvar alterações' : 'Salvar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
