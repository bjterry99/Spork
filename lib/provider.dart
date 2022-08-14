import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spork/models/models.dart';
import 'package:spork/notification_service.dart';
import 'package:spork/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class AppProvider extends ChangeNotifier {
  AppProvider() {
    user = AppUser(
      id: _auth.currentUser?.uid ?? '',
      name: '',
      userName: '',
      photoUrl: '',
      phone: '',
    );

    _subscribeStreams();
  }

  /// Widgets ///

  PreferredSizeWidget getZeroAppBar(Color color) {
    return Platform.isAndroid
        ? PreferredSize(
            preferredSize: Size.zero,
            child: AppBar(
              elevation: 0,
              backgroundColor: color,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: color,
                statusBarIconBrightness: color == CustomColors.primary ? Brightness.light : Brightness.dark,
              ),
            ),
          )
        : PreferredSize(
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
  late AppUser user;

  void _subscribeStreams() {
    // Firebase User Stream
    subscribe(_auth.authStateChanges().listen((data) {
      fireUser = data;
      notifyListeners();
    }, onError: (error) {
      NotificationService.notify("Failed to get authentication data.");
    }));

    // User stream
    if (fireUser != null) {
      subscribe(_firestore
          .collection('users')
          .doc(fireUser!.uid)
          .snapshots()
          .map((snapshot) => AppUser.fromJson(snapshot.data()!))
          .listen((data) {
        user = data;
        notifyListeners();
      }, onError: (error) {
        NotificationService.notify("Failed to get user info.");
      }));
    }
  }

  Stream<List<Recipe>> recipeStream = _firestore
      .collection('recipes')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList());

  Stream<List<Recipe>> menuStream = _firestore
      .collection('menu')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList());

  Stream<List<Grocery>> groceryStream = _firestore
      .collection('grocery')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Grocery.fromJson(doc.data())).toList());

  Stream<List<AppUser>> userStream = _firestore
      .collection('users')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => AppUser.fromJson(doc.data())).toList());

  Stream<QuerySnapshot<Object?>> specificMenuItem(String id) {
    return _firestore.collection('menu').where('id', isEqualTo: id).snapshots();
  }

  Stream<QuerySnapshot<Object?>> numberFollowing(String id) {
    return _firestore.collection('users').where('followers', arrayContains: id).snapshots();
  }

  /// Functions ///

  // User Stuff //

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> syncUser() async {
    var ref = await _firestore.collection('users').doc(fireUser!.uid).get();
    user = AppUser.fromJson(ref.data()!);
    notifyListeners();
  }

  Future<bool> editProfile(AppUser appUser) async {
    try {
      bool userName = await userNameExists(appUser.userName);
      if (!userName) {
        NotificationService.notify('Updating account...');

        var userRef = _firestore.collection('users').doc(appUser.id);
        await userRef.set(appUser.toJson());

        NotificationService.notify('Created User');
        return true;
      } else {
        NotificationService.notify('Username taken.');
      }
    } catch (error) {
      NotificationService.notify('Failed to create User.');
    }
    return false;
  }

  Future<void> createAccount(AppUser appUser) async {
    try {
      NotificationService.notify('Creating account...');
      await Future.delayed(const Duration(seconds: 2));
      var userRef = _firestore.collection('users').doc(_auth.currentUser!.uid);
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
      NotificationService.notify('Failed to find Username.');
    }
    return false;
  }

  Future<bool> sync(PhoneAuthCredential? credential, String? verifyId, String? code) async {
    try {
      bool check = true;
      PhoneAuthCredential myCredential =
          credential ?? PhoneAuthProvider.credential(verificationId: verifyId!, smsCode: code!);

      _auth.signInWithCredential(myCredential).then((value) async {
        NotificationService.notify("Phone number verified.");
      }).catchError((error) async {
        if (error.toString() ==
            '[firebase_auth/credential-already-in-use] This credential is already associated with a different user account.') {
          NotificationService.notify("This phone number is already associated with a different account.");
          check = false;
        } else if (error.toString() ==
            '[firebase_auth/invalid-verification-code] The sms verification code used to create the phone auth credential is invalid. Please resend the verification code sms and be sure use the verification code provided by the user.') {
          NotificationService.notify("Verification code is incorrect.");
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

  Future<void> login(String number, Function updateItems) async {
    try {
      final query = await _firestore.collection('users').where('phone', isEqualTo: number).limit(1).get();
      if (query.docs.isNotEmpty) {
        await verifyPhoneNumber(number, updateItems);
      } else {
        NotificationService.notify('Account not found.');
      }
    } catch (error) {
      NotificationService.notify('Failed to find account.');
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
        instructions: recipeInstructions,
        queryName: recipeName.toLowerCase(),
        visibility: 'explore'
      );
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
      await recipeRef.update(recipe.toJson());

      var menuDoc = await _firestore.collection('menu').doc(recipe.id).get();
      if (menuDoc.exists) {
        var menuRef = _firestore.collection('menu').doc(recipe.id);
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
      Grocery grocery = Grocery(id: ref.id, name: name, mark: false);
      await ref.set(grocery.toJson());
    } catch (error) {
      NotificationService.notify('Failed to add item.');
    }
  }

  bool loader = false; // this variable is only used for this function
  Future<String> uploadPicture(String id) async {
    CroppedFile? croppedImage;
    String url = '';
    try {
      final ImagePicker picker = ImagePicker();

      // Pick an image
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Crop image
        croppedImage = await ImageCropper().cropImage(
          sourcePath: image.path,
          compressQuality: 10,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: CustomColors.primary,
              toolbarWidgetColor: CustomColors.white,
              statusBarColor: CustomColors.primary,
              initAspectRatio: CropAspectRatioPreset.original,
              activeControlsWidgetColor: CustomColors.primary,
              hideBottomControls: true,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Crop Image',
              minimumAspectRatio: 50,
              rectX: 1,
              rectY: 1,
              rectWidth: 100000,
              rectHeight: 100000,
              resetButtonHidden: true,
              rotateButtonsHidden: true,
              aspectRatioLockEnabled: true,
              aspectRatioPickerButtonHidden: true,
              aspectRatioLockDimensionSwapEnabled: false,
              resetAspectRatioEnabled: false,
            ),
          ],
        );
      }

      if (croppedImage != null) {
        loader = true;
        notifyListeners();
        NotificationService.notify("Uploading image...");

        // converts image to base64
        List<int> imageBytes = await croppedImage.readAsBytes();
        String base64Image = base64Encode(imageBytes);

        // upload to storage
        final storageRef = FirebaseStorage.instance.ref();
        final imageRef = storageRef.child(id);

        await imageRef.putString(
          base64Image,
          format: PutStringFormat.base64,
          metadata: SettableMetadata(contentType: 'image/jpeg'),
        );

        url = await imageRef.getDownloadURL();
      } else {
        NotificationService.notify("Failed to image.");
      }
    } catch (error) {
      NotificationService.notify("Failed to upload.");
    }
    loader = false;
    notifyListeners();
    return url;
  }

  Future<void> createHome(MyHome home) async {
    try {
      NotificationService.notify('Creating Home...');

      var homeRef = _firestore.collection('homes').doc();
      home.id = homeRef.id;

      var userRef = _firestore.collection('users').doc(user.id);

      await homeRef.set(home.toJson());
      await userRef.update({
        "homeId": homeRef.id,
      });

      NotificationService.notify('Home created.');
    } catch (error) {
      NotificationService.notify('Failed to create Home.');
    }
  }

  Future<void> editHomeName(String id, String name) async {
    try {
      var homeRef = _firestore.collection('homes').doc(id);
      await homeRef.update({
        "name": name,
      });
    } catch (error) {
      NotificationService.notify('Failed to update Home.');
    }
  }

  /// Futures ///

  Future<MyHome?> fetchHome(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>>? doc = await _firestore.collection('homes').doc(id).get();
      if (doc.exists) {
        MyHome home = MyHome.fromJson(doc.data()!);
        return home;
      }
    } catch (error) {
      NotificationService.notify("Failed to find Home.");
    }
    return null;
  }

  Future<List<Recipe>> searchRecipesExplore(int pageSize, String query, int page) async {
    if (query != '') {
      if (page != 0) {
        final skipThese = await _firestore
            .collection('recipes')
            .where('visibility', isEqualTo: 'explore')
            .where('queryName', isGreaterThanOrEqualTo: query)
            .limit(page)
            .get();
        final lastVisible = skipThese.docs[skipThese.size - 1];

        QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection('recipes')
            .where('visibility', isEqualTo: 'explore')
            .where('queryName', isGreaterThanOrEqualTo: query)
            .startAt([lastVisible])
            .limit(pageSize)
            .get();

        List<Recipe> recipes = snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList();
        return recipes;
      } else {
        QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection('recipes')
            .where('visibility', isEqualTo: 'explore')
            .where('queryName', isGreaterThanOrEqualTo: query)
            .limit(pageSize)
            .get();

        List<Recipe> recipes = snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList();
        return recipes;
      }
    } else {
      return <Recipe>[];
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
