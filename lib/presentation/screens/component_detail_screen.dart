// Presenta el detalle de un componente y ofrece sus acciones de edición y baja.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electrovault/domain/component.dart';
import 'package:electrovault/presentation/providers/component_provider.dart';
import 'package:electrovault/presentation/screens/component_form_screen.dart';

class ComponentDetailScreen extends ConsumerWidget {
  const ComponentDetailScreen({super.key, required this.userId, required this.componentId});
  final String userId;
  final String componentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(componentsProvider(userId));
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del componente')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('No se pudo cargar el componente: $error'))),
        data: (items) {
          final matches = items.where((item) => item.id == componentId);
          if (matches.isEmpty) return const Center(child: Text('El componente ya no está disponible.'));
          final component = matches.first;
          return _DetailBody(userId: userId, component: component);
        },
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.userId, required this.component});
  final String userId;
  final Component component;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _DetailImage(url: component.imageUrl),
          const SizedBox(height: 18),
          Text(component.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          if (component.description.isNotEmpty) ...[const SizedBox(height: 8), Text(component.description)],
          const SizedBox(height: 20),
          _DetailSection(title: 'Identificación', values: {
            'Categoría': component.category, 'Fabricante': component.manufacturer,
            'Modelo': component.model, 'Encapsulado': component.packageType,
          }),
          _DetailSection(title: 'Datos técnicos', values: {
            'Especificaciones': component.specifications, 'Tensión de operación': component.operatingVoltage,
            'Corriente': component.current,
          }),
          _DetailSection(title: 'Inventario', values: {
            'Cantidad': '${component.quantity}', 'Ubicación': component.location,
            'Precio unitario': component.price == null ? '' : component.price!.toStringAsFixed(2),
          }),
          if (component.datasheetUrl.isNotEmpty) _DetailSection(title: 'Documentación', values: {'Datasheet': component.datasheetUrl}),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ComponentFormScreen(userId: userId, component: component))),
            icon: const Icon(Icons.edit_outlined), label: const Text('Editar componente'),
          ),
          OutlinedButton.icon(
            onPressed: () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_outline), label: const Text('Eliminar componente'),
          ),
        ],
      );

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Eliminar componente'),
      content: Text('¿Querés eliminar “${component.name}” del inventario?'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar'))],
    ));
    if (confirm != true) return;
    try {
      await ref.read(componentsProvider(userId).notifier).delete(component.id);
      if (context.mounted) Navigator.of(context).pop();
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $error')));
    }
  }
}

class _DetailImage extends StatelessWidget {
  const _DetailImage({required this.url});
  final String url;
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: url.trim().isEmpty
                ? const Icon(Icons.memory_outlined, size: 56)
                : Image.network(url, fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined, size: 56)),
          ),
        ),
      );
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.values});
  final String title;
  final Map<String, String> values;
  @override
  Widget build(BuildContext context) {
    final visible = values.entries.where((entry) => entry.value.trim().isNotEmpty).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(
      padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...visible.map((entry) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 135, child: Text(entry.key, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
          Expanded(child: SelectableText(entry.value)),
        ]))),
      ]),
    ));
  }
}
