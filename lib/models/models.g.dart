// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      className: json['className'] as String? ?? 'Main',
      cookTime: json['cookTime'] as String? ?? '0:30',
      prepTime: json['prepTime'] as String? ?? '0:30',
      ingredientAmounts: (json['ingredientAmounts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      menuIds: (json['menuIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      creatorId: json['creatorId'] as String? ?? '',
    );

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'className': instance.className,
      'cookTime': instance.cookTime,
      'prepTime': instance.prepTime,
      'ingredientAmounts': instance.ingredientAmounts,
      'ingredients': instance.ingredients,
      'instructions': instance.instructions,
      'menuIds': instance.menuIds,
      'creatorId': instance.creatorId,
    };

Grocery _$GroceryFromJson(Map<String, dynamic> json) => Grocery(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: json['amount'] as String? ?? '',
      mark: json['mark'] as bool? ?? false,
      recipeId: json['recipeId'] as String? ?? '',
      recipeName: json['recipeName'] as String? ?? '',
      creatorId: json['creatorId'] as String? ?? '',
      homeIds: (json['homeIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$GroceryToJson(Grocery instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'mark': instance.mark,
      'recipeId': instance.recipeId,
      'recipeName': instance.recipeName,
      'creatorId': instance.creatorId,
      'homeIds': instance.homeIds,
    };

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      userName: json['userName'] as String,
      phone: json['phone'] as String,
      photoUrl: json['photoUrl'] as String? ?? '',
      followers: (json['followers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      homeId: json['homeId'] as String? ?? '',
    );

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'userName': instance.userName,
      'phone': instance.phone,
      'photoUrl': instance.photoUrl,
      'followers': instance.followers,
      'homeId': instance.homeId,
    };

MyHome _$MyHomeFromJson(Map<String, dynamic> json) => MyHome(
      id: json['id'] as String,
      name: json['name'] as String,
      creatorId: json['creatorId'] as String,
      users:
          (json['users'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
    );

Map<String, dynamic> _$MyHomeToJson(MyHome instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'creatorId': instance.creatorId,
      'users': instance.users,
    };
