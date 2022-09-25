import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spork/models/models.dart';
import 'package:spork/services/notification_service.dart';
import 'package:spork/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

final _firestore = FirebaseFirestore.instance;

class AppProvider extends ChangeNotifier {
  AppProvider() {
    _auth = fire_auth.FirebaseAuth.instance;

    _user = AppUser(
      id: _auth.currentUser?.uid ?? '',
      name: '',
      userName: '',
      photoUrl: '',
      phone: '',
    );

    _subscribeFireUser();
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

  Future unsubscribe(StreamSubscription subscription) async => await subscription.cancel();
  void unsubscribeAll() {
    for (var subscription in _subscriptions) {
      unsubscribe(subscription);
    }
  }

  @override
  void dispose() {
    super.dispose();
    unsubscribeAll();
  }

  late fire_auth.FirebaseAuth _auth;
  fire_auth.User? _fireUser;
  late AppUser _user;

  AppUser get user => _user;
  fire_auth.User? get fireUser => _fireUser;

  void _subscribeFireUser() {
    // Firebase User Stream
    subscribe(_auth.authStateChanges().listen((data) {
      _fireUser = data;
      notifyListeners();
    }, onError: (error) {
      NotificationService.notify("Failed to get authentication data.");
    }));
  }

  void subscribeUser() {
    // User stream
    subscribe(_firestore
        .collection('users')
        .doc(_fireUser!.uid)
        .snapshots()
        .map((snapshot) => AppUser.fromJson(snapshot.data()!))
        .listen((data) {
      _user = data;
      notifyListeners();
    }, onError: (error) {
      NotificationService.notify("Failed to get user info.");
    }));
  }

  Stream<List<Recipe>> recipeStream() {
    if (_user.homeId == '') {
      return _firestore
          .collection('recipes')
          .where('savedIds', arrayContains: _user.id)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList());
    } else {
      return _firestore
          .collection('recipes')
          .where('homeIds', arrayContains: _user.homeId)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList());
    }
  }

  Stream<List<Recipe>> menuStream() {
    if (_user.homeId == '') {
      return _firestore
          .collection('recipes')
          .where('menuIds', arrayContains: _user.id)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList());
    } else {
      return _firestore
          .collection('recipes')
          .where('menuIds', arrayContains: _user.homeId)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList());
    }
  }

  Stream<List<Grocery>> groceryStream() {
    if (_user.homeId == '') {
      return _firestore.collection('grocery').where('creatorId', isEqualTo: _user.id).snapshots().map((snapshot) => snapshot.docs.map((doc) => Grocery.fromJson(doc.data())).toList());
    } else {
      return _firestore.collection('grocery').where('homeId', isEqualTo: _user.homeId).snapshots().map((snapshot) => snapshot.docs.map((doc) => Grocery.fromJson(doc.data())).toList());
    }
  }

  Stream<List<HomeInvite>> inviteStream() {
      return _firestore.collection('homeInvites').where('receiverId', isEqualTo: _user.id).snapshots().map((snapshot) => snapshot.docs.map((doc) => HomeInvite.fromJson(doc.data())).toList());
  }

  Stream<List<AppUser>> userStream = _firestore
      .collection('users')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => AppUser.fromJson(doc.data())).toList());

  Stream<QuerySnapshot<Object?>> numberFollowing(String id) {
    return _firestore.collection('users').where('followers', arrayContains: id).snapshots();
  }

  Stream<QuerySnapshot<Object?>> specificHomeInvite(String id) {
    return _firestore.collection('homeInvites').where('id', isEqualTo: '${_user.id}_$id').snapshots();
  }

  Stream<QuerySnapshot<Object?>> specificHome(String id) {
    return _firestore.collection('homes').where('users', arrayContains: id).snapshots();
  }

  Stream<QuerySnapshot<Object?>> savedRecipes() {
    return _firestore.collection('recipes').where('savedIds', arrayContains: _user.id).snapshots();
  }

  Stream<List<AppUser>> homeUsers() {
    return _firestore.collection('users').where('homeId', isEqualTo: _user.homeId).snapshots().map((snapshot) => snapshot.docs.map((doc) => AppUser.fromJson(doc.data())).toList());
  }

  /// Functions ///

  // User Stuff //

  Future<void> signOut() async {
    await _auth.signOut();
    _user = AppUser(
      id: '',
      name: '',
      userName: '',
      photoUrl: '',
      phone: '',
    );
  }

  Future<bool> editProfile(AppUser appUser) async {
    try {
      bool userName = await userNameExists(appUser.userName, appUser.id);
      if (!userName) {
        NotificationService.notify('Updating account...');

        var userRef = _firestore.collection('users').doc(appUser.id);

        if (appUser.photoUrl != '' && !Uri.parse(appUser.photoUrl).isAbsolute) {
          appUser.photoUrl = await _uploadPicture(userRef.id, appUser.photoUrl);
        }

        await userRef.set(appUser.toJson());

        NotificationService.notify('Updated user');
        return true;
      } else {
        NotificationService.notify('Username taken.');
      }
    } catch (error) {
      NotificationService.notify('Failed to update User.');
    }
    return false;
  }

  Future<void> createAccount(AppUser appUser) async {
    try {
      NotificationService.notify('Creating account...');
      await Future.delayed(const Duration(seconds: 2));
      var userRef = _firestore.collection('users').doc(_auth.currentUser!.uid);
      appUser.id = userRef.id;

      if (appUser.photoUrl != '') {
        appUser.photoUrl = await _uploadPicture(userRef.id, appUser.photoUrl);
      }

      await userRef.set(appUser.toJson());

      NotificationService.notify('Created User');
    } catch (error) {
      NotificationService.notify('Failed to create User.');
    }
  }

  Future<bool> userNameExists(String userName, String? id) async {
    String testId = id ?? '';
    try {
      final query = await _firestore.collection('users').where('userName', isEqualTo: userName).limit(1).get();
      if (query.docs.first.id == testId) return false;
      if (query.docs.isNotEmpty) return true;
    } catch (error) {
      NotificationService.notify('Failed to find Username.');
    }
    return false;
  }

  Future<void> syncUser() async {
    await Future.delayed(const Duration(seconds: 1));
    var userData = await _firestore.collection('users').where('id', isEqualTo: _fireUser!.uid).get();
    _user = AppUser.fromJson(userData.docs.first.data());
  }

  Future<bool> sync(fire_auth.PhoneAuthCredential? credential, String? verifyId, String? code) async {
    try {
      bool check = true;
      fire_auth.PhoneAuthCredential myCredential =
          credential ?? fire_auth.PhoneAuthProvider.credential(verificationId: verifyId!, smsCode: code!);

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
        verificationCompleted: (fire_auth.PhoneAuthCredential credential) async {
          await sync(credential, null, null);
        },
        verificationFailed: (fire_auth.FirebaseAuthException e) {
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

  Future<void> openUrl(String url) async {
    try {
      if (url.startsWith('http:')) {
        url = 'https${url.substring(4)}';
      }
      await launchUrl(
          url.trim().substring(0, 8) == 'https://' ? Uri.parse(url) : Uri.parse('https://$url'));
    } catch (error) {
      throw Exception('Failed to open url');
    }
  }

  Future<void> addToMenu(Recipe recipe) async {
    NotificationService.notify('Adding to menu...');

    if (Platform.isAndroid) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    try {
      var ref = _firestore.collection('recipes').doc(recipe.id);
      if (_user.homeId == '') {
        await ref.update({
          'menuIds': FieldValue.arrayUnion([_user.id]),
        });
      } else {
        await ref.update({
          'menuIds': FieldValue.arrayUnion([_user.homeId]),
        });
      }

      for (int i = 0; i < recipe.ingredients.length; i++) {
        var ref = _firestore.collection('grocery').doc();
        Grocery grocery = Grocery(
            id: ref.id,
            name: recipe.ingredients[i],
            amount: recipe.ingredientAmounts[i],
            recipeId: recipe.id,
            recipeName: recipe.name,
            mark: false,
            creatorId: _user.id,
            homeId: _user.homeId,);
        await ref.set(grocery.toJson());
      }
    } catch (error) {
      NotificationService.notify('Failed to add to menu.');
    }
  }

  Future<void> saveRecipe(String id) async {
    NotificationService.notify('Saving recipe...');

    try {
      bool isHome = _user.homeId != '';
      var ref = _firestore.collection('recipes').doc(id);
      if (isHome) {
        await ref.update({
          'savedIds': FieldValue.arrayUnion([_user.id]),
          'homeIds': FieldValue.arrayUnion([_user.homeId]),
        });
      } else {
        await ref.update({
          'savedIds': FieldValue.arrayUnion([_user.id]),
        });
      }
    } catch (error) {
      NotificationService.notify('Failed to add to save recipe.');
    }
  }

  Future<void> unsaveRecipe(Recipe recipe) async {
    NotificationService.notify('Removing recipe...');

    try {
      var ref = _firestore.collection('recipes').doc(recipe.id);

      bool isHome = _user.homeId != '';
      bool removeHome = true;
      if (isHome) {
        var data = await _firestore.collection('users').where('homeId', isEqualTo: _user.homeId).get();
        List<String> homeMembers = data.docs.map((e) => e.id).toList();

        for (String id in recipe.savedIds) {
          if (homeMembers.contains(id)) {
            removeHome = false;
          }
        }
      }

      if (isHome && removeHome) {
        await ref.update({
          'savedIds': FieldValue.arrayRemove([_user.id]),
          'homeIds': FieldValue.arrayRemove([_user.homeId]),
        });
      } else {
        await ref.update({
          'savedIds': FieldValue.arrayRemove([_user.id]),
        });
      }
    } catch (error) {
      NotificationService.notify('Failed to add to remove recipe.');
    }
  }

  Future<void> reportUser(String id) async {
    NotificationService.notify('Reporting user...');

    try {
      var ref = _firestore.collection('reportedUsers').doc(id);
      await ref.set({
        'id': id,
      });
    } catch (error) {
      NotificationService.notify('Failed to report user.');
    }
  }

  Future<void> reportRecipe(String id) async {
    NotificationService.notify('Reporting recipe...');

    try {
      var ref = _firestore.collection('reportedRecipes').doc(id);
      await ref.set({
        'id': id,
      });
    } catch (error) {
      NotificationService.notify('Failed to report recipe.');
    }
  }

  Future<void> removeFromMenu(String id) async {
    NotificationService.notify('Removing from menu...');

    try {
      var collection = await _firestore.collection('grocery').where('recipeId', isEqualTo: id).get();
      for (var item in collection.docs) {
        await _firestore.collection('grocery').doc(item.id).delete();
      }

      var ref = _firestore.collection('recipes').doc(id);
      if (_user.homeId == '') {
        await ref.update({
          'menuIds': FieldValue.arrayRemove([_user.id])
        });
      } else {
        await ref.update({
          'menuIds': FieldValue.arrayRemove([_user.homeId])
        });
      }
    } catch (error) {
      NotificationService.notify('Failed to remove from menu.');
    }
  }

  Future<void> deleteRecipe(Recipe recipe) async {
    NotificationService.notify('Deleting recipe...');

    try {
      final storageRef = FirebaseStorage.instance.ref();

      if (recipe.photoUrl != '') {
        final pictureRef = storageRef.child(recipe.id);
        await pictureRef.delete();
      }

      await _firestore.collection('recipes').doc(recipe.id).delete();

      var collection = await _firestore.collection('grocery').where('recipeId', isEqualTo: recipe.id).get();
      for (var item in collection.docs) {
        await _firestore.collection('grocery').doc(item.id).delete();
      }
    } catch (error) {
      NotificationService.notify('Failed to delete recipe.');
    }
  }

  Future<void> deleteUser() async {
    NotificationService.notify('Deleting account...');

    try {
      final storageRef = FirebaseStorage.instance.ref();

      if (_user.photoUrl != '') {
        final pictureRef = storageRef.child(_user.id);
        await pictureRef.delete();
      }

      await _firestore.collection('users').doc(_user.id).delete();

      _user = AppUser(
        id: '',
        name: '',
        userName: '',
        photoUrl: '',
        phone: '',
      );
    } catch (error) {
      NotificationService.notify('Failed to delete account.');
    }
  }

  Future<void> createRecipe(Recipe recipe) async {
    NotificationService.notify('Creating recipe...');

    try {
      var recipeRef = _firestore.collection('recipes').doc();
      recipe.id = recipeRef.id;
      recipe.creatorId = _user.id;
      recipe.savedIds = [_user.id];
      if (_user.homeId != '') {
        recipe.homeIds = [_user.homeId];
      }

      if (recipe.photoUrl != '' && !Uri.parse(recipe.photoUrl).isAbsolute) {
        recipe.photoUrl = await _uploadPicture(recipeRef.id, recipe.photoUrl);
      }

      await recipeRef.set(recipe.toJson());
    } catch (error) {
      NotificationService.notify('Failed to create recipe.');
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    NotificationService.notify('Updating recipe...');

    try {
      var recipeRef = _firestore.collection('recipes').doc(recipe.id);

      if (recipe.photoUrl != '' && !Uri.parse(recipe.photoUrl).isAbsolute) {
        recipe.photoUrl = await _uploadPicture(recipeRef.id, recipe.photoUrl);
      }

      await recipeRef.update(recipe.toJson());
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

  Future<void> deleteHome(String id) async {
    try {
      NotificationService.notify('Deleting home...');

      await _firestore.collection('homes').doc(id).delete();
    } catch (error) {
      NotificationService.notify('Failed to delete home.');
    }
  }

  Future<void> acceptHomeInvite(HomeInvite invite) async {
    try {
      NotificationService.notify('Joining home...');

      await _firestore.collection('homeInvites').doc(invite.id).delete();

      var ref = _firestore.collection('homes').doc(invite.homeId);
      await ref.update({
        "users": FieldValue.arrayUnion([_user.id]),
      });
    } catch (error) {
      NotificationService.notify('Failed to accept invite.');
    }
  }

  Future<void> addGroceryItem(Grocery grocery) async {
    try {
      var ref = _firestore.collection('grocery').doc();
      grocery.id = ref.id;

      if (Platform.isAndroid) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }

      await ref.set(grocery.toJson());
    } catch (error) {
      NotificationService.notify('Failed to add item.');
    }
  }

  Future<String> choosePicture() async {
    CroppedFile? croppedImage;
    String string64 = '';
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
        NotificationService.notify("Uploading image...");

        // converts image to base64
        List<int> imageBytes = await croppedImage.readAsBytes();
        string64 = base64Encode(imageBytes);

      } else {
        NotificationService.notify("Failed to upload image.");
      }
    } catch (error) {
      NotificationService.notify("Failed to upload.");
    }
    return string64;
  }

  Future<String> _uploadPicture(String id, String string64) async {
    String url = '';
    try {
      // upload to storage
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child(id);

      await imageRef.putString(
        string64,
        format: PutStringFormat.base64,
        metadata: SettableMetadata(contentType: 'image/jpeg'),
      );

      url = await imageRef.getDownloadURL();
    } catch (error) {
      NotificationService.notify("Failed to upload.");
    }
    return url;
  }

  Future<void> createHome(MyHome home) async {
    try {
      if (Platform.isAndroid) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }

      NotificationService.notify('Creating Home...');

      var homeRef = _firestore.collection('homes').doc();
      home.id = homeRef.id;

      var userRef = _firestore.collection('users').doc(_user.id);

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

  Future<void> inviteToHome(String id) async {
    try {
      NotificationService.notify('Inviting to Home...');

      if (Platform.isAndroid) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }

      var inviteRef = _firestore.collection('homeInvites').doc('${_user.id}_$id');
      HomeInvite invite = HomeInvite(id: '${_user.id}_$id', inviterId: _user.id, receiverId: id, homeId: _user.homeId);
      await inviteRef.set(invite.toJson());
    } catch (error) {
      NotificationService.notify('Failed to invite to Home.');
    }
  }

  Future<void> removeInviteToHome(String id) async {
    try {
      var inviteRef = _firestore.collection('homeInvites').doc(id);
      await inviteRef.delete();
    } catch (error) {
      NotificationService.notify('Failed to invite to Home.');
    }
  }

  Future<void> removeFromHome(String id) async {
    try {
      var ref = _firestore.collection('homes').doc(_user.homeId);
      await ref.update({
        "users": FieldValue.arrayRemove([id])
      });
    } catch (error) {
      NotificationService.notify('Failed to remove from Home.');
    }
  }

  Future<void> follow(String id) async {
    try {
      NotificationService.notify('Following...');

      if (Platform.isAndroid) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }

      var ref = _firestore.collection('users').doc(id);
      await ref.update({
        "followers": FieldValue.arrayUnion([_user.id])
      });
    } catch (error) {
      NotificationService.notify('Failed to follow user.');
    }
  }

  Future<void> unfollow(String id) async {
    try {
      NotificationService.notify('Unfollowing...');

      var ref = _firestore.collection('users').doc(id);
      await ref.update({
        "followers": FieldValue.arrayRemove([_user.id])
      });
    } catch (error) {
      NotificationService.notify('Failed to unfollow user.');
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

  Future<AppUser?> fetchUser(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>>? doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        AppUser appUser = AppUser.fromJson(doc.data()!);
        return appUser;
      }
    } catch (error) {
      // NotificationService.notify("Failed to find user.");
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

  Future<List<Recipe>> searchRecipesFollow(int pageSize, String query, int page) async {
    if (query != '') {
      final following = await _firestore.collection('users').where('followers', arrayContains: _user.id).get();
      List<String> followingList = following.docs.map((e) => e.id).toList();

      if (followingList.isNotEmpty) {
        if (followingList.length <= 10) {
          if (page != 0) {
            final skipThese = await _firestore
                .collection('recipes')
                .where('creatorId', whereIn: followingList)
                .where('queryName', isGreaterThanOrEqualTo: query)
                .limit(page)
                .get();
            final lastVisible = skipThese.docs[skipThese.size - 1];

            QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
                .collection('recipes')
                .where('creatorId', whereIn: followingList)
                .where('queryName', isGreaterThanOrEqualTo: query)
                .startAt([lastVisible])
                .get();
            List<Recipe> recipes = snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList();

            List<Recipe> sortedRecipes = [];
            for (var recipe in recipes) {
              if (recipe.visibility != 'private') {
                sortedRecipes.add(recipe);
                if (sortedRecipes.length == pageSize) {
                  return sortedRecipes;
                }
              }
            }

            return sortedRecipes;
          } else {
            QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
                .collection('recipes')
                .where('creatorId', whereIn: followingList)
                .where('queryName', isGreaterThanOrEqualTo: query)
                .get();
            List<Recipe> recipes = snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList();

            List<Recipe> sortedRecipes = [];
            for (var recipe in recipes) {
              if (recipe.visibility != 'private') {
                sortedRecipes.add(recipe);
                if (sortedRecipes.length == pageSize) {
                  return sortedRecipes;
                }
              }
            }

            return sortedRecipes;
          }
        } else {
          if (page != 0) {
            final skipThese = await _firestore
                .collection('recipes')
                .where('creatorId', whereIn: followingList)
                .where('queryName', isGreaterThanOrEqualTo: query)
                .limit(page)
                .get();
            final lastVisible = skipThese.docs[skipThese.size - 1];

            List<Recipe> recipes = [];
            for (int i=0; i < followingList.length; i=i+10) {
              List<String> someFollowing = [];
              if (followingList.skip(i).length > 10) {
                someFollowing.addAll(followingList.sublist(i, i + 10));
              } else {
                someFollowing.addAll(followingList.skip(i));
              }

              QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
                  .collection('recipes')
                  .where('creatorId', whereIn: followingList)
                  .where('visibility', isNotEqualTo: 'private')
                  .where('queryName', isGreaterThanOrEqualTo: query)
                  .startAt([lastVisible])
                  .get();

              recipes.addAll(snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList());
            }

            List<Recipe> sortedRecipes = [];
            for (var recipe in recipes) {
              if (recipe.visibility != 'private') {
                sortedRecipes.add(recipe);
                if (sortedRecipes.length == pageSize) {
                  return sortedRecipes;
                }
              }
            }

            return sortedRecipes;
          } else {
            List<Recipe> recipes = [];

            for (int i=0; i < followingList.length; i=i+10) {
              List<String> someFollowing = [];
              if (followingList.skip(i).length > 10) {
                someFollowing.addAll(followingList.sublist(i, i + 10));
              } else {
                someFollowing.addAll(followingList.skip(i));
              }

              QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
                  .collection('recipes')
                  .where('creatorId', whereIn: someFollowing)
                  .where('queryName', isGreaterThanOrEqualTo: query)
                  .get();

              recipes.addAll(snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList());
            }

            List<Recipe> sortedRecipes = [];
            for (var recipe in recipes) {
              if (recipe.visibility != 'private') {
                sortedRecipes.add(recipe);
                if (sortedRecipes.length == pageSize) {
                  return sortedRecipes;
                }
              }
            }

            return sortedRecipes;
          }
        }
      } else {
        return <Recipe>[];
      }
    } else {
      return <Recipe>[];
    }
  }

  Future<List<AppUser>> searchPeopleExplore(int pageSize, String query, int page) async {
    if (query != '') {
      if (page != 0) {
        final skipThese = await _firestore
            .collection('users')
            .where('queryName', isNotEqualTo: _user.queryName)
            .where('queryName', isGreaterThanOrEqualTo: query)
            .limit(page)
            .get();
        final lastVisible = skipThese.docs[skipThese.size - 1];

        QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection('users')
            .where('queryName', isNotEqualTo: _user.queryName)
            .where('queryName', isGreaterThanOrEqualTo: query)
            .startAt([lastVisible])
            .limit(pageSize)
            .get();

        List<AppUser> users = snapshot.docs.map((doc) => AppUser.fromJson(doc.data())).toList();
        return users;
      } else {
        QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection('users')
            .where('queryName', isNotEqualTo: _user.queryName)
            .where('queryName', isGreaterThanOrEqualTo: query)
            .limit(pageSize)
            .get();

        List<AppUser> users = snapshot.docs.map((doc) => AppUser.fromJson(doc.data())).toList();
        return users;
      }
    } else {
      return <AppUser>[];
    }
  }

  Future<List<AppUser>> searchPeopleFollow(int pageSize, String query, int page) async {
    if (query != '') {
      if (page != 0) {
        final skipThese = await _firestore
            .collection('users')
            .where('followers', arrayContains: _user.id)
            .where('queryName', isNotEqualTo: _user.queryName)
            .where('queryName', isGreaterThanOrEqualTo: query)
            .limit(page)
            .get();
        final lastVisible = skipThese.docs[skipThese.size - 1];

        QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection('users')
            .where('followers', arrayContains: _user.id)
            .where('queryName', isNotEqualTo: _user.queryName)
            .where('queryName', isGreaterThanOrEqualTo: query)
            .startAt([lastVisible])
            .limit(pageSize)
            .get();

        List<AppUser> users = snapshot.docs.map((doc) => AppUser.fromJson(doc.data())).toList();
        return users;
      } else {
        QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection('users')
            .where('followers', arrayContains: _user.id)
            .where('queryName', isNotEqualTo: _user.queryName)
            .where('queryName', isGreaterThanOrEqualTo: query)
            .limit(pageSize)
            .get();

        List<AppUser> users = snapshot.docs.map((doc) => AppUser.fromJson(doc.data())).toList();
        return users;
      }
    } else {
      return <AppUser>[];
    }
  }

  Future<bool> canEdit(Recipe recipe) async {
    if (recipe.creatorId == _user.id) {
      return true;
    }
    if (_user.homeId != '') {
      MyHome? myHome = await fetchHome(_user.homeId);
      if (myHome != null) {
        if (myHome.users.contains(recipe.creatorId)) {
          return true;
        }
      }
    }
    return false;
  }

}