import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_admin/app/utils/theme/color_theme.dart';
import 'package:speedlab_admin/app/utils/widget/custom_modal.dart';
import 'package:speedlab_admin/app/utils/widget/info_card.dart';

import '../controllers/service_list_controller.dart';

String formatPrice(dynamic price) {
  final intPrice = (price % 1 == 0 ? price.toInt() : price).toString();
  final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
  return intPrice.replaceAllMapped(regex, (match) => '${match[1]}.');
}

class ServiceListView extends GetView<ServiceListController> {
  const ServiceListView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF4F6F9,
      ), // Latar belakang yang selaras dengan HomeView
      appBar: AppBar(
        backgroundColor: Colors.black, // Mengikuti koridor identitas Hitam
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Layanan Servis',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        // centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: ColorTheme.primary),
          );
        }

        if (controller.services.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.fetchServices();
          },
          color: ColorTheme.primary,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(
              top: 10,
              left: 24,
              right: 24,
              bottom: 40,
            ),
            itemCount: controller.services.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final service = controller.services[index];
              return _buildServiceCard(service);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.moveToAddService(),
        label: Text(
          "Tambah Layanan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
        ),
        icon: const Icon(Icons.add),
        backgroundColor: ColorTheme.neonYellow,
        foregroundColor: ColorTheme.darkBgPrimary,
      ),
    );
  }

  Widget _buildServiceCard(dynamic service) {
    final bool isActive = service.isActive ?? false;

    return Container(
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
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            CustomModal.showBottomSheet(
              height: Get.height * 0.8,
              title: service.name ?? "Detail Layanan",
              content: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  () => controller.moveToEditService(service),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorTheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Edit",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                ConfirmationDialog.show(
                                  title: "Hapus Layanan",
                                  message:
                                      "Apakah Anda yakin ingin menghapus layanan ini?",
                                  onConfirm: () {
                                    controller.deleteService(service.id);
                                    // Delay sebentar agar dialog konfirmasi tertutup dulu
                                    Future.delayed(
                                      const Duration(milliseconds: 200),
                                      () {
                                        Get.back(); // Tutup bottom sheet detail layanan
                                      },
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Hapus",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildDetailRow("Deskripsi", service.description ?? "-"),
                      _buildDetailRow(
                        "Harga",
                        "Rp ${formatPrice(service.basePrice ?? 0)}",
                      ),
                      _buildDetailRow(
                        "Status",
                        isActive ? "Tersedia" : "Tidak Tersedia",
                        isActive,
                      ),
                      _buildDetailRow(
                        "Durasi",
                        "${service.estimatedDuration ?? 0} Menit",
                      ),
                      const SizedBox(height: 24),

                      // ========== VARIANTS SECTION ==========
                      if (service.variants != null &&
                          service.variants!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Varian',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...service.variants!.map((variant) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        variant.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Modifier: Rp ${formatPrice(variant.priceModifier)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      if (variant.description.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            variant.description,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 16),
                          ],
                        ),

                      // ========== ADDONS SECTION ==========
                      if (service.availableAddons != null &&
                          service.availableAddons!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available Addons',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...service.availableAddons!.map((addon) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              addon.name,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  addon.type == 'OPTIONAL'
                                                      ? Colors.orange
                                                          .withOpacity(0.2)
                                                      : Colors.red.withOpacity(
                                                        0.2,
                                                      ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              addon.type,
                                              style: GoogleFonts.poppins(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    addon.type == 'OPTIONAL'
                                                        ? Colors.orange[700]
                                                        : Colors.red[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Harga: Rp ${formatPrice(addon.price)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      if (addon.description.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            addon.description,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 16),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? ColorTheme.primary.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.miscellaneous_services_rounded,
                    color: isActive ? ColorTheme.primary : Colors.grey[400],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name ?? "Layanan",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: const Color(0xFF2D3142),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isActive
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color:
                                        isActive
                                            ? Colors.green[500]
                                            : Colors.red[400],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isActive ? "Tersedia" : "Tidak Tersedia",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isActive
                                            ? Colors.green[700]
                                            : Colors.red[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[300],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ColorTheme.primary.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ColorTheme.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.miscellaneous_services_rounded,
                  size: 52,
                  color: ColorTheme.primary.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Tidak Ada Layanan",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Saat ini belum ada daftar layanan servis yang tersedia. Silakan cek kembali nanti.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [bool? isActive]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ),
          Text(
            ': ',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child:
                isActive != null
                    ? Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isActive
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          value,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                isActive ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ),
                    )
                    : Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3142),
                        height: 1.4,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
