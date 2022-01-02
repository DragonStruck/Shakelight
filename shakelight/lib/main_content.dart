// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_collection_literals, prefer_const_literals_to_create_immutables, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'get_x_switch_state.dart';
import 'package:vibration/vibration.dart';
import 'package:shake/shake.dart';
import 'package:torch_light/torch_light.dart';

class MainContent extends StatefulWidget {
	@override
	HomeContent createState() => HomeContent();
}

class HomeContent extends State<MainContent> {
	final GetXSwitchState getXSwitchState = Get.put(GetXSwitchState());
	var switchStateBool = false;
	var firstSwitch = 0;
	var flashLightState = 0;
	late ShakeDetector detector;

	@override
	void initState() {
		super.initState();
		detector = ShakeDetector.waitForStart(onPhoneShake: () {
			if(flashLightState == 1) {
				flashLightState = 0;
				_vibrate();
				_disableFlashlight(context);
			} else if(flashLightState == 0) {
				flashLightState = 1;
				_vibrate();
				_enableFlashlight(context);
			}
		});
	}
  
	@override
	Widget build(BuildContext context) {
		if(getXSwitchState.switchdatacontroller.read('getXIsSwitched') != null) {
			switchStateBool = getXSwitchState.switchdatacontroller.read('getXIsSwitched');
		}

		return Scaffold(
			backgroundColor: Color(0xE0ffffff),
			appBar: AppBar(
				backgroundColor: Colors.purple[900],
				title: Text("Shakelight"),
				actions: <Widget>[
					IconButton(
						onPressed: _settingsMenu, 
						icon: Icon(Icons.settings)
					)
				],
			),
			body: _homeContent(),
		);
	}

	Widget _homeContent() {
		_checkSwitchState();

		return Center( 
			child: Column(
				mainAxisAlignment: MainAxisAlignment.start,
				children: [
					Container(
						margin: EdgeInsets.only(left:0, top:85,right:0,bottom:20.0),
						child: Text("Turn shaking on/off",
							style: TextStyle(
							fontSize: 26,
							fontWeight: FontWeight.bold
							)
						),
					),

					GetBuilder<GetXSwitchState>(
						builder: (_) => 
						Transform.scale(
							scale: 2.0,
							child: Switch (
								value: getXSwitchState.isSwitcheded,
								onChanged: (value){
									getXSwitchState.changeSwitchState(value);
									switchStateBool = getXSwitchState.switchdatacontroller.read('getXIsSwitched');
									if(firstSwitch == 0) {
										firstSwitch = 1;
									}
									_checkSwitchState();
								}
							)
						),
					),
				],
			)
		);
	}

	// Settings menu
	void _settingsMenu() {
		Navigator.of(context).push(
			MaterialPageRoute(
				builder: (BuildContext context) {
					return Scaffold(
						backgroundColor: Color(0xE0ffffff),
						appBar: AppBar(
							backgroundColor: Colors.purple[900],
							title: Text("Settings"),
						),
						// body: ListView(
						// 	children: settingsList,
						// ),
					);
				}
			)
		);
	}

	// Check if app functionality is on or off.
	void _checkSwitchState() {
		if(switchStateBool == true) {
			if(firstSwitch == 1) {
				_vibrate();
			}
			detector.startListening();
		} else if(switchStateBool == false && firstSwitch == 1) {
			_vibrate();
			detector.stopListening();
		}
	}

	// Vibrate the divice for 200ms.
	Future<void> _vibrate() async {
		if (await Vibration.hasVibrator() != null) {
			Vibration.vibrate(duration: 200);
		}
	}

	// Enable flashlight
	Future<void> _enableFlashlight(BuildContext context) async {
		try {
			await TorchLight.enableTorch();
		} on Exception catch (_) {}
	}

	// Disable flashlight
	Future<void> _disableFlashlight(BuildContext context) async {
		try {
			await TorchLight.disableTorch();
		} on Exception catch (_) {}
	}
}