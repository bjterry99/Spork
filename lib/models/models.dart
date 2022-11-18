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
  List<String> savedIds;
  List<String> homeIds;
  String creatorId;
  String queryName;
  String visibility;
  String photoUrl;
  String url;
  List<String> notes;
  List<String> notesCreators;
  dynamic createDate;
  dynamic editDate;

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
    this.savedIds = const <String>[],
    this.homeIds = const <String>[],
    this.creatorId = '',
    this.queryName = '',
    this.visibility = 'private',
    this.photoUrl = '',
    this.url = '',
    this.notes = const <String>[],
    this.notesCreators = const <String>[],
    this.createDate = '',
    this.editDate = '',
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
  String homeId;
  String creatorName;
  dynamic createDate;

  Grocery({
    required this.id,
    required this.name,
    this.amount = '',
    this.mark = false,
    this.recipeId = '',
    this.recipeName = '',
    this.creatorId = '',
    this.homeId = '',
    this.creatorName = '',
    this.createDate = '',
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
  String queryName;

  AppUser({
    required this.id,
    required this.name,
    required this.userName,
    required this.phone,
    this.photoUrl = '',
    this.followers = const <String>[],
    this.homeId = '',
    this.queryName = '',
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppUserToJson(this);
}

@JsonSerializable()
class MyHome {
  String id;
  String name;
  String creatorId;
  List<String> users;

  MyHome({
    required this.id,
    required this.name,
    required this.creatorId,
    this.users = const <String>[],
  });

  factory MyHome.fromJson(Map<String, dynamic> json) => _$MyHomeFromJson(json);
  Map<String, dynamic> toJson() => _$MyHomeToJson(this);
}

@JsonSerializable()
class HomeInvite {
  String id;
  String inviterId;
  String receiverId;
  String homeId;

  HomeInvite({
    required this.id,
    required this.inviterId,
    required this.receiverId,
    required this.homeId,
  });

  factory HomeInvite.fromJson(Map<String, dynamic> json) => _$HomeInviteFromJson(json);
  Map<String, dynamic> toJson() => _$HomeInviteToJson(this);
}