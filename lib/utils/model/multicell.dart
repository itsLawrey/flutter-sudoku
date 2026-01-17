import 'package:hive/hive.dart';

part 'multicell.g.dart';

@HiveType(typeId: 1)
class MultiCell {
  @HiveField(0)
  late List<int> numbers;

  MultiCell() {
    numbers = [];
  }

  void addNumber(int num) {
    if (!numbers.contains(num)) {
      numbers.add(num);
    }
  }

  void removeNumber(int num) {
    if (numbers.contains(num)) {
      numbers.remove(num);
    }
  }

  void clear() {
    numbers.clear(); //clear the list
  }

  bool get isEmpty => numbers.isEmpty;
  bool get isNotEmpty => numbers.isNotEmpty;

  bool contains(int num) => numbers.contains(num);

  @override
  String toString() {
    if (numbers.isEmpty) return "0";
    if (numbers.length == 1) return numbers.first.toString();
    return numbers.toString();
  }
}
