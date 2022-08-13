import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spork/models/models.dart';
import 'package:spork/notification_service.dart';
import 'package:spork/provider.dart';
import 'package:spork/theme.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:provider/provider.dart';

class CreateRecipe extends StatefulWidget {
  const CreateRecipe({this.recipe, Key? key}) : super(key: key);
  final Recipe? recipe;

  @override
  State<CreateRecipe> createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  late String recipeClass;
  late List<String> ingredients;
  late List<String> ingredientAmounts;
  late List<String> instructions;
  late String cookTime;
  late String prepTime;
  late String recipeName;
  bool edit = false;

  Widget getIngredientInput() {
    List<Widget> inputs = [];

    for (int i = 0; i < ingredients.length; i++) {
      inputs.add(Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: ingredients[i],
              style: const TextStyle(
                  color: CustomColors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: CustomFontSize.secondary),
              textCapitalization: TextCapitalization.sentences,
              cursorColor: CustomColors.primary,
              onChanged: (String? newValue) {
                setState(() {
                  ingredients[i] = newValue!;
                });
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: "ingredient...",
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: TextFormField(
              initialValue: ingredientAmounts[i],
              style: const TextStyle(
                  color: CustomColors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: CustomFontSize.secondary),
              cursorColor: CustomColors.primary,
              onChanged: (String? newValue) {
                setState(() {
                  ingredientAmounts[i] = newValue!;
                });
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: "amount...",
              ),
            ),
          ),
        ],
      ));
    }

    return Column(
      children: inputs,
    );
  }

  Widget getInstructionsInput() {
    List<Widget> inputs = [];

    for (int i = 1; i <= instructions.length; i++) {
      inputs.add(
        TextFormField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          initialValue: instructions[i-1],
          style: const TextStyle(
              color: CustomColors.black,
              fontWeight: FontWeight.w400,
              fontSize: CustomFontSize.secondary),
          textCapitalization: TextCapitalization.sentences,
          cursorColor: CustomColors.primary,
          onChanged: (String? newValue) {
            setState(() {
              instructions[i-1] = newValue!;
            });
          },
          decoration: InputDecoration(
              icon: Text(i.toString()),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: "step ${i.toString()}..."),
        ),
      );
    }

    return Column(
      children: inputs,
    );
  }

  bool verifyName() {
    if (recipeName == '') {
      return false;
    } else {
      return true;
    }
  }

  bool verifyIngredients() {
    bool verify = false;
    for (String ingredient in ingredients) {
      if (ingredient != '') {
        verify = true;
      }
    }
    return verify;
  }

  bool verifyInstructions() {
    bool verify = false;
    for (String instruction in instructions) {
      if (instruction != '') {
        verify = true;
      }
    }
    return verify;
  }

  bool verifyAmounts() {
    bool verify = true;
    for (int i = 0; i < ingredients.length; i++) {
      if (ingredients[i] != '') {
        if (ingredientAmounts[i] == '') {
          verify = false;
        }
      }
    }
    return verify;
  }

  void delete() async {
    Navigator.pop(context);
    Navigator.pop(context);
    await Provider.of<AppProvider>(context, listen: false).deleteRecipe(widget.recipe!.id);
  }

  void submit() async {
    List<String> recipeIngredients = [];
    List<String> recipeAmounts = [];
    List<String> recipeInstructions = [];
    bool verify;

    verify = verifyName();
    if (!verify) {
      NotificationService.notify('Recipe must have a name.');
      return;
    }
    verify = verifyIngredients();
    if (!verify) {
      NotificationService.notify('Must include at least one ingredient.');
      return;
    }
    verify = verifyAmounts();
    if (!verify) {
      NotificationService.notify('Ingredients must have an amount.');
      return;
    }
    verify = verifyInstructions();
    if (!verify) {
      NotificationService.notify('Recipe must have instructions.');
      return;
    }

    for (String ingredient in ingredients) {
      if (ingredient != '') {
        recipeIngredients.add(ingredient);
      }
    }
    for (String amount in ingredientAmounts) {
      if (amount != '') {
        recipeAmounts.add(amount);
      }
    }
    for (String instruction in instructions) {
      if (instruction != '') {
        recipeInstructions.add(instruction);
      }
    }

    Navigator.pop(context);
    if (edit) {
      Navigator.pop(context);
      await Provider.of<AppProvider>(context, listen: false).updateRecipe(widget.recipe!);
    } else {
      await Provider.of<AppProvider>(context, listen: false).createRecipe(recipeName, recipeClass, cookTime, prepTime, recipeAmounts, recipeIngredients, recipeInstructions);
    }
  }

  @override
  void initState() {
    if (widget.recipe != null) {
      edit = true;
      recipeClass = widget.recipe!.className;
      ingredients = List<String>.from(widget.recipe!.ingredients);
      ingredientAmounts = List<String>.from(widget.recipe!.ingredientAmounts);
      instructions = List<String>.from(widget.recipe!.instructions);
      prepTime = widget.recipe!.prepTime;
      cookTime = widget.recipe!.cookTime;
      recipeName = widget.recipe!.name;
    } else {
      recipeClass = 'Main';
      ingredients = ['', '', '', ''];
      ingredientAmounts = ['', '', '', ''];
      instructions = ['', '', ''];
      cookTime = '0:30';
      prepTime = '0:10';
      recipeName = '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      onPanDown: (_) {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: Platform.isIOS ? SystemUiOverlayStyle.light :
          const SystemUiOverlayStyle(
            statusBarColor: CustomColors.primary,
            statusBarIconBrightness: Brightness.light,
          ),
          actions: [
            if (edit)
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: GestureDetector(
                onTap: delete,
                child: const Icon(
                  Icons.delete_outline,
                  color: CustomColors.white,
                  size: 25,
                ),
              )
            ),
          ],
          title: Text(
            edit ? 'Edit Recipe' : 'Create New Recipe',
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: CustomFontSize.primary,
                color: CustomColors.white),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          elevation: 1,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Column(
              children: [
                TextFormField(
                  initialValue: recipeName,
                  style: const TextStyle(
                      color: CustomColors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: CustomFontSize.primary),
                  textCapitalization: TextCapitalization.words,
                  cursorColor: CustomColors.primary,
                  onChanged: (String? newValue) {
                    setState(() {
                      recipeName = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    icon: Icon(
                      Icons.short_text_rounded,
                      size: 20,
                    ),
                    hintText: "Recipe name...",
                  ),
                ),
                const Divider(
                  height: 10,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                  color: CustomColors.grey3,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.category_outlined,
                            size: 20,
                            color: CustomColors.grey4,
                          ),
                          SizedBox(
                            width: 17,
                          ),
                          Text(
                            'Recipe class',
                            style: TextStyle(
                                color: CustomColors.grey4,
                                fontWeight: FontWeight.w400,
                                fontSize: CustomFontSize.primary),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Main',
                            groupValue: recipeClass,
                            activeColor: CustomColors.primary,
                            onChanged: (String? value) async {
                              setState(() {
                                recipeClass = 'Main';
                              });
                            },
                          ),
                          const Text('Main',
                          style: TextStyle(fontSize: CustomFontSize.secondary, fontWeight: FontWeight.w500),),
                          const Spacer(),
                          Radio<String>(
                            value: 'Side',
                            groupValue: recipeClass,
                            activeColor: CustomColors.primary,
                            onChanged: (String? value) async {
                              setState(() {
                                recipeClass = 'Side';
                              });
                            },
                          ),
                          const Text('Side',
                              style: TextStyle(fontSize: CustomFontSize.secondary, fontWeight: FontWeight.w500),),
                          const Spacer(),
                          Radio<String>(
                            value: 'Dessert',
                            groupValue: recipeClass,
                            activeColor: CustomColors.primary,
                            onChanged: (String? value) async {
                              setState(() {
                                recipeClass = 'Dessert';
                              });
                            },
                          ),
                          const Text('Dessert',
                            style: TextStyle(fontSize: CustomFontSize.secondary, fontWeight: FontWeight.w500),),
                          const SizedBox(width: 15,)
                        ],
                      )
                    ],
                  ),
                ),
                const Divider(
                  height: 10,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                  color: CustomColors.grey3,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () async {
                      var duration = await showDurationPicker(
                        context: context,
                        initialTime: const Duration(minutes: 30),
                        baseUnit: BaseUnit.minute,
                      );

                      if (duration != null) {
                        String durationString = duration.toString();
                        String hours = durationString.substring(0, durationString.indexOf(':'));
                        durationString = durationString.replaceRange(0, int.parse(hours) > 9 ? 3 : 2, '');
                        String minutes = durationString.substring(0, durationString.indexOf(':'));

                        setState(() {
                          prepTime = hours + ':' + minutes;
                        });
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 20,
                          color: CustomColors.grey4,
                        ),
                        const SizedBox(
                          width: 17,
                        ),
                        const Text(
                          'Prep time',
                          style: TextStyle(
                              color: CustomColors.grey4,
                              fontWeight: FontWeight.w400,
                              fontSize: CustomFontSize.primary),
                        ),
                        const SizedBox(
                          width: 22,
                        ),
                        Text(
                          prepTime,
                          style: const TextStyle(
                              color: CustomColors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: CustomFontSize.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () async {
                      var duration = await showDurationPicker(
                        context: context,
                        initialTime: const Duration(minutes: 10),
                        baseUnit: BaseUnit.minute,
                      );

                      if (duration != null) {
                        String durationString = duration.toString();
                        String hours = durationString.substring(
                            0, durationString.indexOf(':'));
                        durationString = durationString.replaceRange(0, int.parse(hours) > 9 ? 3 : 2, '');
                        String minutes = durationString.substring(
                            0, durationString.indexOf(':'));

                        setState(() {
                          cookTime = hours + ':' + minutes;
                        });
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 20,
                          color: CustomColors.grey4,
                        ),
                        const SizedBox(
                          width: 17,
                        ),
                        const Text(
                          'Cook time',
                          style: TextStyle(
                              color: CustomColors.grey4,
                              fontWeight: FontWeight.w400,
                              fontSize: CustomFontSize.primary),
                        ),
                        const SizedBox(
                          width: 17,
                        ),
                        Text(
                          cookTime,
                          style: const TextStyle(
                              color: CustomColors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: CustomFontSize.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(
                  height: 10,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                  color: CustomColors.grey3,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.egg_outlined,
                        size: 20,
                        color: CustomColors.grey4,
                      ),
                      const SizedBox(
                        width: 17,
                      ),
                      const Text(
                        'Ingredients',
                        style: TextStyle(
                            color: CustomColors.grey4,
                            fontWeight: FontWeight.w400,
                            fontSize: CustomFontSize.primary),
                      ),
                      const Spacer(),
                      if (ingredients.length > 1)
                      GestureDetector(
                        onTap: () {
                          if (ingredients.length > 1) {
                            setState(() {
                              ingredients.removeLast();
                            });
                          }
                        },
                        child: Material(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.remove_rounded,
                              color: CustomColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 17,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            ingredients.add('');
                            ingredientAmounts.add('');
                          });
                        },
                        child: Material(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.add_rounded,
                              color: CustomColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 17,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: getIngredientInput(),
                ),
                const Divider(
                  height: 10,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                  color: CustomColors.grey3,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.format_list_numbered_rounded,
                        size: 20,
                        color: CustomColors.grey4,
                      ),
                      const SizedBox(
                        width: 17,
                      ),
                      const Text(
                        'Instructions',
                        style: TextStyle(
                            color: CustomColors.grey4,
                            fontWeight: FontWeight.w400,
                            fontSize: CustomFontSize.primary),
                      ),
                      const Spacer(),
                      if (instructions.length > 1)
                        GestureDetector(
                        onTap: () {
                          if (instructions.length > 1) {
                            setState(() {
                              instructions.removeLast();
                            });
                          }
                        },
                        child: Material(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.remove_rounded,
                              color: CustomColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 17,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            instructions.add('');
                          });
                        },
                        child: Material(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.add_rounded,
                              color: CustomColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 17,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: getInstructionsInput(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Material(
                          elevation: 1,
                          color: CustomColors.grey2,
                          shape: RoundedRectangleBorder(
                              side: const BorderSide(color: CustomColors.grey4, width: 2),
                              borderRadius: BorderRadius.circular(25)),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                  fontSize: CustomFontSize.big,
                                  color: CustomColors.grey4,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15,),
                      GestureDetector(
                        onTap: submit,
                        child: Material(
                          elevation: 1,
                          color: CustomColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.restaurant_menu_rounded,
                                  color: CustomColors.white,
                                  size: 25,
                                ),
                                const SizedBox(width: 5,),
                                Text(
                                  edit ? 'Save' : 'Create',
                                  style: const TextStyle(
                                      fontSize: CustomFontSize.big,
                                      color: CustomColors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget getToolsInput() {
//   List<Widget> inputs = [];
//
//   for (int i = 0; i < numTools; i++) {
//     inputs.add(
//       const TextField(
//         style: TextStyle(
//             color: CustomColors.black,
//             fontWeight: FontWeight.w400,
//             fontSize: CustomFontSize.secondary),
//         textCapitalization: TextCapitalization.sentences,
//         cursorColor: CustomColors.primary,
//         decoration: InputDecoration(
//           border: InputBorder.none,
//           focusedBorder: InputBorder.none,
//           enabledBorder: InputBorder.none,
//           errorBorder: InputBorder.none,
//           disabledBorder: InputBorder.none,
//           hintText: "tool...",
//         ),
//       ),
//     );
//   }
//
//   return Column(
//     children: inputs,
//   );
// }

// Padding(
//   padding: const EdgeInsets.symmetric(vertical: 10),
//   child: Row(
//     children: [
//       const Icon(
//         Icons.blender_outlined,
//         size: 20,
//         color: CustomColors.grey4,
//       ),
//       const SizedBox(
//         width: 17,
//       ),
//       const Text(
//         'Tools',
//         style: TextStyle(
//             color: CustomColors.grey4,
//             fontWeight: FontWeight.w400,
//             fontSize: CustomFontSize.primary),
//       ),
//       const Spacer(),
//       GestureDetector(
//         onTap: () {
//           if (numTools > 1) {
//             setState(() {
//               numTools--;
//             });
//           }
//         },
//         child: Material(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(40)),
//           child: const Padding(
//             padding: EdgeInsets.all(5),
//             child: Icon(
//               Icons.remove_rounded,
//               color: CustomColors.primary,
//             ),
//           ),
//         ),
//       ),
//       const SizedBox(
//         width: 17,
//       ),
//       GestureDetector(
//         onTap: () {
//           setState(() {
//             numTools++;
//           });
//         },
//         child: Material(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(40)),
//           child: const Padding(
//             padding: EdgeInsets.all(5),
//             child: Icon(
//               Icons.add_rounded,
//               color: CustomColors.primary,
//             ),
//           ),
//         ),
//       ),
//       const SizedBox(
//         width: 17,
//       ),
//     ],
//   ),
// ),
// Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 12),
//   child: getToolsInput(),
// ),
// const Divider(
//   height: 10,
//   thickness: 1,
//   indent: 0,
//   endIndent: 0,
//   color: CustomColors.grey3,
// ),