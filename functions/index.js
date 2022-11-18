const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { firestore } = require("firebase-admin");
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});
require("firebase-functions/lib/logger/compat");
const FieldValue = require("firebase-admin").firestore.FieldValue;

exports.home_OnCreate = functions.firestore.document("homes/{homeId}")
    .onCreate(async (snap, context) => {
    try {
      const homeId = context.params.homeId;
      const db = admin.firestore();

      const home = snap.data();
      const creatorId = home["creatorId"];

      const recipesCollection = db.collection("recipes")
        .where("savedIds", "array-contains", creatorId);
      const recipesSnap = await recipesCollection.get();
      recipesSnap.forEach(async (recipe) => {
        var recipeRef = db.collection("recipes").doc(recipe.id);

        await recipeRef.update({
          homeIds: FieldValue.arrayUnion(homeId),
        });
      });
  } catch (error) {
    functions.logger.log(error);
  }
});

exports.grocery_OnCreate = functions.firestore.document("grocery/{groceryId}")
    .onCreate(async (snap, context) => {
    try {
      const db = admin.firestore();
      const now = firestore.Timestamp.now();

      const grocery = snap.data();
      const time = grocery['createDate'] ?? '';

      if (time == '') {
        var groceryRef = db.collection("grocery").doc(grocery.id);

        await groceryRef.update({
          createDate: now,
        });
      }
  } catch (error) {
    functions.logger.log(error);
  }
});

exports.home_OnDelete = functions.firestore.document("homes/{homeId}")
    .onDelete(async (snap, context) => {
    try {
      const homeId = context.params.homeId;
      const db = admin.firestore();

      const home = snap.data();
      const family = home["users"];

      family.forEach(async (id) => {
        var userRef = db.collection("users").doc(id);

        await userRef.update({
          homeId: '',
        });
      });

      const recipesCollection = db.collection("recipes")
        .where("homeIds", "array-contains", homeId);
      const recipesSnap = await recipesCollection.get();
      recipesSnap.forEach(async (recipe) => {
        var recipeRef = db.collection("recipes").doc(recipe.id);

        await recipeRef.update({
          homeIds: FieldValue.arrayRemove(homeId),
        });
      });
  } catch (error) {
    functions.logger.log(error);
  }
});

exports.home_OnUpdate = functions.firestore.document("homes/{homeId}")
    .onUpdate(async (change, context) => {
    try {
      const db = admin.firestore();
      const homeId = context.params.homeId;
      const beforeHome = change.before.data();
      const afterHome = change.after.data();

      const beforeFamily = beforeHome['users'];
      const afterFamily = afterHome['users'];

      var removedUsers = [];
      var addedUsers = [];
      beforeFamily.forEach((id) => {
        if (!afterFamily.includes(id)) {
          removedUsers.push(id);
        }
      });
      afterFamily.forEach((id) => {
        if (!beforeFamily.includes(id)) {
          addedUsers.push(id);
        }
      });

      if (addedUsers.length > 0) {
        addedUsers.forEach(async (id) => {
          var userRef = db.collection("users").doc(id);

          await userRef.update({
            homeId: homeId,
          });

          const recipesCollection = db.collection("recipes")
            .where("savedIds", "array-contains", id);
          const recipesSnap = await recipesCollection.get();
          recipesSnap.forEach(async (recipe) => {
            var recipeRef = db.collection("recipes").doc(recipe.id);

            await recipeRef.update({
              homeIds: FieldValue.arrayUnion(homeId),
            });
          });

          const groceryCollection = db.collection("grocery")
            .where("creatorId", "==", id);
          const grocerySnap = await groceryCollection.get();
          grocerySnap.forEach(async (grocery) => {
            var groceryRef = db.collection("grocery").doc(grocery.id);

            await groceryRef.update({
              homeId: homeId,
            });
          });
        });
      }

      if (removedUsers.length > 0) {
       removedUsers.forEach(async (id) => {
          var userRef = db.collection("users").doc(id);

          await userRef.update({
            homeId: '',
          });

          const recipesCollection = db.collection("recipes")
            .where("savedIds", "array-contains", id);
          const recipesSnap = await recipesCollection.get();
          recipesSnap.forEach(async (recipe) => {
            var recipeRef = db.collection("recipes").doc(recipe.id);
            var recipe = await recipeRef.get();
            const savedIds = recipe.data()["savedIds"];

            var removeHome = true;
            savedIds.forEach((savedId) => {
              if (afterFamily.includes(savedId)) {
                removeHome = false;
              }
            });

            if (removeHome) {
              await recipeRef.update({
                homeIds: FieldValue.arrayRemove(homeId),
              });
            }
          });

            const groceryCollection = db.collection("grocery")
              .where("creatorId", "==", id);
            const grocerySnap = await groceryCollection.get();
            grocerySnap.forEach(async (grocery) => {
              var groceryRef = db.collection("grocery").doc(grocery.id);

              await groceryRef.update({
                homeId: '',
              });
            });
        });
      }
  } catch (error) {
    functions.logger.log(error);
  }
});

exports.user_OnDelete = functions.firestore.document("users/{userId}")
    .onDelete(async (snap, context) => {
    try {
      const userId = context.params.userId;
      const db = admin.firestore();

      const user = snap.data();
      const homeId = user["homeId"];

      if (homeId != '') {
        var homeRef = db.collection('homes').doc(homeId);
        var home = await homeRef.get();
        var homeCreator = home.data()['creatorId'];

        if (homeCreator == userId) {
          await homeRef.delete();
        } else {
          await homeRef.update({
            users: FieldValue.arrayRemove(userId),
          });
        }
      }

      var recipeIds = [];
      const recipesCollection = db.collection("recipes")
        .where("creatorId", "==", userId);
      const recipesSnap = await recipesCollection.get();
      recipesSnap.forEach(async (recipe) => {
        recipeIds.push(recipe.id);
      });
      recipeIds.forEach(async (id) => {
         await db.collection('recipes').doc(id).delete();
      });

      var groceryIds = [];
      const groceryCollection = db.collection("grocery")
        .where("creatorId", "==", userId);
      const grocerySnap = await groceryCollection.get();
      grocerySnap.forEach(async (grocery) => {
        groceryIds.push(grocery.id);
      });
      groceryIds.forEach(async (id) => {
         await db.collection('grocery').doc(id).delete();
      });
  } catch (error) {
    functions.logger.log(error);
  }
});