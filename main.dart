import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as Images;

import 'dart:math';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();

  Future<List<int>> encrypt() async {
    // load avatar image
    ByteData imageData = await rootBundle.load('dosyalar/denizf.jpg');
    List<int> bytes = Uint8List.view(imageData.buffer);
    var avatarImage = Images.decodeImage(bytes);

    var a = 'dd121e36961a04627eacff629765dd3528471ed745c1e32222db4a8a5f3421c4';
    List<int> xr = List<int>(); //xor listesi
    int xor = 0, pikseller = 0;
    for (int y = 0; y <= avatarImage.height; y++) {
      for (int x = 0; x <= avatarImage.width; x++) {
        pikseller =
            avatarImage.getPixelSafe(x, y); //sıra ile her piksel çekiliyor.
        xor = pikseller.hashCode ^ a.hashCode; //pikseller xor'lanıyor

        xr.add(xor); //xr listesine xor'lanmıs degerler atılıyor
      }
    }
    //FRAKTAL
    int mboyut = avatarImage.width;
    int nboyut = avatarImage.length;
    int say = 0;
    int ortanokta = (sqrt(nboyut * mboyut) - 1).toInt();
    int adimlimit = ortanokta * 2 + 1, Y, X;
    bool ortaknt = true;

    for (int Z = 0; Z < adimlimit; Z++) {
      int adimmod = Z % ortanokta;
      if (ortaknt) {
        if (Z % 2 == 0) {
          X = mboyut - 1;
          Y = Z;
          for (int i = 0; i < Z + 1; i++) {
            say++;
            avatarImage.setPixelSafe(X, Y,
                xr[i]); //xr listesindeki elemanları sırası ile renk byte'ı olarak setPixel yapıyor.
            X--;
            Y--;
          }
        } else {
          X = mboyut - 1 - Z;
          Y = 0;

          for (int i = 0; i < Z + 1; i++) {
            say++;
            avatarImage.setPixelSafe(X, Y, xr[i]);
            X++;
            Y++;
          }
        }
        if (Z == ortanokta) {
          ortaknt = false;
        }
      } else {
        if (adimmod % 2 == 0) {
          if (say == nboyut * mboyut - 1) {
            X = 0;
            Y = nboyut - 1;
            adimmod = ortanokta;
          } else {
            X = 0;
            Y = adimmod;
          }
          for (int i = 0; i < (ortanokta - adimmod + 1); i++) {
            avatarImage.setPixelSafe(X, Y, xr[i]);
            say++;
            X++;
            Y++;
          }
        } else {
          if (say == nboyut * mboyut - 1) {
            X = 0;
            Y = nboyut - 1;
            adimmod = ortanokta;
          } else {
            X = mboyut - adimmod;
            Y = nboyut - 1;
          }
          for (int i = 0; i < (ortanokta - adimmod + 1); i++) {
            avatarImage.setPixelSafe(X, Y, xr[i]);
            say++;
            X--;
            Y--;
          }
        }
      }
    }
    var avatarImage2 = Images.grayscale(avatarImage);

    return Images.encodeJpg(avatarImage);
  }

  //DECRYPT
  Future<List<int>> fdecrypt() async {
    ByteData imageData = await rootBundle.load('dosyalar/denizf.jpg');
    List<int> bytes = Uint8List.view(imageData.buffer);
    var decImage = Images.decodeImage(bytes);
    return Images.encodeJpg(decImage);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  List<int> myImage;

  void mencrypt() {
    widget.encrypt().then((List<int> image) {
      setState(() {
        myImage = image;
      });
    });
  }

  //Bu kısımdaki sorun şu; İlk başta encrypt tuşuna(+) bastığımzda şifreliyor
  //Ancak decrypt tuşuna basıp, resmi getirdikten sonra
  //tekrar encrypt(+) tuşuna basıldığında, şifrelenmemiş ana resim geliyor.
  //Bu sorunu çözebilir misin?
  Timer timer;
  // void _startTimer3() {
  //   //GEREKSİZSE SİLL
  //   const oneSec = const Duration(seconds: 1);
  //   int start = 10;
  //   widget.fdecrypt().then((List<int> image) {
  //     timer = new Timer.periodic(
  //        oneSec,
  //        (Timer timer) => setState(() {
  //               if (start < 1) {
  //                myImage = image;
  //              } else {
  //                start = start - 1;
  //              }
  //            }));
  //  });
  //}

  void decrypt() {
    widget.fdecrypt().then((List<int> image) {
      setState(() {
        myImage = image;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade100,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            myImage == null ? Text('fdassd') : Image.memory(myImage),

            // Text(
            //  'You have pushed the button this many times:',
            // ),
            //   Text(
            //    '$_counter',
            //   style: Theme.of(context).textTheme.display1,
            // ),
            RaisedButton(
              child: Text('Decrypt'),
              textColor: Colors.red,
              onPressed: decrypt, //_startTimer3
            ),
          ],
        ),
      )),
      floatingActionButton: FloatingActionButton(
        //Encrypt butonu
        onPressed: mencrypt,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
