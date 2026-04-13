import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/edit_service_controller.dart';

class EditServiceView extends GetView<EditServiceController> {
  const EditServiceView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EditServiceView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'EditServiceView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
