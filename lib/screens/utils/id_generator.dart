
class IDGenerator {
  static Future<int> generateUniqueId(Function(int) idExists) async {
    int id;
    do {
      id = DateTime
          .now()
          .millisecondsSinceEpoch;
    } while (await idExists(id));
    return id;
  }
}

