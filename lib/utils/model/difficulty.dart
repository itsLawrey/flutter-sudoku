import 'package:hive/hive.dart';

part 'difficulty.g.dart';

@HiveType(typeId: 0)
enum Difficulty {
  @HiveField(0)
  easy(35),
  @HiveField(1)
  medium(30),
  @HiveField(2)
  hard(25);

  final int threshold;
  const Difficulty(this.threshold);
}
