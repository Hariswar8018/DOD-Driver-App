



import 'package:url_launcher/url_launcher.dart';

class Contacts {
  static open(String url)async {
    final Uri _url = Uri.parse(url);
    if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
    }
  }
  static String phone = "9638935910";
  static String whatsapp= "9638935910";
  static String email = "info@driversondemand.in";
  static String web = "http://driversondemand.in/";
  static void launchwhatsapp(){
    String url = "https:wa.me/91$whatsapp";
    open(url);
  }
  static void launchphone(){
    String url = "tel:$phone";
    open(url);
  }
  static void launchemail(){
    String url = "mailto:$email";
    open(url);
  }
  static void launchweb(){
    String url = "https:$web";
    open(url);
  }
}