import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/dete_override_controller.dart';

class DeteOverrideView extends GetView<DeteOverrideController> {
  const DeteOverrideView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DeteOverrideView'), centerTitle: true),
      body: const Center(
        child: Text(
          'DeteOverrideView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
