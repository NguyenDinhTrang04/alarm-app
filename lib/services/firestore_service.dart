import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class FirestoreService {
  final CollectionReference itemsCollection =
      FirebaseFirestore.instance.collection('items');

  Future<void> addItem(Item item) async {
    await itemsCollection.doc(item.id).set(item.toMap());
  }

  Stream<List<Item>> getItems() {
    return itemsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Item.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
