// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_collection_literals

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import './main_content.dart';

void main() async {
	await GetStorage.init();
	runApp(ShakeLight());
}

class ShakeLight extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            theme: ThemeData(
				primaryColor: Colors.purple[900]
            ),
            debugShowCheckedModeBanner: false,
            home: MainContent()
        );
    }
}