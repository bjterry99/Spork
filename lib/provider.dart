import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spork/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class AppProvider extends ChangeNotifier {
  PreferredSizeWidget getZeroAppBar(Color color) {
    return Platform.isAndroid ? PreferredSize(
      preferredSize: Size.zero,
      child: AppBar(
        elevation: 0,
        backgroundColor: color,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: color,
          statusBarIconBrightness:
          color == CustomColors.primary ? Brightness.light : Brightness.dark,
        ),
      ),
    ) : PreferredSize(
      preferredSize: Size.zero,
      child: AppBar(
        elevation: 0,
        backgroundColor: color,
      ),
    );
  }

  Future<void> addToMenu(QueryDocumentSnapshot recipe) async {
    NotificationService.notify('Adding to menu...');

    try {
      var menuRef = _firestore.collection('menu').doc(recipe.id);
      await menuRef.set({
        "id": recipe.id,
        "name": recipe['name'],
        "class": recipe['class'],
        "cookTime": recipe['cookTime'],
        "prepTime": recipe['prepTime'],
        "ingredient_amounts": recipe['ingredient_amounts'],
        "ingredients": recipe['ingredients'],
        "instructions": recipe['instructions'],
      });

      for (int i = 0; i < recipe['ingredients'].length; i++) {
        var ref = _firestore.collection('grocery').doc();
        await ref.set({
          "id": ref.id,
          "name": recipe['ingredients'][i],
          "amount": recipe['ingredient_amounts'][i],
          "recipeName": recipe['name'],
          "recipeId": recipe.id,
          "recipeItem": true,
          "mark": false,
        });
      }

      NotificationService.notify('Added to menu.');
    } catch (error) {
      NotificationService.notify('Failed to add to menu.');
    }
  }

  Future<void> removeFromMenu(QueryDocumentSnapshot recipe) async {
    NotificationService.notify('Removing from menu...');

    try {
      var collection = await _firestore.collection('grocery').where('recipeId', isEqualTo: recipe.id).get();
      for (var item in collection.docs) {
        await _firestore.collection('grocery').doc(item.id).delete();
      }

      await _firestore.collection('menu').doc(recipe.id).delete();

      NotificationService.notify('Removed from menu.');
    } catch (error) {
      NotificationService.notify('Failed to remove from menu.');
    }
  }

  Future<void> deleteRecipe(QueryDocumentSnapshot recipe) async {
    NotificationService.notify('Deleting recipe...');

    try {
      await _firestore.collection('recipes').doc(recipe.id).delete();

      var menuDoc = await _firestore.collection('menu').doc(recipe.id).get();
      if (menuDoc.exists) {
        await _firestore.collection('menu').doc(recipe.id).delete();
      }

      var collection = await _firestore.collection('grocery').where('recipeId', isEqualTo: recipe.id).get();
      for (var item in collection.docs) {
        await _firestore.collection('grocery').doc(item.id).delete();
      }

      NotificationService.notify('Recipe deleted.');
    } catch (error) {
      NotificationService.notify('Failed to delete recipe.');
    }
  }

  Future<void> createRecipe(String recipeName, String recipeClass, String cookTime, String prepTime,
      List<String> recipeAmounts, List<String> recipeIngredients, List<String> recipeInstructions) async {
    NotificationService.notify('Creating recipe...');

    try {
      var recipeRef = _firestore.collection('recipes').doc();
      await recipeRef.set({
        "id": recipeRef.id,
        "name": recipeName,
        "class": recipeClass,
        "cookTime": cookTime,
        "prepTime": prepTime,
        "ingredient_amounts": recipeAmounts,
        "ingredients": recipeIngredients,
        "instructions": recipeInstructions,
      });

      NotificationService.notify('Recipe created.');
    } catch (error) {
      NotificationService.notify('Failed to create recipe.');
    }
  }

  Future<void> updateRecipe(QueryDocumentSnapshot recipe, String recipeName, String recipeClass, String cookTime, String prepTime,
      List<String> recipeAmounts, List<String> recipeIngredients, List<String> recipeInstructions) async {
    NotificationService.notify('Updating recipe...');

    try {
      var recipeRef = _firestore.collection('recipes').doc(recipe.id);
      await recipeRef.update({
        "id": recipeRef.id,
        "name": recipeName,
        "class": recipeClass,
        "cookTime": cookTime,
        "prepTime": prepTime,
        "ingredient_amounts": recipeAmounts,
        "ingredients": recipeIngredients,
        "instructions": recipeInstructions,
      });

      var menuDoc = await _firestore.collection('menu').doc(recipe.id).get();
      if (menuDoc.exists) {
        var menuRef = _firestore.collection('menu').doc(recipe.id);
        await menuRef.update({
          "id": menuRef.id,
          "name": recipeName,
          "class": recipeClass,
          "cookTime": cookTime,
          "prepTime": prepTime,
          "ingredient_amounts": recipeAmounts,
          "ingredients": recipeIngredients,
          "instructions": recipeInstructions,
        });
      }

      NotificationService.notify('Recipe updated.');
    } catch (error) {
      NotificationService.notify('Failed to update recipe.');
    }
  }

  // Future<DocumentSnapshot<Map<String, dynamic>>> getRecipe(String id) async {
  //   DocumentSnapshot<Map<String, dynamic>> recipe = await _firestore.collection('recipes').doc(id).get();
  //   return recipe;
  // }
  // FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
  // future: Provider.of<AppProvider>(context, listen: false)
  //     .getRecipe(item['recipeId']),
  // builder: (context, snapshot) {
  // if (snapshot.hasError) {
  // return const SizedBox();
  // } else if (snapshot.hasData) {
  // var recipe = snapshot.data!.data();
  //
  // return Text(
  // recipe!['name'],
  // style: const TextStyle(
  // color: CustomColors.grey4,
  // fontSize: CustomFontSize.secondary,
  // fontWeight: FontWeight.w300),
  // );
  // }
  // return const SizedBox();
  // },
  // );

  // Future<bool> addToGrocery(QueryDocumentSnapshot item) async {
  //   var doc = await _firestore.collection('grocery').doc(item.id).get();
  //   if (doc.exists) {
  //     return false;
  //   } else {
  //     var ref = _firestore.collection('menu').doc(item.id);
  //     await ref.set({
  //       "id": recipe.id,
  //       "name": recipe['name'],
  //       "class": recipe['class'],
  //       "cookTime": recipe['cookTime'],
  //       "ingredient_amounts": recipe['ingredient_amounts'],
  //       "ingredients": recipe['ingredients'],
  //       "instructions": recipe['instructions'],
  //     });
  //     return true;
  //   }
  // }
  //
  // Future<bool> removeFromGrocery(QueryDocumentSnapshot recipe) async {
  //   var doc = await _firestore.collection('menu').doc(recipe.id).get();
  //   if (doc.exists) {
  //     await _firestore.collection('menu').doc(recipe.id).delete();
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }
}

class NotificationService {
  static GlobalKey<ScaffoldMessengerState> key = GlobalKey<ScaffoldMessengerState>();

  static void notify(String message) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(message),
      duration: const Duration(seconds: 1),
    );

    if (key.currentState != null) {
      key.currentState!
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }
}