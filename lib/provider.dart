import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spork/models/models.dart';
import 'package:spork/notification_service.dart';
import 'package:spork/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class AppProvider extends ChangeNotifier {
  AppProvider() {
    _subscribeStreams();
  }

  /// Widgets ///

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

  /// Streams ///

  final List<StreamSubscription> _subscriptions = [];
  void subscribe(StreamSubscription subscription) => _subscriptions.add(subscription);

  var fireUser = _auth.currentUser;

  void _subscribeStreams() {
    // Firebase User Stream
    subscribe(_auth.authStateChanges().listen((data) {
      fireUser = data;
      notifyListeners();
    }, onError: (error) {
      NotificationService.notify("Failed to get authentication data.");
    }));
  }

  Stream<List<Recipe>> recipeStream = _firestore.collection('recipes').snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => Recipe.fromJson(doc.data()))
      .toList());

  Stream<List<Recipe>> menuStream = _firestore.collection('menu').snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => Recipe.fromJson(doc.data()))
      .toList());

  Stream<List<Grocery>> groceryStream = _firestore.collection('grocery').snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => Grocery.fromJson(doc.data()))
      .toList());

  Stream<QuerySnapshot<Object?>> specificMenuItem(String id) {
    return _firestore.collection('menu').where('id', isEqualTo: id).snapshots();
  }

  /// Functions ///

  // User Stuff //

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> createAccount(AppUser appUser) async {
    try {
      var userRef = _firestore.collection('users').doc();
      appUser.id = userRef.id;
      await userRef.set(appUser.toJson());

      NotificationService.notify('Created User');
    } catch (error) {
      NotificationService.notify('Failed to create User.');
    }
  }

  Future<bool> userNameExists(String userName) async {
    try {
      final query = await _firestore.collection('users').where('userName', isEqualTo: userName).limit(1).get();
      if (query.docs.isNotEmpty) return true;
    } catch (error) {
      NotificationService.notify('Failed to find userName.');
    }
    return false;
  }

  Future<bool> sync(PhoneAuthCredential? credential, String? verifyId, String? code) async {
    try {
      bool check = true;
      PhoneAuthCredential myCredential = credential ?? PhoneAuthProvider.credential(verificationId: verifyId!, smsCode: code!);

      _auth.signInWithCredential(myCredential).then((value) async {
        NotificationService.notify("Phone number verified.");
      }).catchError((error) async {
        if (error.toString() ==
            '[firebase_auth/credential-already-in-use] This credential is already associated with a different user account.') {
          NotificationService.notify("This phone number is already associated with a different account.");
          check = false;
        } else if (error.toString() ==
            '[firebase_auth/invalid-verification-code] The sms verification code used to create the phone auth credential is invalid. Please resend the verification code sms and be sure use the verification code provided by the user.') {
          NotificationService.notify(
              "Verification code is incorrect.");
          check = false;
        } else if (error.toString() ==
            '[firebase_auth/unknown] com.google.firebase.FirebaseException: User has already been linked to the given provider.') {
          NotificationService.notify("Phone number verified.");
        } else if (error.toString() ==
            '[ERROR_PROVIDER_ALREADY_LINKED] - User can only be linked to one identity for the given provider.') {
          NotificationService.notify("Phone number verified.");
        } else if (error.toString() ==
            '[firebase_auth/unknown] d5.j: User has already been linked to the given provider.') {
          NotificationService.notify("Phone number verified.");
        } else if (error.toString() ==
            '[ERROR_PROVIDER_ALREADY_LINKED] - User can only be linked to one identity for the given provider.') {
          NotificationService.notify("Phone number verified.");
        } else {
          NotificationService.notify(error.toString());
          check = false;
        }
      });
      return check;
    } catch (error) {
      NotificationService.notify('Failed to verify phone number');
      return false;
    }
  }

  Future<void> verifyPhoneNumber(String number, Function updateItems) async {
    try {
      NotificationService.notify('Sending verification code...');

      await _auth.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await sync(credential, null, null);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            NotificationService.notify("Invalid phone number. Please try again.");
          } else if (e.code == 'phone-number-already-in-use') {
            NotificationService.notify("Phone number already in use. Please try a different number.");
          } else if (e.code == 'too-many-requests') {
            NotificationService.notify("Servers are full. Please try again later.");
          } else {
            NotificationService.notify("Error encountered. Please try again.");
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          updateItems(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (error) {
      NotificationService.notify('Failed to verify phone number');
    }
  }

  // User Stuff //

  Future<void> addToMenu(Recipe recipe) async {
    NotificationService.notify('Adding to menu...');

    try {
      var menuRef = _firestore.collection('menu').doc(recipe.id);
      // await menuRef.set({
      //   "id": recipe.id,
      //   "name": recipe['name'],
      //   "class": recipe['class'],
      //   "cookTime": recipe['cookTime'],
      //   "prepTime": recipe['prepTime'],
      //   "ingredient_amounts": recipe['ingredient_amounts'],
      //   "ingredients": recipe['ingredients'],
      //   "instructions": recipe['instructions'],
      // });
      await menuRef.set(recipe.toJson());

      for (int i = 0; i < recipe.ingredients.length; i++) {
        var ref = _firestore.collection('grocery').doc();
        Grocery grocery = Grocery(
            id: ref.id,
            name: recipe.ingredients[i],
            amount: recipe.ingredientAmounts[i],
            recipeId: recipe.id,
            recipeName: recipe.name,
            mark: false);
        // await ref.set({
        //   "id": ref.id,
        //   "name": recipe['ingredients'][i],
        //   "amount": recipe['ingredient_amounts'][i],
        //   "recipeName": recipe['name'],
        //   "recipeId": recipe.id,
        //   "recipeItem": true,
        //   "mark": false,
        // });
        await ref.set(grocery.toJson());
      }

      NotificationService.notify('Added to menu.');
    } catch (error) {
      NotificationService.notify('Failed to add to menu.');
    }
  }

  Future<void> removeFromMenu(String id) async {
    NotificationService.notify('Removing from menu...');

    try {
      var collection = await _firestore.collection('grocery').where('recipeId', isEqualTo: id).get();
      for (var item in collection.docs) {
        await _firestore.collection('grocery').doc(item.id).delete();
      }
      await _firestore.collection('menu').doc(id).delete();

      NotificationService.notify('Removed from menu.');
    } catch (error) {
      NotificationService.notify('Failed to remove from menu.');
    }
  }

  Future<void> deleteRecipe(String id) async {
    NotificationService.notify('Deleting recipe...');

    try {
      await _firestore.collection('recipes').doc(id).delete();

      var menuDoc = await _firestore.collection('menu').doc(id).get();
      if (menuDoc.exists) {
        await _firestore.collection('menu').doc(id).delete();
      }

      var collection = await _firestore.collection('grocery').where('recipeId', isEqualTo: id).get();
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
      Recipe recipe = Recipe(
          id: recipeRef.id,
          name: recipeName,
      className: recipeClass,
      cookTime: cookTime,
      prepTime: prepTime,
      ingredientAmounts: recipeAmounts,
      ingredients: recipeIngredients,
      instructions: recipeInstructions);
      await recipeRef.set(recipe.toJson());

      NotificationService.notify('Recipe created.');
    } catch (error) {
      NotificationService.notify('Failed to create recipe.');
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    NotificationService.notify('Updating recipe...');

    try {
      var recipeRef = _firestore.collection('recipes').doc(recipe.id);
      // await recipeRef.update({
      //   "id": recipeRef.id,
      //   "name": recipeName,
      //   "class": recipeClass,
      //   "cookTime": cookTime,
      //   "prepTime": prepTime,
      //   "ingredient_amounts": recipeAmounts,
      //   "ingredients": recipeIngredients,
      //   "instructions": recipeInstructions,
      // });
      await recipeRef.update(recipe.toJson());

      var menuDoc = await _firestore.collection('menu').doc(recipe.id).get();
      if (menuDoc.exists) {
        var menuRef = _firestore.collection('menu').doc(recipe.id);
        // await menuRef.update({
        //   "id": menuRef.id,
        //   "name": recipeName,
        //   "class": recipeClass,
        //   "cookTime": cookTime,
        //   "prepTime": prepTime,
        //   "ingredient_amounts": recipeAmounts,
        //   "ingredients": recipeIngredients,
        //   "instructions": recipeInstructions,
        // });
        await menuRef.update(recipe.toJson());
      }

      NotificationService.notify('Recipe updated.');
    } catch (error) {
      NotificationService.notify('Failed to update recipe.');
    }
  }

  Future<void> markGroceryItem(bool value, String id) async {
    try {
      var ref = _firestore.collection('grocery').doc(id);
      await ref.update({
        "mark": value,
      });
    } catch (error) {
      NotificationService.notify('Failed to mark item.');
    }
  }

  Future<void> deleteGroceryItem(String id) async {
    try {
      await _firestore.collection('grocery').doc(id).delete();
    } catch (error) {
      NotificationService.notify('Failed to delete item.');
    }
  }

  Future<void> addGroceryItem(String name) async {
    try {
      var ref = _firestore.collection('grocery').doc();
      Grocery grocery = Grocery(
          id: ref.id,
          name: name,
          mark: false);
      // await ref.set({
      //   "id": ref.id,
      //   "name": name,
      //   "recipeItem": false,
      //   "mark": false,
      // });
      await ref.set(grocery.toJson());
    } catch (error) {
      NotificationService.notify('Failed to add item.');
    }
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