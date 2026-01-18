import 'package:hive/hive.dart';

part 'multicell.g.dart';

@HiveType(typeId: 1)
class MultiCell {
  @HiveField(0)
  late List<int> numbers;

  @HiveField(1)
  bool isMarked = false;

  MultiCell() {
    numbers = [];
    isMarked = false;
  }

  void addNumber(int num) {
    if (!numbers.contains(num)) {
      numbers.add(num);
      isMarked = false;
    }
  }

  void removeNumber(int num) {
    if (numbers.contains(num)) {
      numbers.remove(num);
      isMarked = false;
    }
  }

  void handleMarking() {
    if (numbers.length == 1) {
      isMarked = !isMarked;
    } else {
      isMarked = false;
    }
  }

  void clear() {
    numbers.clear(); //clear the list
    isMarked = false;
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
