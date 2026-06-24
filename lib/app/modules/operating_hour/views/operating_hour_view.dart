import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/modules/dete_override/controllers/dete_override_controller.dart';
import 'package:speedlab_admin/app/utils/theme/color_theme.dart';

import '../controllers/operating_hour_controller.dart';

class OperatingHourView extends GetView<OperatingHourController> {
  const OperatingHourView({super.key});

  @override
  Widget build(BuildContext context) {
    final deteOverrideController = Get.put<DeteOverrideController>(
      DeteOverrideController(provider: Get.find<BookingsProvider>()),
    );
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'Manajemen Operasional',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          // backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            indicatorColor: ColorTheme.neonYellow,
            indicatorWeight: 3,
            labelColor: ColorTheme.neonYellow,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: "Jadwal Rutin"),
              Tab(text: "Pengecualian Tanggal"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- TAB 1: JADWAL RUTIN ---
            _buildJadwalRutinTab(context, controller),

            // --- TAB 2: PENGECUALIAN TANGGAL ---
            _buildExceptionTab(context, deteOverrideController),
          ],
        ),
      ),
    );
  }

  // ======================================================================
  // 🛠️ TAB 1: JADWAL RUTIN (Menggunakan Column + Expanded, Tanpa Scaffold)
  // ======================================================================
  Widget _buildJadwalRutinTab(
    BuildContext context,
    OperatingHourController controller,
  ) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.operatingHours.length,
              itemBuilder: (context, dayIndex) {
                final day = controller.operatingHours[dayIndex];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              day.dayName.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: day.isOpen ? Colors.black : Colors.grey,
                              ),
                            ),
                            Switch(
                              value: day.isOpen,
                              activeThumbColor: ColorTheme.neonYellow,
                              onChanged:
                                  (value) => controller.toggleDayStatus(
                                    dayIndex,
                                    value,
                                  ),
                            ),
                          ],
                        ),
                        if (day.isOpen) ...[
                          const Divider(),
                          ...List.generate(day.timeSlots.length, (slotIndex) {
                            final slot = day.timeSlots[slotIndex];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap:
                                          () => controller.pickTime(
                                            context,
                                            dayIndex,
                                            slotIndex,
                                            true,
                                          ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          slot.openTime,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    child: Text(
                                      "-",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap:
                                          () => controller.pickTime(
                                            context,
                                            dayIndex,
                                            slotIndex,
                                            false,
                                          ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          slot.closeTime,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed:
                                        () => controller.removeTimeSlot(
                                          dayIndex,
                                          slotIndex,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          TextButton.icon(
                            onPressed: () => controller.addTimeSlot(dayIndex),
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(
                              "Tambah Sesi Waktu",
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        ] else ...[
                          Text(
                            "Bengkel Libur Reguler",
                            style: GoogleFonts.poppins(
                              color: Colors.redAccent,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),

        // Tombol aksi statis di bagian bawah kolom
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: Obx(
            () => ElevatedButton(
              onPressed:
                  controller.isSaving.value
                      ? null
                      : () => controller.saveSchedule(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: ColorTheme.neonYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  controller.isSaving.value
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        "Simpan Jadwal Rutin",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
            ),
          ),
        ),
      ],
    );
  }

  // ======================================================================
  // 🛠️ TAB 2: PENGECUALIAN TANGGAL (Menggunakan Column + Expanded, Tanpa Scaffold)
  // ======================================================================
  Widget _buildExceptionTab(
    BuildContext context,
    DeteOverrideController controller,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_month,
                        color: Colors.blueAccent,
                      ),
                    ),
                    title: Text(
                      "Pilih Tanggal Kalender",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    subtitle: Obx(
                      () => Text(
                        controller.formattedDateText,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.edit_calendar,
                      color: Colors.grey,
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            controller.selectedDate.value ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) controller.onDateSelected(picked);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.selectedDate.value == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text(
                          "Silakan pilih tanggal untuk melihat atau\nmengubah pengaturan operasional khusus.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.grey[500]),
                        ),
                      ),
                    );
                  }

                  if (controller.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.isOpen.value
                                    ? "Status: BUKA"
                                    : "Status: LIBUR",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      controller.isOpen.value
                                          ? Colors.black
                                          : Colors.redAccent,
                                ),
                              ),
                              Switch(
                                value: controller.isOpen.value,
                                activeThumbColor: ColorTheme.neonYellow,
                                onChanged:
                                    (val) => controller.isOpen.value = val,
                              ),
                            ],
                          ),
                          const Divider(height: 30),
                          Text(
                            "Catatan / Alasan Pengecualian:",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: controller.noteCtrl,
                            decoration: InputDecoration(
                              hintText: "Contoh: Libur Nasional, Tutup Awal...",
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (controller.isOpen.value) ...[
                            Text(
                              "Sesi Waktu Operasional Khusus:",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.timeSlots.length,
                              itemBuilder: (context, index) {
                                final slot = controller.timeSlots[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap:
                                              () => controller.pickTime(
                                                context,
                                                index,
                                                true,
                                              ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.blueAccent
                                                    .withOpacity(0.3),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.blueAccent
                                                  .withOpacity(0.05),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              slot.openTime,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Text(
                                          "-",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap:
                                              () => controller.pickTime(
                                                context,
                                                index,
                                                false,
                                              ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.blueAccent
                                                    .withOpacity(0.3),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.blueAccent
                                                  .withOpacity(0.05),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              slot.closeTime,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed:
                                            () => controller.removeTimeSlot(
                                              index,
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            TextButton.icon(
                              onPressed: controller.addTimeSlot,
                              icon: const Icon(Icons.add_circle, size: 18),
                              label: Text(
                                "Tambah Sesi Waktu",
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Tombol aksi khusus Pengecualian Tanggal di bagian paling bawah
        Obx(() {
          if (controller.selectedDate.value == null)
            return const SizedBox.shrink();
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: ElevatedButton(
              onPressed:
                  controller.isSaving.value
                      ? null
                      : () => controller.saveSettings(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: ColorTheme.neonYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  controller.isSaving.value
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        "Terapkan Perubahan Tanggal",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
            ),
          );
        }),
      ],
    );
  }
}
