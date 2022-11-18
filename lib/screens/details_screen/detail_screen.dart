import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:spork/components/buttons/info_box_button.dart';
import 'package:spork/components/buttons/my_text_button.dart';
import 'package:spork/models/models.dart';
import 'package:spork/provider.dart';
import 'package:spork/screens/details_screen/action_button.dart';
import 'package:spork/screens/details_screen/details_title_bar.dart';
import 'package:spork/screens/details_screen/details_header.dart';
import 'package:spork/screens/details_screen/ingredients.dart';
import 'package:spork/screens/details_screen/instructions.dart';
import 'package:spork/services/dialog_service.dart';
import 'package:spork/services/notification_service.dart';
import 'package:spork/theme.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({required this.recipe, Key? key}) : super(key: key);
  final Recipe recipe;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFabVisible = true;
  bool _expanded = false;
  final TextEditingController controller = TextEditingController();
  final dateFormat = DateFormat('MMM dd, yyyy');
  late DateTime createDate;
  late DateTime editDate;

  @override
  void initState() {
    if (widget.recipe.createDate != '') {
      createDate = DateTime.fromMillisecondsSinceEpoch(widget.recipe.createDate.seconds * 1000);
    }
    if (widget.recipe.editDate.toString() != '') {
      editDate = DateTime.fromMillisecondsSinceEpoch(widget.recipe.editDate.seconds * 1000);
    }
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double imgWidth = MediaQuery.of(context).size.width / 1;
    AppUser user = Provider.of<AppProvider>(context).user;

    void writeNote() {
      if (controller.text.length < 501) {
        Provider.of<AppProvider>(context, listen: false).writeNote(controller.text, widget.recipe.id);
        controller.clear();
        FocusScope.of(context).unfocus();
      } else {
        NotificationService.notify('500 character limit.');
      }
    }

    String getTotalTime(String cookTime, String prepTime) {
      int hours = int.parse(cookTime.substring(0, cookTime.indexOf(':')));
      int minutes = int.parse(cookTime.replaceRange(0, hours > 9 ? 3 : 2, ''));
      Duration cook = Duration(hours: hours, minutes: minutes);

      hours = int.parse(prepTime.substring(0, prepTime.indexOf(':')));
      minutes = int.parse(prepTime.replaceRange(0, hours > 9 ? 3 : 2, ''));
      Duration prep = Duration(hours: hours, minutes: minutes);

      Duration totalTime = prep + cook;

      String durationString = totalTime.toString();
      String hoursString = durationString.substring(0, durationString.indexOf(':'));
      durationString = durationString.replaceRange(0, int.parse(hoursString) > 9 ? 3 : 2, '');
      String minutesString = durationString.substring(0, durationString.indexOf(':'));

      return hoursString + ':' + minutesString;
    }

    return Scaffold(
      appBar: Provider.of<AppProvider>(context, listen: false).getZeroAppBar(CustomColors.white),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              elevation: 0,
              flexibleSpace: DetailsHeader(url: widget.recipe.photoUrl, id: widget.recipe.id),
              floating: true,
              automaticallyImplyLeading: false,
              toolbarHeight: imgWidth,
              snap: false,
              backgroundColor: Colors.transparent,
            ),
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: DelegateDetails(widget.recipe, MediaQuery.of(context).size.width / 1.285),
            ),
          ];
        },
        body: GestureDetector(
          onTap: () {
            if (Platform.isAndroid) {
              FocusScope.of(context).unfocus();
            }
          },
          child: NotificationListener<UserScrollNotification>(
            onNotification: (not) {
              if (not.direction == ScrollDirection.forward) {
                setState(() {
                  isFabVisible = true;
                });
                if (Platform.isIOS) {
                  FocusScope.of(context).unfocus();
                }
              } else if (not.direction == ScrollDirection.reverse) {
                setState(() {
                  isFabVisible = false;
                });
              }
              return true;
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Time:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: CustomFontSize.primary,
                                  color: CustomColors.grey4),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              getTotalTime(widget.recipe.cookTime, widget.recipe.prepTime),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: CustomFontSize.primary,
                                  color: CustomColors.grey4),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Prep Time:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: CustomFontSize.primary,
                                      color: CustomColors.grey4),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  "Cook Time:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: CustomFontSize.primary,
                                      color: CustomColors.grey4),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.recipe.prepTime,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: CustomFontSize.primary,
                                      color: CustomColors.grey4),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  widget.recipe.cookTime,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: CustomFontSize.primary,
                                      color: CustomColors.grey4),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ExpansionPanelList(
                      elevation: 0,
                      animationDuration: const Duration(milliseconds: 300),
                      children: [
                        ExpansionPanel(
                          backgroundColor: Colors.transparent,
                          headerBuilder: (context, isExpanded) {
                            return Card(
                              elevation: 3,
                              color: CustomColors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: ListTile(
                                title: Row(
                                  children: const [
                                    Icon(
                                      Icons.egg_outlined,
                                      color: CustomColors.grey4,
                                      size: 30,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'Ingredients',
                                      style: TextStyle(
                                        color: CustomColors.grey4,
                                        fontSize: CustomFontSize.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          body: ListTile(
                            title: Ingredients(widget.recipe.ingredients, widget.recipe.ingredientAmounts),
                          ),
                          isExpanded: _expanded,
                          canTapOnHeader: true,
                        ),
                      ],
                      dividerColor: Colors.grey,
                      expansionCallback: (panelIndex, isExpanded) {
                        _expanded = !_expanded;
                        setState(() {});
                      },
                    ),
                  ),
                  Column(
                    children: [
                      const Divider(
                        height: 20,
                        thickness: 1,
                        indent: 30,
                        endIndent: 30,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 5,
                          left: 10,
                          right: 10,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 10,
                              bottom: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(
                                  child: Text(
                                    'Instructions',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontFamily: 'LibreBodoni',
                                    ),
                                  ),
                                ),
                                Instructions(widget.recipe.instructions),
                                if (widget.recipe.instructions.isNotEmpty)
                                  const SizedBox(
                                    height: 20,
                                  ),
                                if (widget.recipe.url != '')
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () async {
                                      await Provider.of<AppProvider>(context, listen: false).openUrl(widget.recipe.url);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 20),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.link_rounded,
                                            color: CustomColors.grey4,
                                          ),
                                          const SizedBox(
                                            width: 7.5,
                                          ),
                                          Linkify(
                                            onOpen: (link) async {
                                              await Provider.of<AppProvider>(context, listen: false)
                                                  .openUrl(widget.recipe.url);
                                            },
                                            text: widget.recipe.url,
                                            style: const TextStyle(
                                                fontSize: CustomFontSize.primary, color: CustomColors.black),
                                            linkStyle: const TextStyle(
                                              fontSize: CustomFontSize.primary,
                                              color: CustomColors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (user.id != widget.recipe.creatorId)
                                  FutureBuilder<AppUser?>(
                                    future: Provider.of<AppProvider>(context, listen: false)
                                        .fetchUser(widget.recipe.creatorId),
                                    builder: (builder, snapshot) {
                                      if (snapshot.hasData) {
                                        AppUser? appUser = snapshot.data;
                                        if (appUser != null) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.person_outline_rounded,
                                                    color: CustomColors.grey4,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    appUser.name,
                                                    softWrap: true,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.fade,
                                                    style: const TextStyle(
                                                        color: CustomColors.grey4, fontSize: CustomFontSize.primary),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 24, bottom: 10),
                                                child: Text(
                                                  '@${appUser.userName}',
                                                  softWrap: true,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.fade,
                                                  style: const TextStyle(
                                                      color: CustomColors.grey4, fontSize: CustomFontSize.secondary),
                                                ),
                                              ),
                                            ],
                                          );
                                        } else {
                                          return const SizedBox();
                                        }
                                      } else {
                                        return const SizedBox();
                                      }
                                    },
                                  ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.restaurant_menu_rounded,
                                      color: CustomColors.grey4,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      widget.recipe.savedIds.length == 1
                                          ? '1 save'
                                          : '${widget.recipe.savedIds.length.toString()} saves',
                                      softWrap: true,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      style: const TextStyle(
                                          color: CustomColors.grey4, fontSize: CustomFontSize.secondary),
                                    ),
                                  ],
                                ),
                                if (widget.recipe.createDate != '')
                                const SizedBox(height: 5,),
                                if (widget.recipe.createDate != '')
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_outlined,
                                      color: CustomColors.grey4,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      dateFormat.format(createDate),
                                      softWrap: true,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      style: const TextStyle(
                                          color: CustomColors.grey4, fontSize: CustomFontSize.secondary),
                                    ),
                                  ],
                                ),
                                if (widget.recipe.editDate != '')
                                  const SizedBox(height: 5,),
                                if (widget.recipe.editDate != '')
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.edit,
                                        color: CustomColors.grey4,
                                        size: 20,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        dateFormat.format(editDate),
                                        softWrap: true,
                                        maxLines: 1,
                                        overflow: TextOverflow.fade,
                                        style: const TextStyle(
                                            color: CustomColors.grey4, fontSize: CustomFontSize.secondary),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (widget.recipe.notes.isNotEmpty || widget.recipe.savedIds.contains(user.id)  || widget.recipe.homeIds.contains(user.homeId))
                      const Divider(
                        height: 20,
                        thickness: 1,
                        indent: 30,
                        endIndent: 30,
                        color: Colors.grey,
                      ),
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: Provider.of<AppProvider>(context, listen: false).recipe(widget.recipe.id),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final recipeDoc = snapshot.data;
                              final recipeStream = Recipe.fromJson(recipeDoc!.data()!);
                              List<String> notes = recipeStream.notes;
                              List<String> notesCreators = recipeStream.notesCreators;

                              List<Widget> displayNotes = [];
                              for (int i = 0; i < notes.length; i++) {
                                displayNotes.add(
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 10, left: 5, top: 0),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: CustomColors.grey4,
                                              shape: BoxShape.circle,
                                            ),
                                            height: 3,
                                            width: 3,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            notes[i],
                                            softWrap: true,
                                            style: const TextStyle(
                                                color: CustomColors.grey4,
                                                fontSize: CustomFontSize.secondary,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                        if (notesCreators[i] == user.id || widget.recipe.creatorId == user.id)
                                          IconButton(
                                              onPressed: () async {
                                                bool? answer = await DialogService.dialogBox(
                                                  context: context,
                                                  title: 'Remove note?',
                                                  body: Text(
                                                      notes[i],
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
                                                      isPrimary: true,
                                                    ),
                                                  ],
                                                );
                                                bool checkForNullAnswer = answer ?? false;
                                                if (checkForNullAnswer) {
                                                  await Provider.of<AppProvider>(context, listen: false)
                                                      .deleteNote(i, recipeStream);
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.close,
                                                color: CustomColors.grey4,
                                                size: 20,
                                              ),)
                                      ],
                                    ),
                                  ),
                                );
                              }

                              if (recipeStream.notes.isNotEmpty) {
                                return Column(
                                  children: [
                                    const Center(
                                      child: Text(
                                        'Notes',
                                        style: TextStyle(
                                          fontSize: CustomFontSize.big,
                                          fontFamily: 'LibreBodoni',
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 30),
                                      child: Column(
                                        children: displayNotes,
                                      ),
                                    )
                                  ],
                                );
                              }
                            }
                            return const SizedBox();
                          },
                        ),
                      if (widget.recipe.savedIds.contains(user.id) || widget.recipe.homeIds.contains(user.homeId))
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: TextField(
                            controller: controller,
                            maxLines: 4,
                            minLines: 1,
                            textInputAction: TextInputAction.done,
                            onEditingComplete: writeNote,
                            style: const TextStyle(
                                color: CustomColors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: CustomFontSize.primary),
                            textCapitalization: TextCapitalization.sentences,
                            cursorColor: CustomColors.primary,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              icon: Icon(
                                Icons.edit_note_rounded,
                                size: 20,
                              ),
                              hintText: "Write a note...",
                            ),
                          ),
                        ),
                      if (controller.text.isNotEmpty) MyTextButton(text: 'submit', action: writeNote),
                      const SizedBox(height: 30,)
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: isFabVisible ? 1 : 0,
        duration: const Duration(milliseconds: 100),
        child: DetailsActionButton(recipe: widget.recipe),
      ),
    );
  }
}
