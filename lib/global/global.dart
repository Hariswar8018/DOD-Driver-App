import 'package:flutter/material.dart';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_cloud_messaging_flutter/firebase_cloud_messaging_flutter.dart';
import 'package:flutter/material.dart';
class Global{

  static Color bg = Colors.black;
  static Color grey = Color(0xffF3F4F6);

 static List<String> places = [
    "Ahmedabad Junction Railway Station, Kalupur Railway Station Road, Sakar Bazzar, Kalupur, Ahmedabad, Gujarat 380002" ,  // main railway station :contentReference[oaicite:0]{index=0}
    "Divisional Railway Manager's Office, Amdupura, Naroda Road, Ahmedabad, Gujarat 382345" ,  // Western Railway administrative office :contentReference[oaicite:1]{index=1}
    "Gheekanta Metro Station, Old City, Gheekanta, Bhadra, Ahmedabad, Gujarat 380001" ,  // metro station on Blue Line :contentReference[oaicite:2]{index=2}
    "Amraiwadi Metro Station, Rabari Colony, Amraiwadi, Ahmedabad, Gujarat 380026" ,  // elevated metro station, Blue Line :contentReference[oaicite:3]{index=3}
    "Old High Court Metro Station, Shreyas Colony, Navrangpura, Ahmedabad, Gujarat 380009" ,  // interchange station between Blue & Red Lines :contentReference[oaicite:4]{index=4}
    "Sabarmati Ashram, Gandhi Smarak Sangrahalaya, Sabarmati, Ahmedabad, Gujarat 380005" ,  // historic ashram of Mahatma Gandhi :contentReference[oaicite:5]{index=5}
    "Kankaria Lake, Kankaria, Ahmedabad, Gujarat" ,  // large lake + amusement areas :contentReference[oaicite:6]{index=6}
    "Jama Masjid, Manek Chowk, Old Ahmedabad, Gujarat 380001" ,  // major mosque in walled city :contentReference[oaicite:7]{index=7}
    "Sidi Saiyyed Mosque, Shah Jali, Shahibaug, Ahmedabad, Gujarat" ,  // known for its stone lattice (jali) work :contentReference[oaicite:8]{index=8}
    "Swaminarayan Temple, Kalupur, Ahmedabad, Gujarat" ,  // Kalupur Swaminarayan Temple :contentReference[oaicite:9]{index=9}
    "Bhadra Fort, Bhadra, Ahmedabad, Gujarat" ,  // historic fort in old city :contentReference[oaicite:10]{index=10}
    "Teen Darwaza, Bhadra, Ahmedabad, Gujarat" ,  // historic gate in old city :contentReference[oaicite:11]{index=11}
    "Ashram Road, Ahmedabad, Gujarat" ,  // major road with multiple public offices (RBI, Income Tax etc.) :contentReference[oaicite:12]{index=12}
    "Reserve Bank of India, Ashram Road, Ahmedabad, Gujarat" ,  // office on Ashram Road :contentReference[oaicite:13]{index=13}
    "Income Tax Office Buildings, Ashram Road, Ahmedabad, Gujarat" ,  // on Ashram Road :contentReference[oaicite:14]{index=14}
    "Ahmedabad Collectorate, Ashram Road, Ahmedabad, Gujarat" ,  // collector’s office, Ashram Road :contentReference[oaicite:15]{index=15}
    "All India Radio, Ashram Road, Ahmedabad, Gujarat" ,  // radio office on Ashram Road :contentReference[oaicite:16]{index=16}
    "Law Garden Market, Near Sanskar Kendra, Ahmedabad, Gujarat" ,  // popular shopping / night market area :contentReference[oaicite:17]{index=17}
    "Hutheesing Jain Temple, Shahibaug, Ahmedabad, Gujarat" ,  // marble temple in Shahibaug area :contentReference[oaicite:18]{index=18}
    "Auto World Vintage Car Museum, Shahibaug, Ahmedabad, Gujarat" ,  // automobile museum :contentReference[oaicite:19]{index=19}
    "Calico Museum of Textiles, Relief Road, Ahmedabad, Gujarat" ,  // textile museum :contentReference[oaicite:20]{index=20}
    "Vastrapur Lake, Vastrapur, Ahmedabad, Gujarat" ,  // lake & public space :contentReference[oaicite:21]{index=21}
    "Sarkhej Roza, Santej-Sarkhej Road, Ahmedabad, Gujarat" ,  // historic monument on outskirts :contentReference[oaicite:22]{index=22}
    "Science City, Sola, Ahmedabad, Gujarat" ,  // science & exhibition centre in Sola area :contentReference[oaicite:23]{index=23}
    "Sayaji Baug (Kamati Baug), Near Sayajirao Garden Road, Vadodara, Gujarat 390001",  // large garden + museum + zoo :contentReference[oaicite:0]{index=0}
    "Lakshmi Vilas Palace, Champaner Road, Vadodara, Gujarat 390020",  // royal palace/museum :contentReference[oaicite:1]{index=1}
    "Kirti Mandir, Vishwamitri Bridge Road, Vadodara, Gujarat 390001",  // memorial temple :contentReference[oaicite:2]{index=2}
    "Sursagar Lake (Chand Talao), Old City, Vadodara, Gujarat 390001",  // central lake landmark :contentReference[oaicite:3]{index=3}
    "Chimnabai Clock Tower (Raopura Tower), Raopura, Vadodara, Gujarat 390001",  // heritage clock tower :contentReference[oaicite:4]{index=4}
    "Gujarat Government Narmada Bhavan, 3rd Floor, C-Block, Jail Road, Anandpura, Vadodara, Gujarat 390001",  // state govt office :contentReference[oaicite:5]{index=5}
    "Vadodara Municipal Corporation, 4-D, Bapod, Waghodia, Vadodara, Gujarat 390019",  // civic administration office :contentReference[oaicite:6]{index=6}
    "SDM Vadodara City, Kothi Building, Kothi Cross Road, Raopura, Mandvi, Vadodara, Gujarat 390001",  // Sub-Divisional Magistrate office :contentReference[oaicite:7]{index=7}
    "Collector Office, Jilla Seva Sadan, Kothi Building, Raopura, Vadodara, Gujarat 390001",  // District Collectorate :contentReference[oaicite:8]{index=8}
    "Vadodara Junction Railway Station, Alkapuri Road, Sayajigunj, Vadodara, Gujarat 390005",  // main railway station :contentReference[oaicite:9]{index=9}
    "General Post Office Vadodara, Kharivav Road, Near Surya Narayan Mandir, Raopura, Jambubet, Vadodara, Gujarat 390001",  // main post office :contentReference[oaicite:10]{index=10}
    "Fatehgunj Post Office, VIP Road, Fatehgunj, Vadodara, Gujarat 390002",  // post office in Fatehgunj area :contentReference[oaicite:11]{index=11}
    "Karelibaug Post Office, Mental Hospital Road, Vitthal Nagar, Vadodara, Gujarat 390018",  // post office in Karelibaug :contentReference[oaicite:12]{index=12}
    "Pratapgunj Post Office, PMG Office, Pratap Ganj, Vadodara, Gujarat 390002"  // post office in Pratapgunj area :contentReference[oaicite:13]{index=13}
    // Hospitals / Medical
        "Sterling Hospital Vadodara, Race Course Road, Opposite Inox Cinema, Circle West, Hari Nagar, Vadodara, Gujarat 390007",  // super speciality hospital :contentReference[oaicite:0]{index=0}
    "VINS Hospital, 99 Urmi Society, Opp Haveli, Off Productivity Road, Akota, Vadodara, Gujarat 390007",  // private hospital :contentReference[oaicite:1]{index=1}
    "Bankers Heart Institute, Old Padra Road, Opposite Suryakiran Complex, Old Padra Road, Vadodara, Gujarat 390015",  // cardiac hospital :contentReference[oaicite:2]{index=2}
    "Tricolour Hospitals, Dr. Vikram Sarabhai Road, Genda Circle, Vadiwadi, Vadodara, Gujarat 390007",  // hospital :contentReference[oaicite:3]{index=3}
    "Aashray Urology Institute, 80/A Sampatrao Colony, Lane Opposite Circuit House, Off R.C. Dutt Road, Vadodara, Gujarat 390007",  // urology speciality :contentReference[oaicite:4]{index=4}
    "Aayushya Multi Speciality Hospital, A-16 Mukhi Nagar Society, Near My Shannen School, Opp Darshanam Oasis, Khodiyar Nagar, New VIP Road, Vadodara, Gujarat 390019",  // multi-speciality :contentReference[oaicite:5]{index=5}
    "Abhishek Hospital, Shanti Park Society, Besides Jay Mahisagar Maa Mandir, Gorwa Road, Vadodara, Gujarat 390023",  // general hospital :contentReference[oaicite:6]{index=6}

    // Colleges / Universities
    "Maharaja Sayajirao University of Baroda, Pratapgunj, Vadodara, Gujarat 390002",  // major public university :contentReference[oaicite:7]{index=7}
    "The M.S. University of Baroda, Faculty of Fine Arts, Nyay Mandir, Kala Bhavan, Vadodara, Gujarat 390001",  // fine arts faculty :contentReference[oaicite:8]{index=8}
    "Baroda Medical College, J.N. Marg, Pratapgunj, Vadodara, Gujarat 390001",  // medical college :contentReference[oaicite:9]{index=9}
    "Parul University, P.O. Limda, Taluka Waghodia, Vadodara, Gujarat 391760",  // large private university campus :contentReference[oaicite:10]{index=10}
    "Navrachana University, Vasna Bhayli Road, Vadodara, Gujarat 391410",  // private university :contentReference[oaicite:11]{index=11}
    "Vadodara Institute Of Engineering, Kotambi, Halol Toll Road, Near Kotambi, Waghodia, Vadodara, Gujarat 391510",  // engineering college :contentReference[oaicite:12]{index=12}
    "Kala Bhavan Engineering College, Jawaharlal Nehru Marg, Babajipura, Vadodara, Gujarat 390001",  // engineering college within MSU :contentReference[oaicite:13]{index=13}
    "Sigma Institute of Engineering, Ajwa Nimeta Road, Bakrol, Vadodara, Gujarat 391510",  // engineering college :contentReference[oaicite:14]{index=14}

    // Malls / Shopping Centers
    "Mahima Resicom, Sharnam Road, Makarpura, Dhaniavi, Vadodara, Gujarat 390014",  // shopping mall in Dhaniavi area :contentReference[oaicite:15]{index=15}
    "Padmavati Shopping Center, Lehripura Gate, Kansara Pole, Bajwada, Mandvi, Vadodara, Gujarat 390001",  // shopping centre in Baranpura / Mandvi :contentReference[oaicite:16]{index=16}

    // Other Notable Places
    "Khanderao Market, Chamaraja Road, Vadodara, Gujarat",  // historic market & municipal offices at Chamaraja Road :contentReference[oaicite:17]{index=17}
    "Swarnim Gujarat Sports University, Opp. Taluka Seva Sadan, Desar, Vadodara, Gujarat 391774",  // sports university campus in Desar :contentReference[oaicite:18]{index=18}
    "Central University of Gujarat, Kundhela Village, Dabhoi Taluka, Vadodara District, Gujarat 391107",  // central University campus :contentReference[oaicite:19]{index=19}
    // Medical / Hospitals
    "SoLA Civil Hospital, Sarkhej-Gandhinagar Highway, Sola Road, Ahmedabad, Gujarat 380060",  // large public hospital :contentReference[oaicite:0]{index=0}
    "Government Mental Hospital, Shahibaug, Ahmedabad, Gujarat",  // govt mental health institution :contentReference[oaicite:1]{index=1}
    "Gujarat Cancer Research Institute, Shahibaug, Ahmedabad, Gujarat",  // cancer research & hospital centre :contentReference[oaicite:2]{index=2}
    "Smt. NHL Municipal Medical College, Ellisbridge, Paldi, Ahmedabad, Gujarat 380006",  // medical college & associated hospital :contentReference[oaicite:3]{index=3}

    // Colleges / Medical Education
    "B. J. Medical College, Asarwa, Ahmedabad, Gujarat 380016",  // one of principal medical colleges :contentReference[oaicite:4]{index=4}
    "AMC MET Medical College, LG Hospital Campus, Maninagar, Ahmedabad, Gujarat 380008",  // AMC's medical college :contentReference[oaicite:5]{index=5}
    "GCS Medical College, Opposite D. R. M. Office, Chamunda Bridge, Naroda Road, Ahmedabad-380025, Gujarat",  // medical college on Naroda Road :contentReference[oaicite:6]{index=6}

    // Metro / Transit
    "Jivraj Park Metro Station, Jivraj Park, Ahmedabad, Gujarat 380051",  // Red Line metro station :contentReference[oaicite:7]{index=7}
    "Usmanpura Metro Station, Sattar Taluka Society, Usmanpura, Ahmedabad, Gujarat 380014",  // metro station on Red Line :contentReference[oaicite:8]{index=8}
    "Vadaj Metro Station, Akhbar Nagar, Nava Vadaj, Ahmedabad, Gujarat 380081",  // elevated metro station :contentReference[oaicite:9]{index=9}

    // Malls / Shopping Centres
    "Phoenix Mall, Sarkhej-Gandhinagar Highway, Thaltej, Ahmedabad, Gujarat",  // large mall in Thaltej area :contentReference[oaicite:10]{index=10}
    "Palladium Ahmedabad, Sarkhej-Gandhinagar Highway, Thaltej, Ahmedabad, Gujarat",  // high-end shopping centre :contentReference[oaicite:11]{index=11}
    "Acropolis Mall, Thaltej Cross Road, Thaltej Road, Thaltej, Ahmedabad, Gujarat",  // near Thaltej cross roads :contentReference[oaicite:12]{index=12}
    "Himalaya Mall, Gurukul, Ahmedabad, Gujarat",  // mall in Gurukul area :contentReference[oaicite:13]{index=13}
    "Nexus Ahmedabad One, Vastrapur Road, Vastrapur, Ahmedabad, Gujarat",  // big mall in Vastrapur region :contentReference[oaicite:14]{index=14}
    "Iskcon Mall, Iskcon Cross Road, Satellite, Ahmedabad, Gujarat",  // shopping center in Satellite area :contentReference[oaicite:15]{index=15}
    "CG Square Mall, Navrangpura, Ahmedabad, Gujarat",  // mall on CG Road / Navrangpura area :contentReference[oaicite:16]{index=16}
    "Ishaan 3, Near Shell Petrol Pump, Prahladnagar, Ahmedabad, Gujarat",  // smaller shopping complex :contentReference[oaicite:17]{index=17}
  ];
}



class Send{
  static Color bg=Color(0xff8C1528);
  static Color color = Color(0xffF6BA24);

  static Widget se(double w,String s){
    return Container(
      width: w-30,
      height: 50,
      decoration: BoxDecoration(
          color:bg,
          borderRadius: BorderRadius.circular(5)
      ),
      child: Center(child: Text(s,style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w700),)),
    );
  }
  static Widget see(double w,String s,Widget icon){
    return Container(
      width: w-30,
      height: 50,
      decoration: BoxDecoration(
          color:bg,
          borderRadius: BorderRadius.circular(5)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,SizedBox(width: 7,),
          Text(s,style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w700),),
        ],
      ),
    );
  }
  static Widget editor(TextEditingController _controller,double w,String str, bool number){
    return  Center(
      child: Container(
        width: w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(left: 16,top: 8.0,bottom: 8,right: 16),
          child: TextField(
            minLines: 1,maxLines: 1,
            controller: _controller,
            keyboardType: number?TextInputType.number:TextInputType.name,
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w800
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: "",
              hintText: str,
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
  static Widget sees(double w,String s,Widget icon){
    return Container(
      width: w-30,
      height: 50,
      decoration: BoxDecoration(
          color:Colors.white,
          border: Border.all(
              color: Colors.blue
          ),
          borderRadius: BorderRadius.circular(5)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,SizedBox(width: 7,),
          Text(s,style: TextStyle(color: Colors.blue,fontSize: 18,fontWeight: FontWeight.w900),),
        ],
      ),
    );
  }
  static void message(BuildContext context,String str, bool green) async{
    await Flushbar(
      titleColor: Colors.white,
      message: "Lorem Ipsum is simply dummy text of the printing and typesetting industry",
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.linear,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: green?Colors.green:Colors.red,
      boxShadows: [BoxShadow(color: Colors.blue, offset: Offset(0.0, 2.0), blurRadius: 3.0)],
      backgroundGradient: green?LinearGradient(colors: [Colors.green, Colors.green.shade400]):LinearGradient(colors: [Colors.red, Colors.redAccent.shade400]),
      isDismissible: false,
      duration: Duration(seconds: 3),
      icon: green? Icon(
        Icons.verified,
        color: Colors.white,
      ): Icon(
        Icons.warning,
        color: Colors.white,
      ),
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.white,
      messageText: Text(
        str,
        style: TextStyle(fontSize: 16.0, color: Colors.white, fontFamily: "ShadowsIntoLightTwo"),
      ),
    ).show(context);
  }
  static void topic(BuildContext context,String str1,String str) async{
    await Flushbar(
      titleColor: Colors.white,
      message: "Lorem Ipsum is simply dummy text of the printing and typesetting industry",
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.linear,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: Colors.red,
      boxShadows: [BoxShadow(color: Colors.blue, offset: Offset(0.0, 2.0), blurRadius: 3.0)],
      backgroundGradient: LinearGradient(colors: [Colors.red, Colors.redAccent.shade400]),
      isDismissible: false,
      duration: Duration(seconds: 3),
      icon: Icon(
        Icons.warning,
        color: Colors.white,
      ),
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.white,
      titleText:  Text(
        str1,
        style: TextStyle(fontSize: 18.0, color: Colors.white,fontWeight: FontWeight.w700, fontFamily: "ShadowsIntoLightTwo"),
      ),
      messageText: Text(
        str,
        style: TextStyle(fontSize: 14.0, color: Colors.white, fontFamily: "ShadowsIntoLightTwo"),
      ),
    ).show(context);
  }

  static Future<void> sendNotificationsToTokens(String name, String mes,String tokens) async {
    var server = FirebaseCloudMessagingServer(
      serviceAccountFileContent,
    );
    var result = await server.send(
      FirebaseSend(
        validateOnly: false,
        message: FirebaseMessage(
          notification: FirebaseNotification(
            title: name,
            body: mes,
          ),
          android: FirebaseAndroidConfig(
            ttl: '3s', // Optional TTL for notification

            /// Add Delay in String. If you want to add 1 minute delay then add it like "60s"
            notification: FirebaseAndroidNotification(
              icon: 'ic_notification', // Optional icon
              color: '#009999', // Optional color
            ),
          ),
          token: tokens, // Send notification to specific user's token
        ),
      ),
    );
    print(result.toString());
  }
  static Future<void> sendNotification(String name, String mes,String tokens) async {
    var server = FirebaseCloudMessagingServer(
      serviceAccountFileContent,
    );
    var result = await server.send(
      FirebaseSend(
        validateOnly: false,
        message: FirebaseMessage(
          notification: FirebaseNotification(
            title: name,
            body: mes,
          ),
          android: FirebaseAndroidConfig(
            ttl: '3s', // Optional TTL for notification

            /// Add Delay in String. If you want to add 1 minute delay then add it like "60s"
            notification: FirebaseAndroidNotification(
              icon: 'ic_notification', // Optional icon
              color: '#009999', // Optional color
            ),
          ),
          token: tokens, // Send notification to specific user's token
        ),
      ),
    );
    print(result.toString());
  }

  static final serviceAccountFileContent = <String, String>{
    'type': "service_account",
    'project_id': "studio-next-light",
    'private_key_id':  "a0321d013e1c1d188573cfba2f00b4fef0d13895",
    'private_key':  "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCzQVsitKMz0wEf\n79j7iROR2W7qbinklL8oQnkypekTllavh/ds4yMfvsBMoThXXqeeTpp4Ugd74UA6\nLOXw180uNulYpeP/ql6c1o5CyOdBAEwgd8fYKu4iruur7f897gN5N+X/bgMjYk4q\nzNYlKpGd1QlK0/p9155/NoCYzPOTl7P8lSjPrR4xBDKvBOCxBAkxLFPiE0mXW5ed\ndRktIxXDLy9VnWjMzjNOrAsUQZrs18A3nFSPKAtlND0PlS3SjOEPQ9Jhp1AQEIS2\nQfgou1KpuIfIvzoGXDeUnNkDrWetIWps4pXVmUF48rRuxmOa74Isub9Y+kQFoQjn\nIHF+tExLAgMBAAECggEATSgXg0O/b8ImHMoPWo2xF7lAjbWnYJVKBpk+M7fIMD8o\nxts+e+b0qmhfu1w1tR2wBmsNADdGs2LMU34Z52XsEjVekWKuVdDOcrHDgCmbqJXp\nLpyAL6Ki59jk5hdGIzD828Ncw2pl/WgF/1Q15L+C+C3HlybRDjOuLFGYXqzxNxh+\njDMybwfQ06uNWOkpnk8VUbK0gQ5nK1TnSjDOZ4OkXZp7BW+Q/Lg4hSnmg6F38QRH\nTkC1WtjeS6xiRY60LQeoMBBqHEZILQ9zNX2JGiLJgv6aUoGA5W/a3/xUVWd+Ru2f\n8SpW8wwzkLzSgL1E/Fmw5A3C3zsBanwPAkIhqNDwOQKBgQDxZv1Xo19yQx0ag4zD\nj62F574l93MwnPcHDf9X8PVIr/nxEayPzOzJxghmVLwQMMRUy/+ns9zvh+61+PJK\neT/6OuFEHbX/zKE9mmrERJrGVOZ9kMnkRjbpgRq6VbkRbUZhGDgqMuzPx6o2i5A/\n4gm3F6AXTP0P9HFeM7bEeRVmxQKBgQC+GE3k/bWg3MGh1cui6U1CdMgxkR5LSv9T\ne+b4eO+4IvIU6Szbibh44qbJVY05Lmb2VA/cNJ4lFrz3P5MJSQVqPWfmPg7y4uyX\n9/W+geh8O+rUjB9gV35kgJSMaxKIYGZeL1r3fRLzefCIlP6/XS2oLozNXSF9Kaqj\npYbOyCiXzwKBgDBsMkFUGh83ay0YWjIYLfyAQdonysljkwGtQx0GzozoD8DVhMHL\nn2vR93lfYeH1hkxkJ0IiiBzcLXv/Fcrui3DMQseBFjLbfzR2NxhrkohaG2nwky7h\nDr7EEPJzo43lV4q+avW8BVigeno6gJLv6nb5nDlQTirXI657vRuoFizpAoGBAIDg\n2W62070L7ftah4Ubx1WW92Mjj/ZcEl73UdCDrYKZrqaer9rntDnA8HLvnZ925jd7\nJoWU5uMeV18JqxZQe2tb1mUzDc9+KgmeAu32BTi1JrCTj3Ix328j/ZJ1xUrQkJaq\nZHIGSiLoOTtgSJZVBe9QIAXbbij9ZsMsJglripnhAoGAOShUA0siVvt/WiNTODgE\np0alwgV5BrlsD1tYfyQ1hlNbFh7x67ZrBPg/mkNYr7q8/xWDfUdrTngn7xkzNBR8\nYG/RkRxqc+LeF0NSM2PYl84MTCLmJacaJPq/8tZf3tT6amg4nlBm9EGMppn39lDg\n6gbuKH9Dqzn0fCfoatszhV4=\n-----END PRIVATE KEY-----\n",
    'client_email': "firebase-adminsdk-3dfyt@studio-next-light.iam.gserviceaccount.com",
    'client_id':"109409309262803939071",
    'auth_uri':  "https://accounts.google.com/o/oauth2/auth",
    'token_uri':  "https://oauth2.googleapis.com/token",
    'auth_provider_x509_cert_url':  "https://www.googleapis.com/oauth2/v1/certs",
    'client_x509_cert_url': "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-3dfyt%40studio-next-light.iam.gserviceaccount.com",
  };
}
