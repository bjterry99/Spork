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

            var removeHome = false;
            savedIds.forEach((savedId) => {
              if (afterFamily.includes(savedId)) {
                removeHome = true;
              }
            });

            if (removeHome) {
              await recipeRef.update({
                homeIds: FieldValue.arrayRemove(homeId),
              });
            }
          });
        });
      }
  } catch (error) {
    functions.logger.log(error);
  }
});