import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:product_quote_builder/app/modules/quote_form_screen/views/quote_card.dart';
import 'package:product_quote_builder/app/modules/quote_form_screen/views/quote_preview_screen.dart';
import '../controllers/quote_form_screen_controller.dart';
import 'dotted_border_button.dart';
import 'models.dart';

class QuoteFormScreenView extends GetView<QuoteFormScreenController> {
  const QuoteFormScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Quote', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          children: [
            _buildClientDetailsCard(),
            _buildLineItemsCard(),
            _buildSummaryCard(context),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDetailsCard() {
    return QuoteCard(
      title: 'Client Details',
      child: Column(
        children: [
          _buildTextField(
            'Client Name',
            initialValue: controller.clientInfo.value.name,
            onChanged: (val) => controller.clientInfo.value.name = val,
          ),
          _buildTextField(
            'Contact Info (Email/Phone)',
            initialValue: controller.clientInfo.value.contact,
            onChanged: (val) => controller.clientInfo.value.contact = val,
          ),
          _buildTextField(
            'Address',
            initialValue: controller.clientInfo.value.address,
            onChanged: (val) => controller.clientInfo.value.address = val,
            maxLines: 2,
          ),
          _buildTextField(
            'Project Reference (e.g., Website Redesign)',
            initialValue: controller.clientInfo.value.reference,
            onChanged: (val) => controller.clientInfo.value.reference = val,
          ),
        ],
      ),
    );
  }

  Widget _buildLineItemsCard() {
    return QuoteCard(
      title: 'Quotation Items',
      child: Obx(
            () => Column(
          children: [
            ...controller.items.map((item) => _buildLineItemRow(item)),
            // Button to add new item
            Padding(
              padding: EdgeInsets.only(top: 14.0.h),
              child: DottedBorderButton(
                onTap: controller.addItem,
                text: 'Add Item',
                icon: Icons.add_circle_outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemRow(LineItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 25.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Name and Remove Button
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildItemNameField(
                  item.name.value,
                      (val) => item.name.value = val,
                ),
                ),
              ),
              if (controller.items.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                  onPressed: () => controller.removeItem(item.id),
                  tooltip: 'Remove Item',
                ),
            ],
          ),
          SizedBox(height: 8.h),

          // Quantity, Rate, Discount, Tax
          LayoutBuilder(
            builder: (context, constraints) {
              // Use a responsive layout based on screen width
              if (constraints.maxWidth > 500) {
                return Row(
                  children: [
                    _buildValueField(item.quantity, 'Quantity', flex: 2),
                    SizedBox(width: 10.w),
                    _buildValueField(item.rate, 'Rate (\$)', flex: 3),
                    SizedBox(width: 10.w),
                    _buildValueField(item.discountPercent, 'Discount (%)', flex: 2),
                    SizedBox(width: 10.w),
                    _buildValueField(item.taxPercent, 'Tax (%)', flex: 2),
                    SizedBox(width: 10.w),
                    Obx(() => _buildTotalDisplay(item.total)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        _buildValueField(item.quantity, 'Qty', flex: 1),
                        const SizedBox(width: 8),
                        _buildValueField(item.rate, 'Rate (\$)', flex: 2),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildValueField(item.discountPercent, 'Disc. (%)', flex: 1),
                        const SizedBox(width: 8),
                        _buildValueField(item.taxPercent, 'Tax (%)', flex: 1),
                        const SizedBox(width: 8),
                        Obx(() => _buildTotalDisplay(item.total, isMobile: true)),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalDisplay(double total, {bool isMobile = false}) {
    return Expanded(
      flex: isMobile ? 2 : 3,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          controller.formatCurrency(total),
          textAlign: TextAlign.right,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 14 : 16,
            color: Colors.blue.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return QuoteCard(
      title: 'Summary',
      child: Obx(
            () => Column(
          children: [
            _buildSummaryRow('Subtotal', controller.subtotal.value, context),
            _buildSummaryRow('Total Tax (${controller.items.isNotEmpty ? controller.items.first.taxPercent.value.toStringAsFixed(0) : 0}%)', controller.totalTax.value, context),
            Divider(height: 18.h, thickness: 2.w, color: Colors.black26),
            _buildSummaryRow(
              'Grand Total',
              controller.grandTotal.value,
              context,
              isGrandTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, BuildContext context, {bool isGrandTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isGrandTotal ? 14.sp : 13.sp,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
              color: isGrandTotal ? Theme.of(context).primaryColor : Colors.black87,
            ),
          ),
          Text(
            controller.formatCurrency(value),
            style: TextStyle(
              fontSize: isGrandTotal ? 14.sp : 13.sp,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w600,
              color: isGrandTotal ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: controller.clearAll,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 11.h),
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
              ),
              child: Text('Clear All', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14.sp)),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the preview screen
                Get.to(() => const QuotePreviewScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(vertical: 11.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                elevation: 5,
              ),
              child: Text('Preview Quote', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, {ValueChanged<String>? onChanged, int maxLines = 1, String? initialValue}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.r)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        ),
        onChanged: onChanged,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildItemNameField(String name, ValueChanged<String> onChanged) {
    return TextFormField(
      initialValue: name,
      decoration: InputDecoration(
        labelText: 'Item Name / Description',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildValueField(RxDouble value, String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Obx(
            () => TextFormField(
          initialValue: value.value == 0.0 ? '' : value.value.toStringAsFixed(value.value.truncateToDouble() == value.value ? 0 : 2),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.r)),
            contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.5.h),
            isDense: true,
          ),
          onChanged: (val) {
            double parsed = double.tryParse(val) ?? 0.0;
            value.value = parsed.isFinite ? parsed : 0.0;
            // The listener in QuoteController handles calling _updateTotals()
          },
        ),
      ),
    );
  }
}
