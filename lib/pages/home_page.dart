import 'package:airadio/utils/ai_util.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer : Drawer(),
      body: Stack(children: [
        VxAnimatedBox().size(context.screenWidth, context.screenHeight)
        .withGradient(LinearGradient(colors: [
AiColors.primaryColor1,
AiColors.primaryColor2,
        ],
        begin: Alignment.topLeft ,
        
         end: Alignment.bottomRight,
         ),
        
        )
        .make(),
        AppBar(
          title: "YOUR AI RADIO ".text.xl4.bold.white.make(),
          backgroundColor: Colors.transparent,
          elevation: 0.0,

        ).h(100.0).p16()
      ],
      ),
    );
  }
}