import 'package:dod_partner/login/bloc/login/view.dart';
import 'package:dod_partner/second_pages/wallet12.dart';
import 'package:dod_partner/second_pages/withdrawl.dart';
import 'package:flutter/material.dart';

class Walley extends StatefulWidget {
  const Walley({super.key});

  @override
  State<Walley> createState() => _WalleyState();
}

class _WalleyState extends State<Walley> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Color(0xff25252D),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        title: Text("My Wallets",style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        children: [
          SizedBox(height: 15,),
          MyCoins(),
          SizedBox(height: 15,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Text("See All Transactions",style: TextStyle(
                    fontWeight: FontWeight.w800
                ),),
                Spacer(),
                Text("More >    ",style: TextStyle(
                    fontWeight: FontWeight.w500,color: Colors.blue
                ),),
              ],
            ),
          )
        ],
      ),
      persistentFooterButtons: [
        InkWell(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=>Withdrawl()));
          },
          child: Container(
            width: MediaQuery.of(context).size.width-20,
            height: 50,
            color: Colors.black,
            child: Center(
              child: Text("Withdraw to Bank"
                ,style: TextStyle(fontWeight: FontWeight.w800,color: Colors.white,fontSize: 18),),
            ),
          ),
        )
      ],
    );
  }
}
