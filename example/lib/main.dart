import 'package:flutter/material.dart';

import 'package:whatsapp_stickers/whatsapp_stickers.dart';
import 'package:whatsapp_stickers/exceptions.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WhatsApp Stickers'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            var stickerPack = WhatsappStickers(
                "cuppyFlutterWhatsAppStickers",
                "Cuppy Flutter WhatsApp Stickers",
                "John Doe",
                "assets/tray_Cuppy.png",
                "",
                "",
                "");

            stickerPack
              ..addSticker("assets/01_Cuppy_smile.webp", ["☕","🙂"])
              ..addSticker("assets/02_Cuppy_lol.webp", ["😄","😀"])
              ..addSticker("assets/03_Cuppy_rofl.webp", ["😆","😂"])
              ..addSticker("assets/04_Cuppy_sad.webp", ["😃", "😍"])
              ..addSticker("assets/05_Cuppy_cry.webp", ["😭","💧"])
              ..addSticker("assets/06_Cuppy_love.webp", ["😍","♥"])
              ..addSticker("assets/07_Cuppy_hate.webp", ["💔","👎"])
              ..addSticker("assets/08_Cuppy_lovewithmug.webp", ["😍","💑"])
              ..addSticker("assets/09_Cuppy_lovewithcookie.webp", ["😘","🍪"])
              ..addSticker("assets/10_Cuppy_hmm.webp", ["🤔","😐"])
              ..addSticker("assets/11_Cuppy_upset.webp", ["😱","😵"])
              ..addSticker("assets/12_Cuppy_angry.webp", ["😡","😠"])
              ..addSticker("assets/13_Cuppy_curious.webp", ["❓","🤔"])
              ..addSticker("assets/14_Cuppy_weird.webp", ["🌈","😜"])
              ..addSticker("assets/15_Cuppy_bluescreen.webp", ["💻","😩"])
              ..addSticker("assets/16_Cuppy_angry.webp", ["😡","😤"])
              ..addSticker("assets/17_Cuppy_tired.webp", ["😩","😨"])
              ..addSticker("assets/18_Cuppy_workhard.webp", ["😔", "😨"])
              ..addSticker("assets/19_Cuppy_shine.webp", ["🎉","✨"])
              ..addSticker("assets/20_Cuppy_disgusting.webp", ["🤮","👎"])
              ..addSticker("assets/21_Cuppy_hi.webp", ["🖐","🙋"])
              ..addSticker("assets/22_Cuppy_bye.webp", ["🖐","👋"]);

            try {
              await stickerPack.sendToWhatsApp();
            } on WhatsappStickersException catch (e) {
              print(e.cause);
            }
          },
        ),
      ),
    );
  }
}
