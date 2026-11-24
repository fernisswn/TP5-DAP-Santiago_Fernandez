// Valida y guarda un componente nuevo o sus cambios en Cloud Firestore.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electrovault/domain/component.dart';
import 'package:electrovault/presentation/providers/component_provider.dart';

class ComponentFormScreen extends ConsumerStatefulWidget {
  const ComponentFormScreen({super.key, required this.userId, this.component});
  final String userId;
  final Component? component;

  @override
  ConsumerState<ComponentFormScreen> createState() => _ComponentFormScreenState();
}

class _ComponentFormScreenState extends ConsumerState<ComponentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _fields;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.component;
    _fields = {
      'name': TextEditingController(text: item?.name ?? ''),
      'description': TextEditingController(text: item?.description ?? ''),
      'imageUrl': TextEditingController(text: item?.imageUrl ?? ''),
      'category': TextEditingController(text: item?.category ?? ''),
      'manufacturer': TextEditingController(text: item?.manufacturer ?? ''),
      'model': TextEditingController(text: item?.model ?? ''),
      'packageType': TextEditingController(text: item?.packageType ?? ''),
      'specifications': TextEditingController(text: item?.specifications ?? ''),
      'operatingVoltage': TextEditingController(text: item?.operatingVoltage ?? ''),
      'current': TextEditingController(text: item?.current ?? ''),
      'datasheetUrl': TextEditingController(text: item?.datasheetUrl ?? ''),
      'quantity': TextEditingController(text: item == null ? '0' : '${item.quantity}'),
      'location': TextEditingController(text: item?.location ?? ''),
      'price': TextEditingController(text: item?.price?.toString() ?? ''),
    };
  }

  @override
  void dispose() { for (final field in _fields.values) { field.dispose(); } super.dispose(); }

  String _value(String key) => _fields[key]!.text.trim();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final original = widget.component;
    final item = Component(
      id: original?.id ?? '', name: _value('name'), description: _value('description'),
      imageUrl: _value('imageUrl'), category: _value('category'), manufacturer: _value('manufacturer'),
      model: _value('model'), packageType: _value('packageType'), specifications: _value('specifications'),
      operatingVoltage: _value('operatingVoltage'), current: _value('current'), datasheetUrl: _value('datasheetUrl'),
      quantity: int.parse(_value('quantity')), location: _value('location'),
      price: _value('price').isEmpty ? null : double.parse(_value('price').replaceAll(',', '.')),
    );
    try {
      final notifier = ref.read(componentsProvider(widget.userId).notifier);
      if (original == null) { await notifier.add(item); } else { await notifier.update(item); }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo guardar el componente: $error')));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.component == null ? 'Nuevo componente' : 'Editar componente')),
        body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(20), children: [
          _field('name', 'Nombre *', required: true, capitalization: TextCapitalization.sentences),
          _field('description', 'Descripción *', required: true, lines: 3),
          _field('imageUrl', 'URL de imagen *', required: true, keyboard: TextInputType.url),
          _field('category', 'Categoría *', required: true, capitalization: TextCapitalization.words),
          _field('manufacturer', 'Fabricante *', required: true),
          _field('model', 'Modelo'),
          _field('packageType', 'Encapsulado'),
          _field('specifications', 'Especificaciones', lines: 3),
          Row(children: [Expanded(child: _field('operatingVoltage', 'Tensión')), const SizedBox(width: 12), Expanded(child: _field('current', 'Corriente'))]),
          _field('datasheetUrl', 'URL del datasheet', keyboard: TextInputType.url),
          Row(children: [Expanded(child: _field('quantity', 'Cantidad *', keyboard: TextInputType.number, required: true, isInteger: true)), const SizedBox(width: 12), Expanded(child: _field('price', 'Precio unitario', keyboard: const TextInputType.numberWithOptions(decimal: true), isDecimal: true))]),
          _field('location', 'Ubicación'),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: _saving ? null : _save, icon: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined), label: Text(_saving ? 'Guardando…' : 'Guardar')),
          const SizedBox(height: 20),
        ])),
      );

  Widget _field(String key, String label, {bool required = false, int lines = 1, TextInputType? keyboard, TextCapitalization capitalization = TextCapitalization.none, bool isInteger = false, bool isDecimal = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          controller: _fields[key], keyboardType: keyboard, textCapitalization: capitalization, minLines: lines, maxLines: lines,
          decoration: InputDecoration(labelText: label),
          validator: (value) {
            final text = value?.trim() ?? '';
            if (required && text.isEmpty) return 'Este campo es obligatorio.';
            if (isInteger && text.isNotEmpty) {
              final number = int.tryParse(text);
              if (number == null) return 'Ingresá un número entero.';
              if (number < 0) return 'La cantidad no puede ser negativa.';
            }
            if (isDecimal && text.isNotEmpty) {
              final number = double.tryParse(text.replaceAll(',', '.'));
              if (number == null) return 'Ingresá un número válido.';
              if (number < 0) return 'El precio no puede ser negativo.';
            }
            if ((key == 'imageUrl' || key == 'datasheetUrl') && text.isNotEmpty) {
              final uri = Uri.tryParse(text);
              if (uri == null || !uri.hasScheme || !['http', 'https'].contains(uri.scheme) || uri.host.isEmpty) {
                return 'Ingresá una URL http o https válida.';
              }
            }
            return null;
          },
        ),
      );
}
