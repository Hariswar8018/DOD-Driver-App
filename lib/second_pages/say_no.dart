




import 'package:flutter/material.dart';

class Say_No extends StatelessWidget {
  String str; String description;
  Say_No({super.key,required this.str,required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Color(0xff25252D),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text(str,style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: Image.asset("assets/empty.png",width: MediaQuery.of(context).size.width/3,)),
          SizedBox(height: 8),
          Center(child: Text(description,style: TextStyle(fontSize: 19,fontWeight: FontWeight.w500),)),
        ],
      ),
    );
  }
}
