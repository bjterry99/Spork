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
      savedIds: (json['savedIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      creatorId: json['creatorId'] as String? ?? '',
      queryName: json['queryName'] as String? ?? '',
      visibility: json['visibility'] as String? ?? 'private',
      photoUrl: json['photoUrl'] as String? ?? '',
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
      'savedIds': instance.savedIds,
      'creatorId': instance.creatorId,
      'queryName': instance.queryName,
      'visibility': instance.visibility,
      'photoUrl': instance.photoUrl,
    };

Grocery _$GroceryFromJson(Map<String, dynamic> json) => Grocery(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: json['amount'] as String? ?? '',
      mark: json['mark'] as bool? ?? false,
      recipeId: json['recipeId'] as String? ?? '',
      recipeName: json['recipeName'] as String? ?? '',
      creatorId: json['creatorId'] as String? ?? '',
      homeId: json['homeId'] as String? ?? '',
    );

Map<String, dynamic> _$GroceryToJson(Grocery instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'mark': instance.mark,
      'recipeId': instance.recipeId,
      'recipeName': instance.recipeName,
      'creatorId': instance.creatorId,
      'homeId': instance.homeId,
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
      homeId: json['homeId'] as String? ?? 'null',
      queryName: json['queryName'] as String? ?? '',
    );

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'userName': instance.userName,
      'phone': instance.phone,
      'photoUrl': instance.photoUrl,
      'followers': instance.followers,
      'homeId': instance.homeId,
      'queryName': instance.queryName,
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

HomeInvite _$HomeInviteFromJson(Map<String, dynamic> json) => HomeInvite(
      id: json['id'] as String,
      inviterId: json['inviterId'] as String,
      receiverId: json['receiverId'] as String,
      homeId: json['homeId'] as String,
    );

Map<String, dynamic> _$HomeInviteToJson(HomeInvite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inviterId': instance.inviterId,
      'receiverId': instance.receiverId,
      'homeId': instance.homeId,
    };
