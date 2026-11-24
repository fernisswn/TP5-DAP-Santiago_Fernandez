// Representa un componente electrónico almacenado en Cloud Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';

class Component {
  const Component({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.manufacturer,
    required this.model,
    required this.packageType,
    required this.specifications,
    required this.operatingVoltage,
    required this.current,
    required this.datasheetUrl,
    required this.quantity,
    required this.location,
    required this.price,
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final String manufacturer;
  final String model;
  final String packageType;
  final String specifications;
  final String operatingVoltage;
  final String current;
  final String datasheetUrl;
  final int quantity;
  final String location;
  final double? price;

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'category': category,
        'manufacturer': manufacturer,
        'model': model,
        'packageType': packageType,
        'specifications': specifications,
        'operatingVoltage': operatingVoltage,
        'current': current,
        'datasheetUrl': datasheetUrl,
        'quantity': quantity,
        'location': location,
        'price': price,
      };

  static Component fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};

    return Component(
      id: snapshot.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      category: data['category'] as String? ?? '',
      manufacturer: data['manufacturer'] as String? ?? '',
      model: data['model'] as String? ?? '',
      packageType: data['packageType'] as String? ?? '',
      specifications: data['specifications'] as String? ?? '',
      operatingVoltage: data['operatingVoltage'] as String? ?? '',
      current: data['current'] as String? ?? '',
      datasheetUrl: data['datasheetUrl'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      location: data['location'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble(),
    );
  }
}
