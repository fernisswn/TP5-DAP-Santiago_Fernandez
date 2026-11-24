// Muestra el inventario en vivo y permite abrir, editar y eliminar componentes.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electrovault/domain/component.dart';
import 'package:electrovault/presentation/providers/auth_provider.dart';
import 'package:electrovault/presentation/providers/component_provider.dart';
import 'package:electrovault/presentation/screens/component_detail_screen.dart';
import 'package:electrovault/presentation/screens/component_form_screen.dart';

class ComponentsScreen extends ConsumerWidget {
  const ComponentsScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(componentsProvider(user.uid));
    final displayName = user.displayName?.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ElectroVault'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inventario', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(displayName == null || displayName.isEmpty ? user.email ?? 'Tus componentes' : 'Hola, $displayName'),
                ],
              ),
            ),
            Expanded(
              child: state.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _MessageState(
                  icon: Icons.cloud_off_outlined,
                  title: 'No se pudo cargar el inventario',
                  message: error.toString(),
                  action: TextButton.icon(
                    onPressed: () => ref.invalidate(componentsProvider(user.uid)),
                    icon: const Icon(Icons.refresh), label: const Text('Reintentar'),
                  ),
                ),
                data: (components) => components.isEmpty
                    ? _MessageState(
                        icon: Icons.memory_outlined,
                        title: 'Tu inventario está vacío',
                        message: 'Agregá tu primer componente para empezar a organizarlo.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: components.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _ComponentTile(
                          component: components[index],
                          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                            builder: (_) => ComponentDetailScreen(userId: user.uid, componentId: components[index].id),
                          )),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => ComponentFormScreen(userId: user.uid),
        )),
        icon: const Icon(Icons.add), label: const Text('Agregar componente'),
      ),
    );
  }
}

class _ComponentTile extends StatelessWidget {
  const _ComponentTile({required this.component, required this.onTap});
  final Component component;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = [component.category, component.manufacturer, component.model]
        .where((value) => value.trim().isNotEmpty).join(' · ');
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: _ComponentImage(url: component.imageUrl, size: 54),
        title: Text(component.name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle.isEmpty ? 'Sin categoría' : subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const Text('Stock'), Text('${component.quantity}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))],
        ),
      ),
    );
  }
}

class _ComponentImage extends StatelessWidget {
  const _ComponentImage({required this.url, this.size = 180});
  final String url;
  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: size, height: size, color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: url.trim().isEmpty
              ? const Icon(Icons.memory_outlined, size: 32)
              : Image.network(url, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined, size: 32)),
        ),
      );
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.title, required this.message, this.action});
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 12), action!],
          ]),
        ),
      );
}
