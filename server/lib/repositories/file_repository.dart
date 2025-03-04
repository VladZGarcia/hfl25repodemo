import 'dart:convert';
import 'dart:io';

abstract class FileRepository<T> {
  final String filePath;
  FileRepository(this.filePath);

  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(T item);

  String idFromType(T item);
  String simpleIdFromType(T item);

  Future<List<T>> readFile() async {
    final file = File(filePath);
    if (!await file.exists()) {
      await file.writeAsString('[]');
      return <T>[];
    }
    final content = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(content);
    return jsonList.map<T>((json) => fromJson(json)).toList();
  }

  //skriver till fil
  Future<void> writeFile(List<T> items) async {
    final file = File(filePath);
    final jsonList = items.map((item) => toJson(item)).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  // Lägger till item
  Future<T> add(T item) async {
    var items = await readFile();
    items.add(item);
    await writeFile(items);
    return item;
  }

  Future<List<T>> getAll() async {
    var items = await readFile();
    return items;
  }

  Future<T?> getById(String id) async {
    var items = await readFile();
    for (var item in items) {
      if (idFromType(item) == id) {
        return item;
      }
    }
    return null;
  }

  Future<T> update(String id, T newItem) async {
    var items = await readFile();
    for (var i = 0; i < items.length; i++) {
      if (idFromType(items[i]) == id) {
        items[i] = newItem;
        await writeFile(items);
        return newItem;
      }
    }
    throw Exception('Item not found');
  }

  Future<T> delete(String id) async {
    var items = await readFile();
    for (var i = 0; i < items.length; i++) {
      if (idFromType(items[i]) == id) {
        var removedItem = items.removeAt(i);
        await writeFile(items);
        return removedItem;
      }
    }
    throw Exception('Item not found');
  }
}
