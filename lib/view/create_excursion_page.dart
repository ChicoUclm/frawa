import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:uuid/uuid.dart';

import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/controllers/user_controller.dart';

import 'package:excursiona/model/excursion.dart';
import 'package:excursiona/model/user_model.dart';

import 'package:excursiona/shared/assets.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';

import 'package:excursiona/view/excursion_page.dart';
import 'package:excursiona/view/perimeter_page.dart';
import 'package:excursiona/view/search_participants_page.dart';
import 'package:excursiona/view/widgets/add_participant_avatar.dart';
import 'package:excursiona/view/widgets/form_button.dart';
import 'package:excursiona/view/widgets/participant_avatar.dart';

const _minPerimeterRadius = 1.0;
const _maxPerimeterRadius = 10.0;

class CreateExcursionPage extends StatefulWidget {
  const CreateExcursionPage({super.key});

  @override
  State<CreateExcursionPage> createState() => _CreateExcursionPageState();
}

class _CreateExcursionPageState extends State<CreateExcursionPage> {
  UserModel? currentUser;

  String _excursionName = "";
  String _dropdownValue = "Media";
  String _description = "";
  final _formKey = GlobalKey<FormState>();
  final Set<UserModel> _participants = {};
  final UserController _userController = UserController();

  late LatLng? _perimeterCenter;
  late double _perimeterRadius;
  final TextEditingController _perimeterRadiusController =
      TextEditingController();
  final TextEditingController _perimeterCenterController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _setPositionData();
    _setPerimeterRadius(_minPerimeterRadius.toInt());
    _initializeParticipants();
  }

  _setPositionData() {
    getCurrentPosition().then((value) async {
      setState(() {
        _updatePerimeterCenter(LatLng(value.latitude, value.longitude));
      });
    }).catchError((error) {
      showSnackBar(context, Theme.of(context).primaryColor, error.toString());
    });
  }

  _setPerimeterRadius(int radius) {
    _perimeterRadius = radius.toDouble();
    _updatePerimeterRadius(_minPerimeterRadius);
  }

  _initializeParticipants() async {
    currentUser = await _userController.getUserBasicInfo();
    setState(() {
      _participants.add(currentUser!);
    });
  }

  _addParticipants() async {
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    Set<UserModel>? result = await nextScreen(
        context,
        SearchParticipantsPage(alreadyParticipants: _participants),
        PageTransitionType.rightToLeftWithFade);
    if (result == null) return;
    setState(() {
      _participants.addAll(result);
    });
  }

  _deleteParticipant(UserModel user) {
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    setState(() {
      _participants.remove(user);
    });
  }

  _showLoadingDialog() {
    showDialog(
        barrierColor: Constants.darkWhite.withOpacity(0.8),
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(Assets.resourceImagesMaploader,
                        height: 200, width: 200),
                    // SizedBox(height: 20),
                    Text(
                      "Creando excursión...",
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ));
        });
  }

  _createExcursion() async {
    if (!_formKey.currentState!.validate()) return;
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    _showLoadingDialog();

    Excursion excursion = Excursion(
      date: DateTime.now(),
      description: _description,
      difficulty: _dropdownValue,
      id: const Uuid().v4(),
      ownerName: currentUser!.name,
      ownerPic: currentUser!.profilePic,
      perimeterCenter: _perimeterCenter!,
      perimeterRadius: _perimeterRadius * 100,
      title: _excursionName,
    );

    var result =
        await ExcursionController().createExcursion(excursion, _participants);

    if (result == false) {
      Navigator.of(context).pop();
      showSnackBar(context, Colors.red, "Hubo un error al crear la excursión");
    } else {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      showSnackBar(context, Colors.green, "Excursión creada con éxito");
      nextScreenReplace(
          context,
          ExcursionPage(
            excursionId: excursion.id,
            excursion: excursion,
            participants: _participants,
          ),
          PageTransitionType.fade);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crear excursión", style: GoogleFonts.inter()),
        foregroundColor: Colors.black,
        backgroundColor: const Color(0xFFFAFAFA),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: _formKey,
                  child: TextFormField(
                    autocorrect: false,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 40,
                    decoration: InputDecoration(
                      labelText: "Título de la excursión *",
                      labelStyle: GoogleFonts.inter(
                          textStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w300)),
                      prefixIcon: const Icon(
                        Icons.info,
                        color: Constants.indigoDye,
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Constants.indigoDye),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Constants.indigoDye),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _excursionName = value.trim());
                    },
                    validator: (value) {
                      return value!.isEmpty
                          ? "Por favor ingrese un título"
                          : null;
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Participantes",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  height: 150,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Constants.border,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: Constants.boxShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _participants.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _participants.length) {
                              return AddParticipantAvatar(
                                  onTap: _addParticipants);
                            }
                            return ParticipantAvatar(
                              user: _participants.elementAt(index),
                              onDelete: () => _deleteParticipant(
                                  _participants.elementAt(index)),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Nº de participantes: ${_participants.length}",
                        style: GoogleFonts.inter(
                            textStyle: const TextStyle(fontSize: 13)),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _perimeterCenterController,
                  decoration: InputDecoration(
                    labelText: "Centro del perímetro",
                    alignLabelWithHint: true,
                    labelStyle: GoogleFonts.inter(
                        textStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w300)),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Constants.indigoDye)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Constants.indigoDye)),
                  ),
                  onTap: () {
                    if (_perimeterCenter == null) {
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PerimeterPage(
                          initialLocation: _perimeterCenter!,
                          onLocationSelected: _updatePerimeterCenter,
                          perimeterRadius: _perimeterRadius * 100,
                        ),
                      ),
                    );
                  },
                  readOnly: true,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _perimeterRadiusController,
                  decoration: InputDecoration(
                    labelText: "Radio del perímetro (metros)",
                    alignLabelWithHint: true,
                    labelStyle: GoogleFonts.inter(
                        textStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w300)),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Constants.indigoDye)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Constants.indigoDye)),
                  ),
                  onTap: () => _showNumberPicker(context),
                  readOnly: true,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Descripción de la excursión",
                    alignLabelWithHint: true,
                    labelStyle: GoogleFonts.inter(
                        textStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w300)),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Constants.indigoDye)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Constants.indigoDye)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _description = value.trim();
                    });
                  },
                  maxLines: 4,
                  minLines: 1,
                  maxLength: 200,
                ),
                const SizedBox(height: 8),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Dificultad de la excursión",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 20),
                      DropdownButton(
                          iconEnabledColor: Constants.indigoDye,
                          value: _dropdownValue,
                          style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                  fontSize: 16, color: Colors.black)),
                          alignment: Alignment.centerLeft,
                          items: const [
                            DropdownMenuItem(
                                value: "Fácil", child: Text("Fácil")),
                            DropdownMenuItem(
                                value: "Media", child: Text("Media")),
                            DropdownMenuItem(
                                value: "Difícil", child: Text("Difícil")),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _dropdownValue = value!;
                            });
                          }),
                    ]),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 38.0),
                  child: FormButton(
                      text: "Empezar excursión",
                      onPressed: _createExcursion,
                      icon: Icons.play_arrow_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _updatePerimeterCenter(LatLng position) {
    setState(() {
      _perimeterCenter = position;
      _perimeterCenterController.text =
          "${position.latitude}, ${position.longitude}";
    });
  }

  _updatePerimeterRadius(double radius) {
    _perimeterRadiusController.text = (radius * 100).toInt().toString();
  }

  _showNumberPicker(BuildContext context) {
    _updatePerimeterRadius(_minPerimeterRadius);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: CupertinoPicker(
            itemExtent: 30,
            onSelectedItemChanged: (int value) {
              _setPerimeterRadius(value + 1);
              _updatePerimeterRadius(value + 1);
            },
            children: List<Widget>.generate(
                (_maxPerimeterRadius - _minPerimeterRadius + 1).toInt(),
                (int index) {
              return Center(
                  child: Text(((_minPerimeterRadius + index) * 100)
                      .toInt()
                      .toString()));
            }),
          ),
        );
      },
    );
  }
}
