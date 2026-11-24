// Lee y modifica componentes en la colección privada de cada usuario.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electrovault/domain/component.dart';

class ComponentDataSource {
  ComponentDataSource({
    required FirebaseFirestore database,
    required String userId,
  }) : _components = database
            .collection('users')
            .doc(userId)
            .collection('components')
            .withConverter<Component>(
              fromFirestore: Component.fromFirestore,
              toFirestore: (component, _) => component.toFirestore(),
            );

  final CollectionReference<Component> _components;

  Stream<List<Component>> watchComponents() => _components
      .orderBy('name')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((document) => document.data()).toList());

  Future<void> addComponent(Component component) async {
    final document = _components.doc();
    await document.set(component);
  }

  Future<void> updateComponent(Component component) =>
      _components.doc(component.id).set(component);

  Future<void> deleteComponent(String componentId) =>
      _components.doc(componentId).delete();
}
