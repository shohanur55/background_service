import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

Future<void> initial_service() async {
  final service = FlutterBackgroundService();
  /*
  initializes it with an instance of the FlutterBackgroundService class.
  This suggests that the code is using a library or package named
  FlutterBackgroundService to handle background tasks in a Flutter application.
   */

  await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onBackground: oniosbackground,
        onForeground: onstart,
      ),
      androidConfiguration: AndroidConfiguration(
        isForegroundMode: true,
        onStart: onstart,
        autoStart: true,
      ));
}

@pragma('vm:entry-point')
Future<bool> oniosbackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}
//providing additional information to the Dart virtual machine
@pragma('vm:entry-point')

void onstart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setforeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setbackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopservice').listen((event) {
    service.stopSelf();
  });
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
            title: "notication title", content: "notification content");
      }
    }
    print("background service is running");
    service.invoke('update');
  });
}
