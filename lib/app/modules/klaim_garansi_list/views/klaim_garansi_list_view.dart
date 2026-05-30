import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_admin/app/data/models/warranty_model.dart';
import 'package:speedlab_admin/app/utils/theme/color_theme.dart';

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

          // actions: [
          //   Row(
          //     children: [
          //       IconButton(
          //         onPressed: () => controller.fetchKlaimGaransi(),
          //         icon: const Icon(Icons.refresh, color: Colors.white),
          //         tooltip: 'Refresh',
          //       ),
          //       IconButton(
          //         onPressed: () => controller.pickFilterDate(),
          //         icon: const Icon(Icons.filter_list, color: Colors.white),
          //         tooltip: 'Filter',
          //       ),
          //     ],
          //   ),
          // ],
        ),
        body: Column(
          children: [
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
                  Tab(text: 'Terverifikasi'),
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
                    'Terverifikasi',
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
