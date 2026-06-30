import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_admin/app/data/models/warranty_model.dart';
import 'package:speedlab_admin/app/utils/theme/color_theme.dart';
import 'package:speedlab_admin/app/utils/widget/custom_modal.dart';

import '../controllers/klaim_garansi_list_controller.dart';

class KlaimGaransiListView extends GetView<KlaimGaransiListController> {
  const KlaimGaransiListView({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black, // Koridor identitas hitam
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Klaim Garansi',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),

          actions: [
            Row(
              children: [
                IconButton(
                  onPressed: () => controller.fetchWarranties(),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Refresh',
                ),
                Obx(
                  () => IconButton(
                    onPressed: _showFilterBottomSheet,
                    icon: Icon(
                      Icons.filter_list,
                      color:
                          controller.hasActiveFilters
                              ? ColorTheme.neonYellow
                              : Colors.white,
                    ),
                    tooltip: 'Filter',
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Obx(
              () =>
                  controller.hasActiveFilters
                      ? Container(
                        width: double.infinity,
                        color: Colors.black,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (controller.searchQuery.value.trim().isNotEmpty)
                              _buildActiveFilterChip(
                                'Cari: ${controller.searchQuery.value.trim()}',
                                onRemoved: controller.clearSearch,
                              ),
                            if (controller.selectedFilterData.value != null)
                              _buildActiveFilterChip(
                                'Tanggal: ${controller.formatDate(controller.selectedFilterData.value)}',
                                onRemoved: controller.clearDateFilter,
                              ),
                          ],
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
            Container(
              color: Colors.black,
              child: TabBar(
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                indicatorColor: ColorTheme.neonYellow,
                indicatorWeight: 4,
                labelColor: ColorTheme.neonYellow,
                unselectedLabelColor: Colors.grey[400],
                labelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'Menunggu Verifikasi'),
                  Tab(text: 'Diterima'),
                  Tab(text: 'Ditolak'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Placeholder widgets for each tab
                  _buildTabContent(
                    'Menunggu Verifikasi',
                    Icons.hourglass_empty,
                    Colors.blue,
                  ),
                  _buildTabContent(
                    'Diterima',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildTabContent('Ditolak', Icons.cancel, Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    final searchController = TextEditingController(
      text: controller.searchQuery.value,
    );

    CustomModal.showBottomSheet(
      title: 'Filter Klaim Garansi',
      height: Get.height * 0.65,
      padding: const EdgeInsets.all(20),
      content: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cari klaim berdasarkan ID, nama, plat, keluhan, atau catatan',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: searchController,
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Cari klaim...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Tanggal klaim',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: controller.pickFilterDate,
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: Text(
                controller.selectedFilterData.value == null
                    ? 'Semua tanggal'
                    : controller.formatDate(controller.selectedFilterData.value),
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  searchController.clear();
                  controller.clearSearch();
                  controller.clearDateFilter();
                  Get.back();
                },
                icon: const Icon(Icons.restart_alt_rounded),
                label: Text(
                  'Reset',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, {VoidCallback? onRemoved}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: ColorTheme.neonYellow.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ColorTheme.neonYellow.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tune_rounded, size: 14, color: ColorTheme.neonYellow),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ColorTheme.neonYellow,
            ),
          ),
          if (onRemoved != null) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onRemoved,
              borderRadius: BorderRadius.circular(999),
              child: const Icon(Icons.close_rounded, size: 14, color: ColorTheme.neonYellow),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabContent(String status, IconData icon, Color color) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: ColorTheme.neonYellow),
        );
      }

      // Use controller method for filtering
      List<WarrantyModel> filteredWarrantyStatus = controller
          .getWarrantiesByStatus(status);

      // if (controller.selectedFilterData.value != null) {
      //   final filterDate = controller.selectedFilterData.value!;

      //   filteredWarrantyStatus =
      //       filteredWarrantyStatus.where((warranty) {
      //         DateTime? wDate = warranty.warrantyDate;
      //         if (wDate == null) return false;
      //         return wDate.year == filterDate.year &&
      //             wDate.month == filterDate.month &&
      //             wDate.day == filterDate.day;
      //       }).toList();
      // }

      if (filteredWarrantyStatus.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 56, color: Colors.black38),
              ),
              const SizedBox(height: 24),
              Text(
                'Belum Ada Klaim Garansi!', // Disesuaikan untuk konteks admin
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tidak ada klaim garansi dengan status\n"$status"',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchWarranties(),
        color: Colors.black,
        backgroundColor: ColorTheme.neonYellow,
        child: ListView.separated(
          padding: const EdgeInsets.only(
            top: 16,
            left: 24,
            right: 24,
            bottom: 40,
          ),
          itemCount: filteredWarrantyStatus.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final warranty = filteredWarrantyStatus[index];
            return _buildWarrantyCard(warranty, status, icon, color);
          },
        ),
      );
    });
  }
}

Widget _buildWarrantyCard(
  WarrantyModel warranty,
  String status,
  IconData icon,
  Color color,
) {
  // Use controller methods for data parsing
  // final motorcycleInfo = controller.getMotorcycleInfo(booking);
  // final servicesInfo = controller.getServicesInfo(booking);
  // final dateTimeInfo = controller.formatDateTime(booking);
  final controller = Get.find<KlaimGaransiListController>();
  return Container(
    margin: const EdgeInsets.only(bottom: 16), // Jarak antar card
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24), // Lengkungan lebih modern
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03), // Shadow lebih halus
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
      ],
      border: Border.all(color: const Color(0xFFF0F0F0), width: 1.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. HEADER (ID & Status)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Garansi ID',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    // controller.formatBookingId(booking.id),
                    "${warranty.id ?? 'N/A'}",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Status Badge (Lebih menyerupai pil/kapsul)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20), // Bentuk pil
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 2. BODY (Informasi Detail di dalam Inner Container)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(
              0xFFF8F9FA,
            ), // Latar belakang abu-abu sangat muda
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (warranty.motorcycleId != null &&
                  warranty.motorcycleId!.isNotEmpty) ...[
                _buildInfoRow(
                  Icons.two_wheeler_rounded,
                  warranty.motorcycleId!['model'] ?? 'N/A',
                ),
                const SizedBox(height: 12),
              ],

              if (warranty.claimDate != null) ...[
                _buildInfoRow(
                  Icons.miscellaneous_services_rounded,
                  warranty.claimDate!.toIso8601String(),
                ),
                const SizedBox(height: 12),
              ],

              if (warranty.userId != null && warranty.userId!.isNotEmpty) ...[
                _buildInfoRow(Icons.person, warranty.userId!['name'] ?? 'N/A'),
                const SizedBox(height: 12),
              ],

              if (warranty.complaint != null && warranty.complaint!.isNotEmpty)
                _buildInfoRow(
                  Icons.format_quote_rounded,
                  warranty.complaint!,
                  isExpandable: true,
                ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 3. FOOTER (Total Harga & Action Buttons)
        // if (booking.totalPrice != null) ...[
        //   Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Text(
        //         'Total Biaya',
        //         style: GoogleFonts.poppins(
        //           fontSize: 13,
        //           color: Colors.grey[600],
        //           fontWeight: FontWeight.w500,
        //         ),
        //       ),
        //       Text(
        //         controller.formatPrice(booking.totalPrice!.toInt()),
        //         style: GoogleFonts.poppins(
        //           fontSize: 16,
        //           fontWeight: FontWeight.w700,
        //           color: Colors.black87,
        //         ),
        //       ),
        //     ],
        //   ),
        //   const Padding(
        //     padding: EdgeInsets.symmetric(vertical: 16),
        //     child: Divider(height: 1, color: Color(0xFFF0F0F0), thickness: 1.5),
        //   ),
        // ] else ...[
        //   // Jika tidak ada harga, tetap beri jarak untuk tombol
        //   const SizedBox(height: 4),
        // ],

        // Tombol Aksi
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => controller.verifyWarranty(warranty.id!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      14,
                    ), // Lengkungan disesuaikan
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Verifikasi',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            if (status != 'Dibatalkan') ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      () => controller.showRejectReasonDialog(warranty.id!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTheme.neonYellow,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Tolak',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}

Widget _buildInfoRow(IconData icon, String text, {bool isExpandable = false}) {
  return Row(
    crossAxisAlignment:
        isExpandable ? CrossAxisAlignment.start : CrossAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.black87, size: 16),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Padding(
          padding:
              isExpandable ? const EdgeInsets.only(top: 4.0) : EdgeInsets.zero,
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ),
    ],
  );
}
