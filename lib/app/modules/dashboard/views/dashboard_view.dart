import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:speedlab_admin/app/utils/theme/color_theme.dart';

import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: controller.pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => SalomonBottomBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          curve: Curves.easeInOut,
          backgroundColor: Colors.black,
          selectedItemColor: ColorTheme.neonYellow,
          unselectedItemColor: Colors.white,
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home),
              title: Text("Home", style: GoogleFonts.poppins(fontSize: 12)),
              // selectedColor: Colors.blue,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.build),
              title: Text(
                "Daftar Servis",
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              // selectedColor: Colors.blue,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.settings),
              title: Text(
                "Daftar Booking",
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              // selectedColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
