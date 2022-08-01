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
    };

Grocery _$GroceryFromJson(Map<String, dynamic> json) => Grocery(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: json['amount'] as String? ?? '',
      mark: json['mark'] as bool? ?? false,
      recipeId: json['recipeId'] as String? ?? '',
      recipeName: json['recipeName'] as String? ?? '',
    );

Map<String, dynamic> _$GroceryToJson(Grocery instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'mark': instance.mark,
      'recipeId': instance.recipeId,
      'recipeName': instance.recipeName,
    };