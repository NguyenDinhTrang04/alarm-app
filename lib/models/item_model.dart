class Item {
  final String id;
  final String name;

  Item({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {'name': name};
  }

  static Item fromMap(String id, Map<String, dynamic> map) {
    return Item(id: id, name: map['name']);
  }
}
