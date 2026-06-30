import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_admin/app/data/models/bookings_model.dart';
import 'package:speedlab_admin/app/utils/theme/color_theme.dart';
import 'package:speedlab_admin/app/utils/widget/custom_modal.dart';

import '../controllers/booking_list_controller.dart';

class BookingListView extends GetView<BookingListController> {
  const BookingListView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(
          0xFFF4F6F9,
        ), // Koridor putih/abu-abu bersih
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black, // Koridor identitas hitam
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Riwayat Booking',
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
                  onPressed: () => controller.fetchBookings(),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Refresh',
                ),
                Obx(
                  () => IconButton(
                    onPressed: _showFilterBottomSheet,
                    icon: Icon(
                      Icons.filter_list,
                      color:
                          controller.searchQuery.value.trim().isNotEmpty ||
                                  controller.selectedFilterData.value != null
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
                  (controller.searchQuery.value.trim().isNotEmpty ||
                          controller.selectedFilterData.value != null)
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
              color: Colors.black, // Tab panel konsisten hitam
              child: TabBar(
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                indicatorColor: ColorTheme.neonYellow, // Identitas Neon Yellow
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
                  Tab(text: 'Sedang Dikerjakan'),
                  Tab(text: 'Selesai'),
                  Tab(text: 'Dibatalkan'),
                ],
              ),
            ),
            // Add refresh button
            Expanded(
              child: TabBarView(
                children: [
                  _buildTabContent(
                    'Menunggu Verifikasi',
                    Icons.hourglass_empty_rounded,
                    Colors.orange,
                  ),
                  _buildTabContent(
                    'Terverifikasi',
                    Icons.verified_rounded,
                    Colors.blue,
                  ),
                  _buildTabContent(
                    'Sedang Dikerjakan',
                    Icons.build_circle_rounded,
                    Colors.teal,
                  ),
                  _buildTabContent(
                    'Selesai',
                    Icons.check_circle_rounded,
                    Colors.green,
                  ),
                  _buildTabContent(
                    'Dibatalkan',
                    Icons.cancel_rounded,
                    Colors.red,
                  ),
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
      title: 'Filter Booking',
      height: Get.height * 0.65,
      padding: const EdgeInsets.all(20),
      content: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cari booking berdasarkan ID, plat, layanan, atau keluhan',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: searchController,
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Cari booking...',
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
              'Tanggal booking',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                await controller.pickFilterDate();
              },
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: Text(
                controller.selectedFilterData.value == null
                    ? 'Semua tanggal'
                    : controller.formatDate(
                      controller.selectedFilterData.value,
                    ),
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
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: ColorTheme.neonYellow,
              ),
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
      List<BookingsModel> filteredBookingStatus = controller
          .getBookingsByStatus(status);

      if (controller.selectedFilterData.value != null) {
        final filterDate = controller.selectedFilterData.value!;

        filteredBookingStatus =
            filteredBookingStatus.where((booking) {
              DateTime? bDate = booking.bookingDate;
              if (bDate == null) return false;
              return bDate.year == filterDate.year &&
                  bDate.month == filterDate.month &&
                  bDate.day == filterDate.day;
            }).toList();
      }

      if (filteredBookingStatus.isEmpty) {
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
                'Belum Ada Penugasan!', // Disesuaikan untuk konteks admin
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tidak ada booking dengan status\n"$status"',
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
        onRefresh: () => controller.fetchBookings(),
        color: Colors.black,
        backgroundColor: ColorTheme.neonYellow,
        child: ListView.separated(
          padding: const EdgeInsets.only(
            top: 16,
            left: 24,
            right: 24,
            bottom: 40,
          ),
          itemCount: filteredBookingStatus.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final booking = filteredBookingStatus[index];
            return _buildBookingCard(booking, status, icon, color);
          },
        ),
      );
    });
  }

  Widget _buildBookingCard(
    BookingsModel booking,
    String status,
    IconData icon,
    Color color,
  ) {
    // Use controller methods for data parsing
    final motorcycleInfo = controller.getMotorcycleInfo(booking);
    final servicesInfo = controller.getServicesInfo(booking);
    final dateTimeInfo = controller.formatDateTime(booking);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'ID: ${controller.formatBookingId(booking.id)}',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.2), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF4F6F9), thickness: 1.5),
          ),

          // Motor info
          if (motorcycleInfo.isNotEmpty)
            _buildInfoRow(Icons.two_wheeler_rounded, motorcycleInfo),
          if (motorcycleInfo.isNotEmpty) const SizedBox(height: 10),

          // Service info
          if (servicesInfo.isNotEmpty)
            _buildInfoRow(Icons.miscellaneous_services_rounded, servicesInfo),
          if (servicesInfo.isNotEmpty) const SizedBox(height: 10),

          // Date info
          if (dateTimeInfo.isNotEmpty)
            _buildInfoRow(Icons.calendar_month_rounded, dateTimeInfo),
          if (dateTimeInfo.isNotEmpty) const SizedBox(height: 10),

          // Complaint
          if (booking.complaint != null && booking.complaint!.isNotEmpty)
            _buildInfoRow(
              Icons.format_quote_rounded,
              booking.complaint!,
              isExpandable: true,
            ),
          if (booking.complaint != null && booking.complaint!.isNotEmpty)
            const SizedBox(height: 10),

          // Total Price
          if (booking.totalPrice != null)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: Colors.black,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Total: ${controller.formatPrice(booking.totalPrice!.toInt())}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

          if (booking.totalPrice != null) const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showBookingDetailModal(booking),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black12, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Detail',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              // Show action button only if status is not "Dibatalkan"
              if (status != 'Dibatalkan') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showActionModal(status, booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTheme.neonYellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Aksi',
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

  Widget _buildInfoRow(
    IconData icon,
    String text, {
    bool isExpandable = false,
  }) {
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
                isExpandable
                    ? const EdgeInsets.only(top: 4.0)
                    : EdgeInsets.zero,
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

  void _showBookingDetailModal(BookingsModel booking) {
    CustomModal.showBottomSheet(
      title: 'Detail Booking',
      height: Get.height * 0.75,
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'No. Booking',
                controller.formatBookingId(booking.id),
              ),
              _buildDetailRow('Motor', controller.getMotorcycleInfo(booking)),
              _buildDetailRow('Layanan', controller.getServicesInfo(booking)),
              _buildDetailRow(
                'Tanggal',
                controller.formatDate(booking.bookingDate),
              ),
              _buildDetailRow(
                'Waktu',
                '${controller.formatTime(booking.bookingTime.toString())} WIB',
              ),
              _buildDetailRow(
                'Estimasi Selesai',
                '${controller.formatEstimatedTime(booking)} WIB',
              ),
              _buildDetailRow(
                'Pembayaran DP',
                controller.getPaymentStatus(booking.id),
              ),
              _buildDetailRow(
                'Total Biaya',
                controller.formatPrice(booking.totalPrice?.toInt() ?? 0),
              ),
              _buildDetailRow('Status', booking.status ?? '-'),

              if (booking.complaint != null &&
                  booking.complaint!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Keluhan:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.complaint!,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: Get.back,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Tutup",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionModal(String status, BookingsModel booking) {
    List<ActionSheetItem> actions = [];

    switch (status) {
      case 'Menunggu Verifikasi':
        actions = [
          ActionSheetItem(
            title: 'Batalkan Booking',
            icon: Icons.cancel_rounded,
            isDestructive: true,
            onPressed: () => controller.cancelBooking(booking),
          ),
          ActionSheetItem(
            title: 'Verifikasi Booking',
            icon: Icons.check_circle_rounded,
            isDestructive: false,
            onPressed:
                () => controller.updateStatusBookingAction(
                  booking,
                  'Terverifikasi',
                ),
          ),
        ];
        break;
      case 'Terverifikasi':
        actions = [
          ActionSheetItem(
            title: 'Mulai Pengerjaan',
            icon: Icons.build_circle_rounded,
            isDestructive: false,
            onPressed:
                () => controller.updateStatusBookingAction(
                  booking,
                  'Sedang Dikerjakan',
                ),
          ),
          ActionSheetItem(
            title: 'Batalkan Booking',
            icon: Icons.cancel_rounded,
            isDestructive: true,
            onPressed: () => controller.cancelBooking(booking),
          ),
        ];
        break;
      case 'Sedang Dikerjakan':
        actions = [
          ActionSheetItem(
            title: 'Tambah Progress',
            icon: Icons.timeline_rounded,
            onPressed: () => controller.addProgress(booking),
          ),
          ActionSheetItem(
            title: 'Selesaikan Pengerjaan',
            icon: Icons.check_circle_rounded,
            isDestructive: false,
            onPressed:
                () => controller.updateStatusBookingAction(booking, 'Selesai'),
          ),
        ];
        break;
      case 'Selesai':
        actions = [
          // ActionSheetItem(
          //   title: 'Konfirmasi Pengambilan',
          //   icon: Icons.check_circle_rounded,
          //   onPressed: () => controller.confirmPickup(booking),
          // ),
          ActionSheetItem(
            title: 'Lihat Riwayat Servis',
            icon: Icons.check_circle_rounded,
            onPressed: () => controller.moveToRiwayatServis(booking),
          ),
          ActionSheetItem(
            title: 'Unduh Invoice',
            icon: Icons.download_rounded,
            onPressed: () => controller.downloadInvoice(booking),
          ),
        ];
        break;
    }

    CustomModal.showActionSheet(title: 'Pilih Aksi', actions: actions);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            ': ',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
