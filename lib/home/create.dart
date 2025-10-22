
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/main.dart';
import 'package:step_progress/step_progress.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api.dart';
import '../global/global.dart';
import '../global/widgets.dart';
import 'package:dod_partner/main.dart' as np;

class CreateSeller extends StatefulWidget {
  const CreateSeller({super.key});

  @override
  State<CreateSeller> createState() => _CreateSellerState();
}

class _CreateSellerState extends State<CreateSeller> {

  late StepProgressController stepProgressController;

  XFile? banner, logo, gstfront,gstback , idcard, attorney;


  @override
  void initState() {
    super.initState();
    stepProgressController = StepProgressController(totalSteps: 4);
  }

  void onUpdate(){
    stepProgressController = StepProgressController(totalSteps: 4);
  }
  pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {
      return _file;
    }
    print('No Image Selected');
  }
  @override
  void dispose() {
    stepProgressController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return  Scaffold(
      body: Column(
        children: [
          Container(
            width: w,
            height: 120,
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text("Create Driver Profile",style: TextStyle(fontWeight: FontWeight.w800,fontSize: 22,color: Colors.white),),
                ),
                SizedBox(height: 10,),
                InkWell(
                  onTap: () async {
                    final Uri _url = Uri.parse('tel:+918269669272');
                    if (!await launchUrl(_url)) {
                      throw Exception('Could not launch $_url');
                    }
                  },
                  child: Row(
                    children: [
                      SizedBox(width: 10,),
                      Icon(Icons.support_agent,color: Colors.white,),SizedBox(width: 5,),
                      Text(" Support at : +91-8269669272",style: TextStyle(color: Colors.white),),SizedBox(width: 5,),
                      Icon(Icons.keyboard_arrow_down_outlined,color: Colors.white,),
                      SizedBox(width: 10,),
                      progress?CircularProgressIndicator():SizedBox(),
                      SizedBox(width: 5,),
                      Spacer(),
                      InkWell(
                          onTap: ()async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  title: Text("Log Out", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  content: Text("You sure to Log Out ? Your changes may not be saved"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () async {
                                        await FirebaseAuth.instance.signOut();
                                        await FirebaseAuth.instance.signOut();
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>np.MyHomePage(title: "",)));
                                      },
                                      child: const Text("Confirm",style: TextStyle(color: Colors.white),),
                                    ),
                                  ],
                                );
                              },
                            );
                              },
                          child: Icon(Icons.logout,color: Colors.white,)),SizedBox(width: 10,),
                    ],
                  ),
                ),
                SizedBox(height: 14,)
              ],
            ),
          ),
          LinearProgressIndicator(
            value: uploadProgress, // must be between 0.0 and 1.0
            minHeight: 4,
            backgroundColor: Colors.grey.shade200,
            color: Colors.orange,
            borderRadius: BorderRadius.circular(10),
          ),
          Container(
            width: w,
            height: 80,
            child: StepProgress(
              totalSteps: 4,
              padding: const EdgeInsets.all(10),
              controller: stepProgressController,
              lineSubTitles: const [
                'Info',
                'Upload',
                "Address",
              ],currentStep: i,
              theme: const StepProgressThemeData(
                stepLineSpacing: 28,
                stepLineStyle: StepLineStyle(
                  lineThickness: 10,
                  isBreadcrumb: true,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
              width: w,
              height: h-230-51,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: colum(w),
                ),
              )
          ),
        ],
      ),
      persistentFooterButtons: [
        progress?Center(child: CircularProgressIndicator()):i==0?InkWell(
            onTap: (){
              if(!isChecked){
                Send.message(context, "Please give Consent", false);
                return ;
              }
              next();
            },
            child: GW.button("Continue to Fill Application", w)):
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: previous,
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Global.bg,
                child: Icon(Icons.arrow_back,color: Colors.white,),
              ),
            ),
            InkWell(
                onTap:next,
                child: GW.button(i==4?"Complete Form & Submit":"Continue to Fill Application", w-80)),
          ],
        )
      ],
      backgroundColor: Colors.white,
    );
  }

  Widget colum(double w){
    if(i==0){
      return r1(w);
    }else if(i==1){
      return r2(w);
    }else if(i==2){
      return r3(w);
    }
    return r5(w);
  }
  TextEditingController phone=TextEditingController();
  TextEditingController fax=TextEditingController();
  TextEditingController email=TextEditingController();

  TextEditingController myname=TextEditingController();

  Future<MultipartFile> returnmul(XFile b) async {
    MultipartFile userPhoto = await MultipartFile.fromFile(
      b!.path,
      filename: b.name, // keeps the original filename
    );
    return userPhoto;
  }
  String? validateFields() {
    if (myname.text.isEmpty) return "Name is required";
    if (email1.text.isEmpty) return "Primary email is required";
    if (email2.text.isEmpty) return "Alternate email is required";
    if (father.text.isEmpty) return "Father's name is required";
    if (address.text.isEmpty) return "Home address is required";
    if (warehouse.text.isEmpty) return "Current address is required";
    if (gst.text.isEmpty) return "Aadhaar number is required";
    if (license.text.isEmpty) return "Driver license number is required";
    if (phone1.text.isEmpty) return "Alternate contact is required";
    if (gstfront == null) return "Please select Aadhaar front image";
    if (gstback == null) return "Please select Aadhaar back image";
    if (idcard == null) return "Please select license image";
    if (attorney == null) return "Please select profile photo";
    return null; // All fields are filled
  }

  Future<void> registerDriver() async {
    final Dio dio = Dio(
      BaseOptions(validateStatus: (status) => status != null && status < 700),
    );
    String? errorMessage = validateFields();
    if (errorMessage != null) {
      print(errorMessage);
      Send.message(context, errorMessage, false);
      return;
    }

    try {
      setState(() {
        progress=true;
      });
      MultipartFile adhhar1=await returnmul(gstfront!);
      MultipartFile adhhar2=await returnmul(gstback!);
      MultipartFile licenses=await returnmul(idcard!);
      MultipartFile photo1 =await returnmul(attorney!);
      final user = FirebaseAuth.instance.currentUser;
      DateTime now = DateTime.now();
      String currentDate =
          "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      FormData formData = FormData.fromMap({
        "provider": "mobile",
        "firebase_id": user!.uid,
        "fcm_token": "${user.uid}",
        "name": myname.text,
        "email": email1.text,
        "mobile": "${user.phoneNumber}",
        "platform_type": "android",
        "referral_number": "88",
        "role": "driver",
        "online": "1",
        "latitude": "0",
        "longitude": "0",
        "joined": currentDate,
        "last_online": currentDate,
        "rating": "5",
        "rides": "0",
        "alternate_email": "${email2.text}",
        "user_photo": photo1, //
        "alternate_contact": "${phone1.text}",
        "father_name": "${father.text}",
        "home_address": "${address.text}",
        "current_address": "${warehouse.text}",
        "adhaar_number": "${gst.text}",
        "adhaar_picture": adhhar1,//
        "adhaar_picture_back": adhhar2,//
        "driver_license": "${license.text}",
        "license_picture":licenses, //
        "experience": "$selectedValue",
      });

      Response response = await dio.post(
        Api.apiurl + "driver/register",
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
          },
        ),
      );

      print(response.statusMessage);
      print(response.statusCode);
      print(response.data);
      if (response.statusCode == 200||response.statusCode==201) {
        print("Driver registered successfully!");
        print(response.data);
        setfalse();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>np.MyHomePage(title: '',)));
        Send.message(context, "Success", true);
      } else {
        setfalse();
        Send.message(context, "Failed to register driver. Status code: ${response.statusCode}", false);
        print("Failed to register driver. Status code: ${response.statusCode}");
      }
    } catch (e) {
      setfalse();
      Send.message(context, "Failed to register driver. $e", false);
      print("Error registering driver: $e");
    }
  }
  void setfalse(){
    setState(() {
      progress=false;
    });
  }

  TextEditingController address=TextEditingController();
  TextEditingController officer = TextEditingController();
  TextEditingController warehouse = TextEditingController();
  TextEditingController mcaid=TextEditingController();
  TextEditingController headquaters = TextEditingController();

  TextEditingController license = TextEditingController();
  Widget r5(double w){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        t("Please Select your Experience in YEARS ?"),
        SizedBox(height: 5,),
        Center(
          child: Container(
            width: w - 20,
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade200,
              ),
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Select a Number"),
                  value: selectedValue,
                  items: List.generate(70, (index) => (index + 1).toString())
                      .map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedValue = newValue!;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10,),
        t("Permament Address"),
        t1("Please write your Full Permanent Address"),
        te(w, address,"Jhirpani, Rourkela, Odisha",desc:true),
        t("Current Address"),
        t1("Please Write your Full Current Address"),
        te(w, warehouse,"7978097489",desc: true),
      ],
    );
  }
  String selectedValue = "1";

  List<String> items=[
    "Micro","Small","Middle","Not Under MSME ( Large Company )"
  ];

  Widget r2(double w){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        t("Your Name"),
        t1("Please Type your Exact Name appearing in Adhaar Card & Driving License"),
        te(w, myname,"Ayusman Samasi"),
        t("Your Father Name"),
        t1("Please Type your Father Name appearing in Adhaar Card & Driving License"),
        te(w, father,"Ratan Samasi"),
        t("Your Email"),
        t1("Please write your Personal Email for Communication"),
        te(w, email1,"ayusmansamasi@gmail.com"),
        t("Your Alternate Email"),
        t1("Please write your Alternate Email incase"),
        te(w, email2,"ayusmansamasi@gmail.com"),
        t("Your Alternate Phone"),
        t1("Please write your Alternate Phone Number incase"),
        te(w, phone1,"7978097489",no: true),
    ]);
  }
  TextEditingController phone1=TextEditingController();

  TextEditingController email2=TextEditingController();
TextEditingController email1 = TextEditingController();
  TextEditingController father=TextEditingController();
  Widget r3(double w){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            !isSwitched?Icon(Icons.camera_alt):Icon(Icons.image_search_rounded),
            SizedBox(width: 5,),
            t("Use Camera to Click Pictures ?"),
            Switch(
              value: !isSwitched,
              activeColor: Colors.green,
              onChanged: (bool value) {
                setState(() {
                  isSwitched = !value; // Update the boolean
                });
              },
            ),
          ],
        ),
        t("Adhaar Number"),
        t1("Please Type Exact 12 Digit Adhaar Number"),
        te(w, gst,"619026495424",no: true),
        t("Upload Adhaar CARD pic"),
        t1("It must be official ID Card with Same Name of Driver"),
        Row(
          children: [
            InkWell(
              onTap: () async {
                gstfront=await pickImage(isSwitched?ImageSource.gallery:ImageSource.camera);
                setState(() {

                });
              },
              child: gstfront==null?im(w,i: 1):_buildImageContainer(gstfront,w),
            ),
            SizedBox(width: 10,),
            InkWell(
              onTap: () async {
                gstback=await pickImage(isSwitched?ImageSource.gallery:ImageSource.camera);
                setState(() {

                });
              },
              child: gstback==null?im(w,i: 2):_buildImageContainer(gstback,w),
            ),
          ],
        ),
        t("Driver License Number"),
        t1("Please Type Your Unique Driver License Number"),
        te(w, license,""),
        t("Upload Your Driver ID Card"),
        t1("Please Upload your Driver ID Card to verify your Vehicle Experience"),
        InkWell(
          onTap: () async {
            idcard=await pickImage(isSwitched?ImageSource.gallery:ImageSource.camera);
            setState(() {

            });
          },
          child: idcard==null?im(w):_buildImageContainer(idcard,w),
        ),
        t("Upload your Picture"),
        t1("Upload your 3:4 Passport Size Picture"),
        InkWell(
          onTap: () async {
            attorney =await pickImage(isSwitched?ImageSource.gallery:ImageSource.camera);
            setState(() {

            });
          },
          child: attorney==null?im(w,square: true):_buildImageContainer(attorney,w,square: true),
        ),
        SizedBox(height: 20,)
      ],
    );
  }

  Widget im(double w,{bool square = false,int i= 0})=>Padding(
    padding: const EdgeInsets.only(top: 6.0,bottom: 15),
    child: Container(
      width:square?(w/4): w/3,
      height: square?(w/3.5):(w/3)*9/16,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          i==2?Icon(Icons.flip_camera_ios):Icon(Icons.image),
          Text(i==0?"Click to Upload":"Upload ${i==1?"Front":"Back"} Picture",style: TextStyle(fontSize: 7),)
        ],
      ),
    ),
  );
  bool isSwitched = false;
  Widget _buildImageContainer(XFile? imageFile, double w, {bool square = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0, bottom: 15),
      child: Container(
        width: square ? w / 4 : w / 3,
        height: square ? w / 4 : (w / 3) * 9 / 16,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade400),
          image: imageFile == null
              ? null : DecorationImage(
            image: FileImage(File(imageFile.path)),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  TextEditingController name=TextEditingController();
  TextEditingController desc=TextEditingController();
  TextEditingController full_desc=TextEditingController();
  TextEditingController web1=TextEditingController();
  TextEditingController web2= TextEditingController();
  TextEditingController gst=TextEditingController();

  Widget te(double w,TextEditingController controller, String hint,{ bool no = false,bool desc=false})=>
      Padding(
        padding: const EdgeInsets.only(top: 5.0,bottom: 16),
        child: Container(
          width : w  , height : desc?140:50,
          decoration: BoxDecoration(
            color: Colors.grey.shade100, // Background color of the container
            borderRadius: BorderRadius.circular(5.0), // Rounded corners
          ),
          child: Padding(
              padding: desc?EdgeInsets.all(15): EdgeInsets.only( left :10, right : 18.0),
              child: Center(
                child: TextFormField(
                  keyboardType: no?TextInputType.number:TextInputType.name,
                  controller: controller,
                  minLines: desc?5:1,
                  maxLines: desc?100:1,
                  readOnly: progress,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle:TextStyle(color:Colors.grey.shade400),
                    isDense: true,
                    border: InputBorder.none, // No border
                  ),
                ),
              )
          ),
        ),
      );
  bool progress=false;

  double uploadProgress=0;

  Future<String> uploadpic(XFile file)async{
    try {
      final File imageFile = File(file.path);
      final String fileName = 'public/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      return "";
    }catch(e){
      return e.toString();
    }
  }


  Widget t(String str)=>Text(str
    ,style: TextStyle(fontWeight: FontWeight.w800,fontSize: 18),);
  Widget t1(String str)=> Text(str,style: TextStyle(fontWeight: FontWeight.w400,fontSize: 13),);

  List<String> categories=[];
  Widget r1(double w){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10,),
        Text("Let's Complete your Driver Application"
          ,style: TextStyle(fontWeight: FontWeight.w800,fontSize: 18),),
        Text("Creating a driver account is quick and easy. By signing up, you can start accepting ride requests, manage your schedule, and earn on your own terms. Simply provide your basic information, upload the required documents, and complete our verification process."
          ,style: TextStyle(fontWeight: FontWeight.w400,fontSize: 13),),
        SizedBox(height: 10,),
        Text("Documents to be Handy : "
          ,style: TextStyle(fontWeight: FontWeight.w800,fontSize: 18),),
        SizedBox(height: 5,),
        col(w, "assets/adhaar.png", "Adhaar Card", "We need official to Verify your Identity"),
        col(w, "assets/lic.jpg", "Driver License", "To Verify your Experience"),
        col(w, "assets/pic.jpg", "Personal Details", "Your Basic Details"),
        SizedBox(height: 20,),
        Text("You Verify that "
          ,style: TextStyle(fontWeight: FontWeight.w800,fontSize: 18),),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(
              value: isChecked,checkColor: Colors.white,
              activeColor: Global.bg,
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value!;
                });
              },
            ),
            Container(
                width: w-90,
                child: Text("I consent that I am a Experience Driver with minimum Experience of 1 Year and is Mentally and Physically Fit",
                  style: TextStyle(fontSize: 12),)),
          ],
        ),
        SizedBox(height: 5,),

      ],

    );
  }
  bool isChecked = false;

  int i = 0;
  next(){
    if(i==3){
      showDialog(
        context: context,
        barrierDismissible: false, // Prevents closing when tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Submit Form'),
            content: const Text('Are you sure you want to Submit ?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Perform action and close dialog
                  registerDriver();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return ;
    }
    setState(() {
      i++;
      stepProgressController.nextStep();
    });
  }
  previous(){
    if(i==0){
      return ;
    }
    setState(() {
      i--;
      stepProgressController.previousStep();
    });
  }

  Widget col(double w,String assetName, String name,String desc){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        width: w-20,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: CircleAvatar(
                  radius: w/11,
                  backgroundColor: Colors.grey.shade400,
                  child:
                  CircleAvatar(
                    radius: w/11-1,
                    backgroundColor: Colors.white,
                    child: Padding(padding: EdgeInsets.all(10),
                      child: Image.asset(assetName,fit: BoxFit.cover,),
                    ),
                  )
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                Text(desc)
              ],
            )
          ],
        ),
      ),
    );
  }
}
