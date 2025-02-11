

bool isValid(String? value) {
  return value != null && value.isNotEmpty;
} 

extension FindStuff<T> on List<T> {
  T? goodFirstWhere(bool Function(T item) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}