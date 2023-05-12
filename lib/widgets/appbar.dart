import 'package:flutter/material.dart';

AppBar appBar(BuildContext context) => AppBar(
      shadowColor: const Color.fromRGBO(255, 255, 255, 0.5),
      backgroundColor: Colors.white,
      title: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/icons/logo.png',
            height: 25,
          )),
      leadingWidth: 50,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back),
        color: const Color.fromRGBO(240, 120, 5, 1),
      ),
      elevation: 10,
    );
