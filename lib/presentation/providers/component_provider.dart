// Mantiene la lista en tiempo real y coordina las operaciones ABM.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electrovault/datasource/component_datasource.dart';
import 'package:electrovault/domain/component.dart';

final componentDataSourceProvider = Provider.family<ComponentDataSource, String>(
  (ref, userId) => ComponentDataSource(
    database: FirebaseFirestore.instance,
    userId: userId,
  ),
);

final componentsProvider = StateNotifierProvider.autoDispose.family<
    ComponentsNotifier, AsyncValue<List<Component>>, String>((ref, userId) {
  return ComponentsNotifier(ref.watch(componentDataSourceProvider(userId)));
});

class ComponentsNotifier extends StateNotifier<AsyncValue<List<Component>>> {
  ComponentsNotifier(this._dataSource) : super(const AsyncLoading()) {
    _subscription = _dataSource.watchComponents().listen(
      (components) => state = AsyncData(components),
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncError(error, stackTrace);
      },
    );
  }

  final ComponentDataSource _dataSource;
  late final StreamSubscription<List<Component>> _subscription;

  Future<void> add(Component component) => _dataSource.addComponent(component);

  Future<void> update(Component component) =>
      _dataSource.updateComponent(component);

  Future<void> delete(String componentId) =>
      _dataSource.deleteComponent(componentId);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
