import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spork/components/buttons/info_box_button.dart';
import 'package:spork/components/buttons/primary_button.dart';
import 'package:spork/components/buttons/secondary_button.dart';
import 'package:spork/models/models.dart';
import 'package:spork/services/dialog_service.dart';
import 'package:spork/services/notification_service.dart';
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
  late String visibility;
  late List<String> ingredients;
  late List<String> ingredientAmounts;
  late List<String> instructions;
  late String cookTime;
  late String prepTime;
  late String recipeName;
  late String photoUrl;
  late String url;
  bool edit = false;

  Widget getIngredientInput() {
    List<Widget> inputs = [];

    for (int i = 0; i < ingredients.length; i++) {
      inputs.add(Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: ingredientAmounts[i],
              style: const TextStyle(
                  color: CustomColors.black, fontWeight: FontWeight.w400, fontSize: CustomFontSize.secondary),
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
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: TextFormField(
              initialValue: ingredients[i],
              style: const TextStyle(
                  color: CustomColors.black, fontWeight: FontWeight.w400, fontSize: CustomFontSize.secondary),
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
          initialValue: instructions[i - 1],
          style: const TextStyle(
              color: CustomColors.black, fontWeight: FontWeight.w400, fontSize: CustomFontSize.secondary),
          textCapitalization: TextCapitalization.sentences,
          cursorColor: CustomColors.primary,
          onChanged: (String? newValue) {
            setState(() {
              instructions[i - 1] = newValue!;
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

  bool verifyInstructions() {
    bool verify = url.isNotEmpty;
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
    bool? answer = await DialogService.dialogBox(
      context: context,
      title: 'Delete Recipe?',
      body: const Text(
        'This cannot be undone.',
        style: InfoBoxTextStyle.body,
      ),
      actions: [
        InfoBoxButton(
          action: () {
            Navigator.of(context).pop(false);
          },
          text: 'Cancel',
          isPrimary: true,
        ),
        InfoBoxButton(
          action: () {
            Navigator.of(context).pop(true);
          },
          text: 'Confirm',
          isPrimary: false,
        ),
      ],
    );
    bool checkForNullAnswer = answer ?? false;
    if (checkForNullAnswer) {
      Navigator.pop(context);
      Navigator.pop(context);
      await Provider.of<AppProvider>(context, listen: false).deleteRecipe(widget.recipe!);
    }
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
    verify = verifyAmounts();
    if (!verify) {
      NotificationService.notify('Ingredients must have an amount.');
      return;
    }
    verify = verifyInstructions();
    if (!verify) {
      NotificationService.notify('Recipe must have instructions or a link.');
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

    if (Platform.isAndroid) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    Navigator.pop(context);
    if (edit) {
      Navigator.pop(context);
      Recipe recipe = Recipe(
          id: widget.recipe!.id,
          name: recipeName,
          className: recipeClass,
          cookTime: cookTime,
          prepTime: prepTime,
          ingredientAmounts: recipeAmounts,
          ingredients: recipeIngredients,
          instructions: recipeInstructions,
          queryName: recipeName.toLowerCase(),
          visibility: visibility,
          menuIds: widget.recipe!.menuIds,
          savedIds: widget.recipe!.savedIds,
          creatorId: widget.recipe!.creatorId,
          homeIds: widget.recipe!.homeIds,
          url: url,
          editDate: DateTime.now(),
          notes: widget.recipe!.notes,
          notesCreators: widget.recipe!.notesCreators,
          photoUrl: photoUrl);

      await Provider.of<AppProvider>(context, listen: false).updateRecipe(recipe);
    } else {
      Recipe recipe = Recipe(
          id: '',
          name: recipeName,
          className: recipeClass,
          cookTime: cookTime,
          prepTime: prepTime,
          ingredientAmounts: recipeAmounts,
          ingredients: recipeIngredients,
          instructions: recipeInstructions,
          queryName: recipeName.toLowerCase(),
          visibility: visibility,
          url: url,
          createDate: DateTime.now(),
          photoUrl: photoUrl);

      await Provider.of<AppProvider>(context, listen: false).createRecipe(recipe);
    }
  }

  @override
  void initState() {
    if (widget.recipe != null) {
      edit = true;
      visibility = widget.recipe!.visibility;
      recipeClass = widget.recipe!.className;
      ingredients = List<String>.from(widget.recipe!.ingredients);
      ingredientAmounts = List<String>.from(widget.recipe!.ingredientAmounts);
      instructions = List<String>.from(widget.recipe!.instructions);
      prepTime = widget.recipe!.prepTime;
      cookTime = widget.recipe!.cookTime;
      recipeName = widget.recipe!.name;
      photoUrl = widget.recipe!.photoUrl;
      url = widget.recipe!.url;
    } else {
      recipeClass = 'Main';
      visibility = 'follow';
      ingredients = ['', '', '', ''];
      ingredientAmounts = ['', '', '', ''];
      instructions = ['', '', ''];
      cookTime = '0:30';
      prepTime = '0:10';
      recipeName = '';
      photoUrl = '';
      url = '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppProvider>(context, listen: false).user;

    void choosePicture() async {
      String string64 = await Provider.of<AppProvider>(context, listen: false).choosePicture();
      setState(() {
        if (string64 != '') {
          photoUrl = string64;
        }
      });
    }

    Widget getPhoto() {
      if (Uri.parse(photoUrl).isAbsolute) {
        return CachedNetworkImage(
          imageUrl: photoUrl,
          imageBuilder: (context, imageProvider) => SizedBox(
            height: 100,
            width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image(
                image: imageProvider,
              ),
            ),
          ),
          placeholder: (context, url) => const SizedBox(
            height: 100,
            width: 100,
            child: Icon(
              Icons.add_photo_alternate_outlined,
              color: CustomColors.grey4,
            ),
          ),
          errorWidget: (context, url, error) => const SizedBox(
            height: 100,
            width: 100,
            child: Icon(
              Icons.add_photo_alternate_outlined,
              color: CustomColors.grey4,
            ),
          ),
        );
      } else if (photoUrl == '') {
        return const SizedBox(
          height: 100,
          width: 100,
          child: Icon(
            Icons.add_photo_alternate_outlined,
            color: CustomColors.grey4,
          ),
        );
      } else {
        return SizedBox(
            height: 100,
            width: 100,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(
                  base64Decode(photoUrl),
                  fit: BoxFit.contain,
                )));
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (Platform.isAndroid) {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: Platform.isIOS
              ? SystemUiOverlayStyle.light
              : const SystemUiOverlayStyle(
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
                  )),
          ],
          title: Text(
            edit ? 'Edit Recipe' : 'Create New Recipe',
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: CustomFontSize.primary, color: CustomColors.white),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          elevation: 3,
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: Platform.isIOS ? ScrollViewKeyboardDismissBehavior.onDrag : ScrollViewKeyboardDismissBehavior.manual,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Column(
              children: [
                TextFormField(
                  initialValue: recipeName,
                  style: const TextStyle(
                      color: CustomColors.black, fontWeight: FontWeight.w400, fontSize: CustomFontSize.primary),
                  textCapitalization: TextCapitalization.sentences,
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
                          const Text(
                            'Main',
                            style: TextStyle(fontSize: CustomFontSize.secondary, fontWeight: FontWeight.w500),
                          ),
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
                          const Text(
                            'Side',
                            style: TextStyle(fontSize: CustomFontSize.secondary, fontWeight: FontWeight.w500),
                          ),
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
                          const Text(
                            'Dessert',
                            style: TextStyle(fontSize: CustomFontSize.secondary, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            width: 15,
                          )
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
                              color: CustomColors.grey4, fontWeight: FontWeight.w400, fontSize: CustomFontSize.primary),
                        ),
                        const SizedBox(
                          width: 22,
                        ),
                        Text(
                          prepTime,
                          style: const TextStyle(
                              color: CustomColors.black, fontWeight: FontWeight.w500, fontSize: CustomFontSize.primary),
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
                        String hours = durationString.substring(0, durationString.indexOf(':'));
                        durationString = durationString.replaceRange(0, int.parse(hours) > 9 ? 3 : 2, '');
                        String minutes = durationString.substring(0, durationString.indexOf(':'));

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
                              color: CustomColors.grey4, fontWeight: FontWeight.w400, fontSize: CustomFontSize.primary),
                        ),
                        const SizedBox(
                          width: 17,
                        ),
                        Text(
                          cookTime,
                          style: const TextStyle(
                              color: CustomColors.black, fontWeight: FontWeight.w500, fontSize: CustomFontSize.primary),
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
                            color: CustomColors.grey4, fontWeight: FontWeight.w400, fontSize: CustomFontSize.primary),
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
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
                TextFormField(
                  initialValue: url,
                  keyboardType: TextInputType.url,
                  style: const TextStyle(
                      color: CustomColors.black, fontWeight: FontWeight.w400, fontSize: CustomFontSize.primary),
                  cursorColor: CustomColors.primary,
                  onChanged: (String? newValue) {
                    setState(() {
                      url = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    icon: Icon(
                      Icons.link_outlined,
                      size: 20,
                    ),
                    hintText: "Recipe link...",
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
                            color: CustomColors.grey4, fontWeight: FontWeight.w400, fontSize: CustomFontSize.primary),
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
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.image_outlined,
                            size: 20,
                            color: CustomColors.grey4,
                          ),
                          SizedBox(
                            width: 17,
                          ),
                          Text(
                            'Picture',
                            style: TextStyle(
                                color: CustomColors.grey4,
                                fontWeight: FontWeight.w400,
                                fontSize: CustomFontSize.primary),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15),
                        child: GestureDetector(
                          onTap: choosePicture,
                          child: Stack(
                            children: [
                              Material(
                                elevation: 3,
                                color: CustomColors.grey2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                child: getPhoto(),
                              ),
                              if (photoUrl != '')
                              Positioned(
                                top: 10,
                                left: 70,
                                child: GestureDetector(
                                  onTap: () async {
                                    if (Uri.parse(photoUrl).isAbsolute && widget.recipe != null) {
                                      await Provider.of<AppProvider>(context, listen: false).deleteImage(widget.recipe!.id);
                                    }
                                    setState(() {
                                      photoUrl = '';
                                    });
                                  },
                                  child: Material(
                                    elevation: 3,
                                    color: CustomColors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                    child: const Icon(Icons.close, color: CustomColors.grey4,),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.mobile_screen_share_rounded,
                            size: 20,
                            color: CustomColors.grey4,
                          ),
                          SizedBox(
                            width: 17,
                          ),
                          Text(
                            'Share recipe with...',
                            style: TextStyle(
                                color: CustomColors.grey4,
                                fontWeight: FontWeight.w400,
                                fontSize: CustomFontSize.primary),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Radio<String>(
                                value: 'private',
                                groupValue: visibility,
                                activeColor: CustomColors.primary,
                                onChanged: (String? value) async {
                                  setState(() {
                                    visibility = 'private';
                                  });
                                },
                              ),
                              Text(
                                user.homeId == '' ? 'Myself' : 'My Home',
                                style: const TextStyle(fontSize: CustomFontSize.secondary, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Radio<String>(
                                value: 'follow',
                                groupValue: visibility,
                                activeColor: CustomColors.primary,
                                onChanged: (String? value) async {
                                  setState(() {
                                    visibility = 'follow';
                                  });
                                },
                              ),
                              const Text(
                                'Followers',
                                style: TextStyle(fontSize: CustomFontSize.secondary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Radio<String>(
                                value: 'explore',
                                groupValue: visibility,
                                activeColor: CustomColors.primary,
                                onChanged: (String? value) async {
                                  setState(() {
                                    visibility = 'explore';
                                  });
                                },
                              ),
                              const Text(
                                'Everyone',
                                style: TextStyle(fontSize: CustomFontSize.secondary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SecondaryButton(text: 'Cancel', action: () => Navigator.pop(context)),
                      const SizedBox(
                        width: 15,
                      ),
                      PrimaryButton(
                        text: !edit ? 'Create' : 'Save',
                        action: submit,
                        isActive: true,
                        icon: const Icon(
                          Icons.restaurant_menu_rounded,
                          color: CustomColors.white,
                        ),
                      )
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
