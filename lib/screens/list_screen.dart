import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../state/item_store.dart';
import 'form_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key, required this.store});

  final ItemStore store;

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  @override
  void initState() {
    super.initState();
    widget.store.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final store = widget.store;
        final items = store.items;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Achados e Perdidos'),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: 'Atualizar',
                icon: const Icon(Icons.refresh),
                onPressed: store.load,
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: store.load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 88),
                      children: [
                        if (store.errorMessage != null && items.isEmpty)
                          _ErrorState(
                            message: store.errorMessage!,
                            onRetry: store.load,
                          )
                        else if (items.isEmpty && !store.isLoading)
                          const _EmptyState()
                        else ...[
                          if (store.errorMessage != null)
                            _ErrorBanner(
                              message: store.errorMessage!,
                              onRetry: store.load,
                            ),
                          ...items.map((item) => _ItemCard(item: item)),
                        ],
                      ],
                    ),
                  ),
                  if (store.isLoading && items.isEmpty)
                    const Center(child: CircularProgressIndicator()),
                  if (store.isLoading && items.isNotEmpty)
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormScreen(store: widget.store),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    final isLost = item.isLost;
    final statusColor = isLost
        ? Theme.of(context).colorScheme.errorContainer
        : Theme.of(context).colorScheme.tertiaryContainer;
    final onStatusColor = isLost
        ? Theme.of(context).colorScheme.onErrorContainer
        : Theme.of(context).colorScheme.onTertiaryContainer;
    final statusIcon = isLost ? Icons.search_off : Icons.check_circle_outline;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    style: Theme.of(context).textTheme.titleMedium,
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
                  avatar: Icon(statusIcon, size: 18, color: onStatusColor),
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
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(item.createdAt),
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar',
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Excluir',
                  color: Theme.of(context).colorScheme.error,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} '
        'às ${two(local.hour)}:${two(local.minute)}';
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => onRetry(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      color: colors.errorContainer,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ListTile(
        leading: Icon(Icons.error_outline, color: colors.onErrorContainer),
        title: Text(message, style: TextStyle(color: colors.onErrorContainer)),
        trailing: IconButton(
          tooltip: 'Tentar novamente',
          icon: Icon(Icons.refresh, color: colors.onErrorContainer),
          onPressed: () => onRetry(),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}
