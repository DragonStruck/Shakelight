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
				_disableTorch(context);
			} else if(flashLightState == 0) {
				flashLightState = 1;
				_vibrate();
				_enableTorch(context);
			}
		});
	}
  
	@override
	Widget build(BuildContext context) {
		if(getXSwitchState.switchdatacontroller.read('getXIsSwitched') != null) {
			switchStateBool = getXSwitchState.switchdatacontroller.read('getXIsSwitched');
		}

		return Scaffold(
			appBar: AppBar(
				backgroundColor: Colors.purple[900],
				title: Text("Shakelight"),
				actions: <Widget>[
					IconButton(
						onPressed: _optionsMenu, 
						icon: Icon(Icons.settings)
					)
				],
			),
			body: _homeContent(),
		);
	}

	Widget _homeContent() {
		// detector = ShakeDetector.waitForStart(
		// 	onPhoneShake: () {
		// 		if(flashLightState == 1) {
		// 			flashLightState = 0;
		// 			_vibrate();
		// 			_disableTorch(context);
		// 		} else if(flashLightState == 0) {
		// 			flashLightState = 1;
		// 			_vibrate();
		// 			_enableTorch(context);
		// 		}
				



		// 		// _switchFlashLight(flashLightState);
		// 		// print("shake");
		// 	}
		// );

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

					GetBuilder<GetXSwitchState>(builder: (_) => 
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

	void _optionsMenu() {
		Navigator.of(context).push(
			MaterialPageRoute(
				builder: (BuildContext context) {
					return Scaffold(
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
			// print("ON");
		} else if(switchStateBool == false && firstSwitch == 1) {
			_vibrate();
			detector.stopListening();
			// print("OFF");
		}
	}

	Future<void> _vibrate() async {
		if (await Vibration.hasVibrator() != null) {
			Vibration.vibrate(duration: 200);
		}
	}

	Future<bool> _checkFlashLight() async {
		try {
			return await TorchLight.isTorchAvailable();
		} on Exception catch (_) {
		// Handle error
			return false;
		}
	}

	// Future<void> _switchFlashLight(_onOff) async {
	// 	if(_checkFlashLight() == true) {
	// 		// print("available");

	// 		switch(_onOff) {
	// 			case 1:
	// 				try {
	// 					await TorchLight.enableTorch();
	// 					} on Exception catch (_) {
	// 					// Handle error
	// 				}
	// 			break;
	// 			case 0:
	// 				try {
	// 					await TorchLight.disableTorch();
	// 					} on Exception catch (_) {
	// 					// Handle error
	// 				}
	// 			break;
	// 		}

	// 	} else {
	// 		// print("not available");
	// 	}
	// }

	Future<void> _enableTorch(BuildContext context) async {
		try {
			await TorchLight.enableTorch();
		} on Exception catch (_) {

		}
	}

	Future<void> _disableTorch(BuildContext context) async {
		try {
			await TorchLight.disableTorch();
		} on Exception catch (_) {

		}
	}
}

