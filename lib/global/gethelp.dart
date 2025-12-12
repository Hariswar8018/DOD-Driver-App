
import 'package:flutter/material.dart';

import 'contacts.dart';

class GetHelp extends StatelessWidget {
  const GetHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        centerTitle: true,
        title: Text("Help & Support",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),
      ),
      body: Column(
        children: [
          list(0, "Call Customer Care","Help quires your doubt regarding your Order "),
          list(1, "Mail Customer Care","Help quires your doubt regarding your Order "),
          list(2, "Whatsapp ","You could ask anything in Chat"),
        ],
      ),
    );
  }
  Widget list(int i,String str, String str2, )=>ListTile(
    onTap: (){
      if(i==0){
        Contacts.launchphone();
      }else if(i==1){
        Contacts.launchemail();
      }else if(i==2){
        Contacts.launchwhatsapp();
      }else{
        Contacts.launchweb();
      }
    },
    leading: geticon(i),
    tileColor: i%2==0?Colors.white:Colors.grey.shade50,
    title: Text(str,style: TextStyle(fontWeight: FontWeight.w800),),
    subtitle: Text(str2,style: TextStyle(fontWeight: FontWeight.w300,),),
  );

  Icon geticon(int i){
    if(i==0){
      return Icon(Icons.support_agent,color: Colors.blue,);
    }else if(i==1){
      return Icon(Icons.mail,color: Colors.orange,);
    }else if(i==2){
      return Icon(Icons.chat,color: Colors.green,);
    }else if(i==3){
      return Icon(Icons.location_on_sharp,color: Colors.red,);
    }
    return Icon(Icons.support);

  }
}
