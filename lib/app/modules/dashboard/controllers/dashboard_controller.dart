import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speedlab_admin/app/modules/booking_list/views/booking_list_view.dart';
import 'package:speedlab_admin/app/modules/home/views/home_view.dart';
import 'package:speedlab_admin/app/modules/service_list/views/service_list_view.dart';

class DashboardController extends GetxController {
  final currentIndex = 0.obs;

  final List<Widget> pages = [HomeView(), ServiceListView(), BookingListView()];

  void changePage(int index) {
    currentIndex.value = index;
  }
}
