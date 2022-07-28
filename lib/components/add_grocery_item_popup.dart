import 'package:flutter/material.dart';
import 'package:spork/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class GroceryPopup extends StatefulWidget {
  const GroceryPopup({Key? key}) : super(key: key);

  @override
  State<GroceryPopup> createState() => _GroceryPopupState();
}

class _GroceryPopupState extends State<GroceryPopup> {
  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(15),
      child: Container(
        decoration: const BoxDecoration(
          color: CustomColors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Builder(builder: (context) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TextFormField(
              autofocus: true,
              controller: controller,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'add item...',
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    )
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    )
                ),
              ),
              style: const TextStyle(
                fontSize: CustomFontSize.primary,
              ),
              onEditingComplete: () async {
                Navigator.pop(context);
                if (controller.text != '') {
                  var ref = _firestore.collection('grocery').doc();
                  await ref.set({
                    "id": ref.id,
                    "name": controller.text,
                    "recipeItem": false,
                    "mark": false,
                  });
                }
              },
            ),
          );
        }),
      ),
    );
  }
}
