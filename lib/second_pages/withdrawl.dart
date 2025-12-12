import 'package:dio/dio.dart';
import 'package:dod_partner/global/global.dart';
import 'package:dod_partner/second_pages/wallet12.dart';
import 'package:flutter/material.dart';

import '../api.dart';
import '../login/bloc/login/view.dart' show UserModel;
import '../login/locationpermission.dart';

class Withdrawl extends StatelessWidget {
   Withdrawl({super.key});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text("Withdrawal Now",style: TextStyle(color: Colors.grey.shade200),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 15,),
          MyCoins(),
          SizedBox(height: 15,),
          Center(
            child: RichText(text: TextSpan(
                text: "Withdrawal your",
                style: TextStyle(fontWeight: FontWeight.w800,fontSize: 23,color: Colors.black),
                children: [
                  TextSpan(
                    text: " Amount",
                    style: TextStyle(fontWeight: FontWeight.w800,fontSize: 23,color: Colors.blue),),
                ]),

            ),
          ),
          SizedBox(height: 10,),
          Container(
            width: w-40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.left,
              maxLength: 10,
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w800
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: "",
                prefixText: "    ₹     ",
                prefixStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w800
                ),
                hintText: "Enter the Amount",
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              onChanged: (value) {
                if (value.length > 10) {
                  _controller.text = value.substring(0, 10);
                  _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length));
                }
              },
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(

              textAlign: TextAlign.center,"By continuing use to our App, you agree to by Driver Terms & Condition and Payment Receive Process as defined in our Docs",
              style: TextStyle(color: Colors.black),),
          ),
        ],
      ),
      persistentFooterButtons: [
        InkWell(
          onTap: () async {
            double amount = double.parse(_controller.text);final Dio dio = Dio(
              BaseOptions(
                validateStatus: (status) => status != null && status < 500,
              ),
            );

            try {
              final response = await dio.post(
                "${Api.apiurl}driver/withdraw",
                options: Options(
                  headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer ${UserModel.token}", // REQUIRED
                  },
                ),
                data: {
                  "amount": amount,
                },
              );

              print("Withdraw Status: ${response.statusCode}");
              print("Withdraw Response: ${response.data}");
              if(response.statusCode==201||response.statusCode==200){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LocationPermission()));
                Send.message(context, "Withdraw Successful! ", true);

              }else{
                Send.message(context, "${response.statusMessage}",false);

              }
            } catch (e) {
              print("Withdraw Error: $e");
              Send.message(context, "$e",false);
            }
          },
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width-20,
              height: 50,
              color: Colors.black,
              child: Center(
                child: Text("Withdrawl Now"
                  ,style: TextStyle(fontWeight: FontWeight.w800,color: Colors.white,fontSize: 18),),
              ),
            ),
          ),
        ),
      ],
    );
  }
  TextEditingController _controller = TextEditingController();
  bool on = false;



}
