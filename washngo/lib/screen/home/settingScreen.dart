import 'package:flutter/material.dart';
import 'package:washngo/layouts/bgHomeScreen.dart';
import 'package:washngo/screen/home/settingScreenContent.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Bghomescreen(
      showFooter: false, 
      child: const SettingScreenContent(),
    );
  }
}