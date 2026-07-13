import 'game_data_models.dart';
import 'rules_constants.dart';

/// An item instance carried by a character. Stored denormalized (like the
/// original app's 19-column equipment rows) so customized and homebrew items
/// survive independently of the game data.
class Item {
  String type; // Weapon | Armor | Personal Effect
  String name;
  String description;
  String shortDesc;
  String book;
  String page;
  int price;
  String unit; // koku | bu | zeni
  int rarity;
  List<String> qualities;
  // Weapon-only fields.
  String category;
  String skill;
  String grip;
  int rangeMin;
  int rangeMax;
  int damage;
  int deadliness;
  // Armor-only fields.
  int physicalResistance;
  int supernaturalResistance;

  Item({
    required this.type,
    required this.name,
    this.description = '',
    this.shortDesc = '',
    this.book = '',
    this.page = '',
    this.price = 0,
    this.unit = 'zeni',
    this.rarity = 0,
    this.qualities = const [],
    this.category = '',
    this.skill = '',
    this.grip = '',
    this.rangeMin = 0,
    this.rangeMax = 0,
    this.damage = 0,
    this.deadliness = 0,
    this.physicalResistance = 0,
    this.supernaturalResistance = 0,
  });

  bool get isWeapon => type == itemTypeWeapon;
  bool get isArmor => type == itemTypeArmor;

  /// Regroups consecutive per-grip rows of one weapon (as emitted by
  /// [Item.fromWeapon]) into a single group, so the UI and PDF can present
  /// one weapon with multiple grips. A repeated grip name starts a new group,
  /// keeping two copies of the same weapon separate.
  static List<List<Item>> gripGroups(Iterable<Item> weapons) {
    final groups = <List<Item>>[];
    for (final weapon in weapons) {
      final current = groups.isEmpty ? null : groups.last;
      if (current != null &&
          current.first.name == weapon.name &&
          !current.any((item) => item.grip == weapon.grip)) {
        current.add(weapon);
      } else {
        groups.add([weapon]);
      }
    }
    return groups;
  }

  /// Builds the weapon item for one grip, applying that grip's stat effects
  /// (the original app emits one row per grip).
  factory Item.fromWeapon(Weapon weapon, WeaponGrip grip) {
    var damage = weapon.damage;
    var deadliness = weapon.deadliness;
    var rangeMin = weapon.rangeMin;
    var rangeMax = weapon.rangeMax;
    final qualities = List.of(weapon.qualities);
    for (final effect in grip.effects) {
      final value = effect.value is int ? effect.value as int : 0;
      switch (effect.attribute) {
        case 'damage':
          damage += value;
        case 'deadliness':
          deadliness += value;
        case 'range':
          rangeMax += value;
        case 'quality':
          if (effect.value is String) qualities.add(effect.value as String);
      }
    }
    return Item(
      type: itemTypeWeapon,
      name: weapon.name,
      book: weapon.reference.book,
      page: weapon.reference.page,
      price: weapon.price.value,
      unit: weapon.price.unit,
      rarity: weapon.rarity,
      qualities: qualities,
      category: weapon.category,
      skill: weapon.skill,
      grip: grip.name,
      rangeMin: rangeMin,
      rangeMax: rangeMax,
      damage: damage,
      deadliness: deadliness,
    );
  }

  factory Item.fromArmor(Armor armor) {
    var physical = 0;
    var supernatural = 0;
    for (final resistance in armor.resistances) {
      if (resistance.category == 'Physical') physical = resistance.value;
      if (resistance.category == 'Supernatural') {
        supernatural = resistance.value;
      }
    }
    return Item(
      type: itemTypeArmor,
      name: armor.name,
      book: armor.reference.book,
      page: armor.reference.page,
      price: armor.price.value,
      unit: armor.price.unit,
      rarity: armor.rarity,
      qualities: List.of(armor.qualities),
      physicalResistance: physical,
      supernaturalResistance: supernatural,
    );
  }

  factory Item.fromPersonalEffect(PersonalEffect effect) => Item(
        type: itemTypePersonalEffect,
        name: effect.name,
        book: effect.reference.book,
        page: effect.reference.page,
        price: effect.price.value,
        unit: effect.price.unit,
        rarity: effect.rarity,
      );

  Item.fromJson(Map<String, dynamic> json)
      : type = json['type'] ?? itemTypePersonalEffect,
        name = json['name'] ?? '',
        description = json['description'] ?? '',
        shortDesc = json['short_desc'] ?? '',
        book = json['book'] ?? '',
        page = json['page']?.toString() ?? '',
        price = json['price'] ?? 0,
        unit = json['unit'] ?? 'zeni',
        rarity = json['rarity'] ?? 0,
        qualities = List<String>.from(json['qualities'] ?? []),
        category = json['category'] ?? '',
        skill = json['skill'] ?? '',
        grip = json['grip'] ?? '',
        rangeMin = json['range_min'] ?? 0,
        rangeMax = json['range_max'] ?? 0,
        damage = json['damage'] ?? 0,
        deadliness = json['deadliness'] ?? 0,
        physicalResistance = json['physical_resistance'] ?? 0,
        supernaturalResistance = json['supernatural_resistance'] ?? 0;

  Map<String, dynamic> toJson() => {
        'type': type,
        'name': name,
        'description': description,
        'short_desc': shortDesc,
        'book': book,
        'page': page,
        'price': price,
        'unit': unit,
        'rarity': rarity,
        'qualities': qualities,
        'category': category,
        'skill': skill,
        'grip': grip,
        'range_min': rangeMin,
        'range_max': rangeMax,
        'damage': damage,
        'deadliness': deadliness,
        'physical_resistance': physicalResistance,
        'supernatural_resistance': supernaturalResistance,
      };
}
