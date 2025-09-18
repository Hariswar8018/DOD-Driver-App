import 'package:dod_partner/global/global.dart';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Global.bg,
      appBar: AppBar(
        backgroundColor: Global.bg,
        title: Text("Filling form for DOD Partner",style: TextStyle(color: Colors.white),),
      ),
      body: Row(
        children: [
          SidebarX(
            controller: SidebarXController(selectedIndex: i),
            theme: SidebarXTheme(
              decoration: BoxDecoration(
                color: Colors.black
              ),
              hoverColor: Colors.white,
              iconTheme: IconThemeData(
                color: Colors.white,
              ),selectedIconTheme: IconThemeData(
              color: Colors.blue
            ),
              textStyle: TextStyle(color: Colors.white),
              selectedTextStyle: const TextStyle(color: Colors.white),
            ),
            items: const [
              SidebarXItem(icon: Icons.person, label: 'Home'),
              SidebarXItem(icon: Icons.work, label: 'Search'),
              SidebarXItem(icon: Icons.location_on_sharp, label: 'Search'),
              SidebarXItem(icon: Icons.credit_card_outlined, label: 'Home'),
              SidebarXItem(icon: Icons.upload, label: 'Search'),
              SidebarXItem(icon: Icons.info, label: 'Home'),

            ],
          ),
          col(),

        ],
      ),    );
  }
  int i = 0;

  Widget col(){
    if(i==0){
      return Personal();
    }else if(i==1){
      return Work();
    }else if(i==2){
      return Location();
    }else if(i==3){
      return Adhaar();
    }else if(i==4){
      return Upload();
    }else {
      return Info();
    }
  }

  Widget Personal(){
    return Column(
      children: [
        Text("Upload Info",style: TextStyle(color: Colors.white),)
      ],
    );
  }
  Widget Work(){
    return Column(
      children: [
        Text("Upload Info")
      ],
    );
  }
  Widget Location(){
    return Column(
      children: [
        Text("Upload Info")
      ],
    );
  }
  Widget Adhaar(){
    return Column(
      children: [
        Text("Upload Info")
      ],
    );
  }
  Widget Upload(){
    return Column(
      children: [
        Text("Upload Info")
      ],
    );
  }
  Widget Info(){
    return Column(
      children: [
        Text("Upload Info")
      ],
    );
  }
}
