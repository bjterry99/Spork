import 'package:json_annotation/json_annotation.dart';
part 'models.g.dart';

// Run 'flutter pub run build_runner build' to create generated dart classes for firestore
// If regenerating file, remove .toIso8601String methods on dates. It will break when uploading to firebase

@JsonSerializable()
class Recipe {
  String id;
  String name;
  String className;
  String cookTime;
  String prepTime;
  List<String> ingredientAmounts;
  List<String> ingredients;
  List<String> instructions;
  List<String> menuIds;
  String creatorId;

  Recipe({
    required this.id,
    required this.name,
    this.className = 'Main',
    this.cookTime = '0:30',
    this.prepTime = '0:30',
    this.ingredientAmounts = const <String>[],
    this.ingredients = const <String>[],
    this.instructions = const <String>[],
    this.menuIds = const <String>[],
    this.creatorId = '',
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}

@JsonSerializable()
class Grocery {
  String id;
  String name;
  String amount;
  bool mark;
  String recipeId;
  String recipeName;
  String creatorId;
  List<String> homeIds;

  Grocery({
    required this.id,
    required this.name,
    this.amount = '',
    this.mark = false,
    this.recipeId = '',
    this.recipeName = '',
    this.creatorId = '',
    this.homeIds = const <String>[],
  });

  factory Grocery.fromJson(Map<String, dynamic> json) => _$GroceryFromJson(json);
  Map<String, dynamic> toJson() => _$GroceryToJson(this);
}

@JsonSerializable()
class AppUser {
  String id;
  String name;
  String userName;
  String phone;
  String photoUrl;
  List<String> followers;
  String homeId;

  AppUser({
    required this.id,
    required this.name,
    required this.userName,
    required this.phone,
    this.photoUrl = '',
    this.followers = const <String>[],
    this.homeId = '',
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppUserToJson(this);
}

@JsonSerializable()
class MyHome {
  String id;
  String name;
  List<String> users;

  MyHome({
    required this.id,
    required this.name,
    this.users = const <String>[],
  });

  factory MyHome.fromJson(Map<String, dynamic> json) => _$MyHomeFromJson(json);
  Map<String, dynamic> toJson() => _$MyHomeToJson(this);
}