import 'dart:collection';
import 'dart:math';

import 'package:equatable/equatable.dart';

/// Got this from very godo ranch
class Rarity<T> extends Equatable {
  const Rarity(this.value, this.weight);

  final T value;

  final int weight;

  @override
  List<Object?> get props => [value, weight];
}

class RarityList<T> {
  RarityList(List<Rarity<T>> rarities)
      : _rarities = rarities..sort((a, b) => a.weight < b.weight ? 1 : -1),
        assert(
          rarities.fold<int>(0, _raritySum) == 1000,
          '''
The sum of the rarities weight has to equal 1000: ${rarities.fold<int>(0, _raritySum)}''',
        ) {
    _probabilities = _rarities.map((rare) {
      final filler = 1000 - _rarities.fold<int>(0, _raritySum);
      return List.filled(rare.weight == 0 ? filler : rare.weight, rare);
    }).fold<List<Rarity<T>>>(<Rarity<T>>[], (p, e) => p..addAll(e));
  }

  List<Rarity<T>> get rarities => UnmodifiableListView(_rarities);
  late final List<Rarity<T>> _rarities;

  List<Rarity<T>> get probabilities => UnmodifiableListView(_probabilities);
  late final List<Rarity<T>> _probabilities;

  T getRandom([Random? rnd]) {
    final index = (rnd ?? Random()).nextInt(1000);
    return _probabilities[index].value;
  }

  static int _raritySum<T>(int sum, Rarity<T> rarity) => sum + rarity.weight;
}
