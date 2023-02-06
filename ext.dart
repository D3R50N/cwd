extension OE on Object {
  List keys(obj) {
    return obj.keys.toList();
  }
}

extension SE on String {
  String charAt(int index) {
    return split("")[index];
  }
}
