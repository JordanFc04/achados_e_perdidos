import 'package:flutter/material.dart';

import '../models/item_model.dart';
import 'form_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final List<ItemModel> items = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      errorMessage = 'Não foi possível carregar os objetos. Verifique sua conexão e tente novamente.';
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achados e Perdidos'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: loadItems,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: loadItems,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 88),
                  children: [
                    if (errorMessage != null)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: loadItems,
                                  child: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else if (items.isEmpty && !isLoading)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              const Text('Nenhum objeto cadastrado ainda'),
                            ],
                          ),
                        ),
                      )
                    else
                      ...items.map((item) {
                        final isLost = item.status == 'Perdido';

                        final statusColor = isLost
                            ? Theme.of(context).colorScheme.errorContainer
                            : Theme.of(context).colorScheme.tertiaryContainer;
                        final onStatusColor = isLost
                            ? Theme.of(context).colorScheme.onErrorContainer
                            : Theme.of(context).colorScheme.onTertiaryContainer;
                        final statusIcon = isLost
                            ? Icons.search_off
                            : Icons.check_circle_outline;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Chip(
                                      label: Text(
                                        item.status,
                                        style: TextStyle(color: onStatusColor),
                                      ),
                                      avatar: Icon(
                                        statusIcon,
                                        size: 18,
                                        color: onStatusColor,
                                      ),
                                      backgroundColor: statusColor,
                                      side: BorderSide.none,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.place_outlined, size: 16),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(item.location)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(item.description),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
              if (isLoading && items.isEmpty)
                const Center(child: CircularProgressIndicator()),
              if (isLoading && items.isNotEmpty)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo objeto',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormScreen()),
          );
          if (mounted) loadItems();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
