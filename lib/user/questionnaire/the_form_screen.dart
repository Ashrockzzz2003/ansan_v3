import 'package:ansan/model/question.dart';
import 'package:ansan/user/home_screen.dart';
import 'package:ansan/util/loading_screen.dart';
import 'package:ansan/util/toast_message.dart';
import 'package:ansan/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:im_stepper/stepper.dart';

class UserQuestionnaireForm extends StatefulWidget {
  const UserQuestionnaireForm({super.key});

  @override
  State<UserQuestionnaireForm> createState() => _UserQuestionnaireFormState();
}

class _UserQuestionnaireFormState extends State<UserQuestionnaireForm> {
  bool _isLoading = false;

  int activeStep = 0;
  int maxIndex = 35;

  List<int> numbers = List.generate(35, (index) => index + 1);

  late List<TextEditingController> controllers;

  late List<Question> questionList;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });

    if (FirebaseAuth.instance.currentUser == null) {
      showToast("You are not logged in yet. Please login first.");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
        (route) => false,
      );
      return;
    }

    controllers = List.generate(maxIndex, (index) {
      return TextEditingController();
    });

    questionList = [
      // Level 1
      Question(
        questionFull: "Please enter your height in cm",
        questionLabel: "Height",
        placeHolder: "Your height in (cm)",
        icon: const Icon(Icons.height_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: false,
        isText: false,
        isNumber: true,
        controller: controllers[0],
        validator: _fieldValidator,
      ),
      Question(
        questionFull: "Please enter your weight in kg",
        questionLabel: "Weight",
        placeHolder: "Your weight in (kg)",
        icon: const Icon(Icons.balance_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: false,
        isText: false,
        isNumber: true,
        controller: controllers[1],
        validator: _fieldValidator,
      ),
      Question(
        questionFull: "Please select your COVID vaccination status",
        questionLabel: "Vaccination Status",
        placeHolder: "Your vaccination status",
        icon: const Icon(Icons.medical_services_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const [
          "Fully Vaccinated",
          "Partially Vaccinated",
          "Not Vaccinated"
        ],
        values: const [
          "Fully Vaccinated",
          "Partially Vaccinated",
          "Not Vaccinated"
        ],
        controller: controllers[2],
      ),
      Question(
        questionFull: "Do you have any allergies?",
        questionLabel: "Allergies",
        placeHolder: "Your allergies",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[3],
      ),
      Question(
        questionFull: "Please enter your allergies",
        questionLabel: "Allergies",
        placeHolder: "Your allergies",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: false,
        isText: true,
        isNumber: false,
        controller: controllers[4],
        validator: _fieldValidator,
      ),
      Question(
        questionFull: "Please enter symptoms observed. (Enter NIL if none)",
        questionLabel: "Symptoms",
        placeHolder: "Your symptoms",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: false,
        isText: true,
        isNumber: false,
        controller: controllers[5],
        validator: _fieldValidator,
      ),
      Question(
        questionFull:
            "How long have you been experiencing symptoms? (Enter NIL if none)",
        questionLabel: "Symptoms Duration",
        placeHolder: "x days or y weeks",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: false,
        isText: true,
        isNumber: false,
        controller: controllers[6],
        validator: _fieldValidator,
      ),
      Question(
        questionFull: "Any accidents or injuries?",
        questionLabel: "Accidents/Injuries",
        placeHolder: "Your accidents/injuries",
        icon: const Icon(Icons.medical_services_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[7],
      ),
      Question(
        questionFull:
            "Any long term medication? Please specify. (Enter NIL if none)",
        questionLabel: "Medication",
        placeHolder: "Your medication",
        icon: const Icon(Icons.medical_services_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: false,
        isText: true,
        isNumber: false,
        controller: controllers[8],
        validator: _fieldValidator,
      ),
      Question(
        questionFull: "Any past medical history.",
        questionLabel: "Medical History",
        placeHolder: "Your medical history",
        icon: const Icon(Icons.medical_services_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: true,
        isText: false,
        isNumber: false,
        options: const [
          "Blood Pressure",
          "Diabetes",
          "Eye Diseases",
          "Thyroid",
          "Other Comorbidity Conditions",
          "None"
        ],
        values: const [
          "Blood Pressure",
          "Diabetes",
          "Eye Diseases",
          "Thyroid",
          "Other Comorbidity Conditions",
          "None"
        ],
        controller: controllers[9],
      ),
      Question(
        questionFull: "Other consumptions.",
        questionLabel: "Consumptions",
        placeHolder: "Your consumptions",
        icon: const Icon(Icons.medical_services_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: true,
        isText: false,
        isNumber: false,
        options: const [
          "Tobacco Chewing",
          "Smoking",
          "Alcohol",
          "Others",
          "None"
        ],
        values: const [
          "Tobacco Chewing",
          "Smoking",
          "Alcohol",
          "Others",
          "None"
        ],
        controller: controllers[10],
      ),
      Question(
        questionFull: "Family History",
        questionLabel: "Family History",
        placeHolder: "Your family history",
        icon: const Icon(Icons.medical_services_rounded),
        isRequired: true,
        isMultipleChoice: false,
        isMultiSelect: true,
        isText: false,
        isNumber: false,
        options: const [
          "Blood Pressure",
          "Diabetes",
          "Glaucoma",
          "Cataract",
          "Diabetic Retinopathy",
          "Other Eye Disease",
          "None"
        ],
        values: const [
          "Blood Pressure",
          "Diabetes",
          "Glaucoma",
          "Cataract",
          "Diabetic Retinopathy",
          "Other Eye Disease",
          "None"
        ],
        controller: controllers[11],
      ),

      // Level 2
      /*
      req.body.redness == null ||
      req.body.pain == null ||
      req.body.halos == null ||
      req.body.suddenExacerbation == null ||
      req.body.consulted == null ||
      req.body.medicines == null ||
      req.body.generalInvestigation == null ||
      req.body.diabeticRetinopathy == null ||
      req.body.macularDegenerations == null ||
      req.body.macularhole == null ||
      req.body.glaucoma == null ||
      req.body.catract == null ||
      req.body.uveitis == null ||
      req.body.fundusPhotography == null ||
      req.body.fundusAngiography == null ||
      req.body.opticalCoherenceTomography == null ||
      req.body.visualFieldAnalysis == null ||
      req.body.gonioscopy == null ||
      req.body.centralCornealThicknessAnalysis == null ||
      req.body.slitLampInvestigation == null ||
      req.body.applanationTonometry == null ||
      req.body.bScan == null ||
      req.body.biochemicalParameters == null
      */
      Question(
        questionFull: "Do you face Redness of eye?",
        questionLabel: "Redness Of Eye",
        placeHolder: "Redness Of Eye",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[12],
      ),
      Question(
        questionFull: "Do you face pain in eye?",
        questionLabel: "Pain In Eyes",
        placeHolder: "Pain In Eyes",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[13],
      ),
      Question(
        questionFull: "Do you see halos around lights?",
        questionLabel: "Halos around lights",
        placeHolder: "Halos around lights",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[14],
      ),
      Question(
        questionFull: "Any time you had sudden exacerbation of the problem?",
        questionLabel: "Sudden Exacerbation",
        placeHolder: "Sudden Exacerbation",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[15],
      ),
      Question(
        questionFull: "Did you show to any doctor for this problem?",
        questionLabel: "Consulted",
        placeHolder: "Consulted",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[16],
      ),
      Question(
        questionFull: "Have you been taking any medicines for this problem?",
        questionLabel: "Medicines",
        placeHolder: "Medicines",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[17],
      ),
      Question(
        questionFull: "Any general investigations you have got done?",
        questionLabel: "General Investigations",
        placeHolder: "General Investigations",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[18],
      ),
      Question(
        questionFull: "Do you have diabetic retinopathy?",
        questionLabel: "Diabetic Retinopathy",
        placeHolder: "Diabetic Retinopathy",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[19],
      ),
      Question(
        questionFull: "Do you have macular degenerations?",
        questionLabel: "Macular Degenerations",
        placeHolder: "Macular Degenerations",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[20],
      ),
      Question(
        questionFull: "Do you have macular hole?",
        questionLabel: "Macular Hole",
        placeHolder: "Macular Hole",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[21],
      ),
      Question(
        questionFull: "Do you have glaucoma?",
        questionLabel: "Glaucoma",
        placeHolder: "Glaucoma",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[22],
      ),
      Question(
        questionFull: "Do you have cataract?",
        questionLabel: "Cataract",
        placeHolder: "Cataract",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[23],
      ),
      Question(
        questionFull: "Do you have uveitis?",
        questionLabel: "Uveitis",
        placeHolder: "Uveitis",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[24],
      ),
      Question(
        questionFull: "Have you got Fundus Photography investigations?",
        questionLabel: "Fundus Photography",
        placeHolder: "Fundus Photography",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[25],
      ),
      Question(
        questionFull: "Have you got Fundus Angiography investigations?",
        questionLabel: "Fundus Angiography",
        placeHolder: "Fundus Angiography",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[26],
      ),
      Question(
        questionFull:
            "Have you got Optical Coherence Tomography investigations?",
        questionLabel: "Optical Coherence Tomography",
        placeHolder: "Optical Coherence Tomography",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[27],
      ),
      Question(
        questionFull: "Have you got Visual Field Analysis investigations?",
        questionLabel: "Visual Field Analysis",
        placeHolder: "Visual Field Analysis",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[28],
      ),
      Question(
        questionFull: "Have you got Gonioscopy investigations?",
        questionLabel: "Gonioscopy",
        placeHolder: "Gonioscopy",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[29],
      ),
      Question(
        questionFull:
            "Have you got Central Corneal Thickness Analysis investigations?",
        questionLabel: "Central Corneal Thickness Analysis",
        placeHolder: "Central Corneal Thickness Analysis",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[30],
      ),
      Question(
        questionFull: "Have you got Slit Lamp investigations?",
        questionLabel: "Slit Lamp",
        placeHolder: "Slit Lamp",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[31],
      ),
      Question(
        questionFull: "Have you got Applanation Tonometry investigations?",
        questionLabel: "Applanation Tonometry",
        placeHolder: "Applanation Tonometry",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[32],
      ),
      Question(
        questionFull: "Have you got B Scan investigations?",
        questionLabel: "B Scan",
        placeHolder: "B Scan",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[33],
      ),
      Question(
        questionFull: "Have you got Biochemical Parameters investigations?",
        questionLabel: "Biochemical Parameters",
        placeHolder: "Biochemical Parameters",
        icon: const Icon(Icons.coronavirus_rounded),
        isRequired: true,
        isMultipleChoice: true,
        isMultiSelect: false,
        isText: false,
        isNumber: false,
        options: const ["Yes", "No", "Don't Know"],
        values: const ["Yes", "No", "Don't Know"],
        controller: controllers[34],
      ),
    ];
    setState(() {
      _isLoading = false;
    });
    super.initState();
  }

  @override
  void dispose() {
    for (var element in controllers) {
      element.dispose();
    }
    super.dispose();
  }

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: _isLoading == true
          ? const LoadingScreen()
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  pinned: true,
                  centerTitle: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  expandedHeight: MediaQuery.of(context).size.height * 0.16,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(
                      horizontal: 0.0,
                      vertical: 8.0,
                    ),
                    centerTitle: true,
                    collapseMode: CollapseMode.parallax,
                    background: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32.0),
                        bottomRight: Radius.circular(32.0),
                      ),
                      child: Image.asset(
                        "assets/ansan_1.jpg",
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    title: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        "Medical History",
                        style: GoogleFonts.habibi(
                          textStyle: Theme.of(context).textTheme.headlineSmall,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          NumberStepper(
                            activeStepColor:
                                Theme.of(context).primaryIconTheme.color,
                            activeStepBorderColor:
                                Theme.of(context).secondaryHeaderColor,
                            stepColor: Theme.of(context).splashColor,
                            lineColor: Theme.of(context).secondaryHeaderColor,
                            stepReachedAnimationEffect: Curves.easeInOutCubic,
                            enableStepTapping: false,
                            direction: Axis.horizontal,
                            enableNextPreviousButtons: false,
                            numbers: numbers,
                            activeStep: activeStep,
                            lineLength: 24,
                            onStepReached: (index) {
                              setState(() {
                                activeStep = index;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              previousButton(),
                              nextButton(),
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.outline),
                            ),
                            child: Column(
                              children: [
                                Form(
                                  autovalidateMode: AutovalidateMode.disabled,
                                  key: _formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      questionList[activeStep],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<String> _submitSurvey() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (FirebaseAuth.instance.currentUser == null) {
        showToast("You are not logged in yet. Please login first.");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomeScreen(),
          ),
          (route) => false,
        );
        return "-1";
      }

      debugPrint({
        "height": controllers[0].text.toString(),
        "weight": controllers[1].text.toString(),
        "covidVaccination": controllers[2].text.toString(),
        "anyAllergies": controllers[3].text.toString(),
        "allergies": controllers[4].text.toString(),
        "symptoms": controllers[5].text.toString(),
        "symptomDuration": controllers[6].text.toString(),
        "injury": controllers[7].text.toString(),
        "medication": controllers[8].text.toString(),
        "medicalHistory": controllers[9].text.toString(),
        "consumptions": controllers[10].text.toString(),
        "familyHistory": controllers[11].text.toString(),
        // Lvl 2
        "redness": controllers[12].text.toString(),
        "pain": controllers[13].text.toString(),
        "halos": controllers[14].text.toString(),
        "suddenExacerbation": controllers[15].text.toString(),
        "consulted": controllers[16].text.toString(),
        "medicines": controllers[17].text.toString(),
        "generalInvestigation": controllers[18].text.toString(),
        "diabeticRetinopathy": controllers[19].text.toString(),
        "macularDegenerations": controllers[20].text.toString(),
        "macularhole": controllers[21].text.toString(),
        "glaucoma": controllers[22].text.toString(),
        "catract": controllers[23].text.toString(),
        "uveitis": controllers[24].text.toString(),
        "fundusPhotography": controllers[25].text.toString(),
        "fundusAngiography": controllers[26].text.toString(),
        "opticalCoherenceTomography": controllers[27].text.toString(),
        "visualFieldAnalysis": controllers[28].text.toString(),
        "gonioscopy": controllers[29].text.toString(),
        "centralCornealThicknessAnalysis": controllers[30].text.toString(),
        "slitLampInvestigation": controllers[31].text.toString(),
        "applanationTonometry": controllers[32].text.toString(),
        "bScan": controllers[33].text.toString(),
        "biochemicalParameters": controllers[34].text.toString(),
        "createdAt": FieldValue.serverTimestamp(),
        "createdBy": FirebaseAuth.instance.currentUser!.uid,
      }.toString());

      final theFormData = {
        "height": controllers[0].text.toString(),
        "weight": controllers[1].text.toString(),
        "covidVaccination": controllers[2].text.toString(),
        "anyAllergies": controllers[3].text.toString(),
        "allergies": controllers[4].text.toString(),
        "symptoms": controllers[5].text.toString(),
        "symptomDuration": controllers[6].text.toString(),
        "injury": controllers[7].text.toString(),
        "medication": controllers[8].text.toString(),
        "medicalHistory": controllers[9].text.toString(),
        "consumptions": controllers[10].text.toString(),
        "familyHistory": controllers[11].text.toString(),
        // Lvl 2
        "redness": controllers[12].text.toString(),
        "pain": controllers[13].text.toString(),
        "halos": controllers[14].text.toString(),
        "suddenExacerbation": controllers[15].text.toString(),
        "consulted": controllers[16].text.toString(),
        "medicines": controllers[17].text.toString(),
        "generalInvestigation": controllers[18].text.toString(),
        "diabeticRetinopathy": controllers[19].text.toString(),
        "macularDegenerations": controllers[20].text.toString(),
        "macularhole": controllers[21].text.toString(),
        "glaucoma": controllers[22].text.toString(),
        "catract": controllers[23].text.toString(),
        "uveitis": controllers[24].text.toString(),
        "fundusPhotography": controllers[25].text.toString(),
        "fundusAngiography": controllers[26].text.toString(),
        "opticalCoherenceTomography": controllers[27].text.toString(),
        "visualFieldAnalysis": controllers[28].text.toString(),
        "gonioscopy": controllers[29].text.toString(),
        "centralCornealThicknessAnalysis": controllers[30].text.toString(),
        "slitLampInvestigation": controllers[31].text.toString(),
        "applanationTonometry": controllers[32].text.toString(),
        "bScan": controllers[33].text.toString(),
        "biochemicalParameters": controllers[34].text.toString(),
        "createdAt": FieldValue.serverTimestamp(),
        "createdBy": FirebaseAuth.instance.currentUser!.uid,
      };

      final db = FirebaseFirestore.instance;

      await db
          .collection("userData")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("medicalHistory")
          .add(theFormData);
      await db
          .collection("userData")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        "numberOfQuestionnairesTaken": FieldValue.increment(1),
      }, SetOptions(merge: true));

      showToast("Your medical history has been submitted successfully.");

      return "1";
    } catch (e) {
      debugPrint("Error: $e");
      showToast("Something went wrong. Please try again later.");
      return "-2";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    return "-1";
  }

  Widget nextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: MaterialButton(
        onPressed: activeStep == maxIndex - 1
            ? () async {
                if (_formKey.currentState!.validate() &&
                    controllers[activeStep].text.isNotEmpty) {
                  _formKey.currentState!.save();
                  _submitSurvey().then((value) {
                    if (value == "-1" ||
                        value == "-2" ||
                        value == "-3" ||
                        value == "-4") {
                      setState(() {
                        activeStep = 0;
                      });
                      return;
                    }

                    Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(
                        builder: (context) {
                          return const UserHomeScreen();
                        },
                      ),
                      (route) => false,
                    );
                  });
                } else {
                  showToast(
                    "Please select an option or fill the filed to proceed",
                  );
                }
              }
            : () {
                if (_formKey.currentState!.validate() &&
                    controllers[activeStep].text.isNotEmpty) {
                  _formKey.currentState!.save();

                  if (activeStep < maxIndex - 1) {
                    if (activeStep == 3) {
                      if (controllers[activeStep].text == "Yes") {
                        setState(() {
                          activeStep++;
                        });
                      } else {
                        setState(() {
                          controllers[activeStep + 1].text = "NIL";
                          activeStep += 2;
                        });
                      }
                    } else {
                      setState(() {
                        activeStep++;
                      });
                    }
                  }
                } else {
                  showToast(
                      "Please select an option or fill the filed to proceed");
                }
              },
        minWidth:
            activeStep == 0 ? MediaQuery.of(context).size.width * 0.8 : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        color: Theme.of(context).colorScheme.primary,
        child: Text(
          activeStep == maxIndex - 1 ? "Submit" : "Next",
          style: GoogleFonts.poppins(
            textStyle: Theme.of(context).textTheme.titleMedium,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }

  Widget previousButton() {
    return activeStep > 0
        ? Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: MaterialButton(
              onPressed: activeStep <= 0
                  ? null
                  : () {
                      // Decrement activeStep, when the previous button is tapped. However, check for lower bound i.e., must be greater than 0.
                      if (activeStep > 0) {
                        if (activeStep == 5) {
                          if (controllers[3].text == "Yes") {
                            setState(() {
                              activeStep--;
                            });
                          } else {
                            setState(() {
                              controllers[activeStep - 1].text = "NIL";
                              activeStep -= 2;
                            });
                          }
                        } else {
                          setState(() {
                            activeStep--;
                          });
                        }
                      }
                    },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              color: activeStep > 0
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).disabledColor,
              child: Text(
                "Previous",
                style: GoogleFonts.poppins(
                  textStyle: Theme.of(context).textTheme.titleMedium,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          )
        : const SizedBox();
  }
}
