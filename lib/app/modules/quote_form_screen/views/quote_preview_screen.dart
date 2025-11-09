import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controllers/quote_form_screen_controller.dart';
import 'package:get/get.dart';

class QuotePreviewScreen extends GetView<QuoteFormScreenController> {
  const QuotePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quote ${controller.quoteId}', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0.w),
            child: Chip(
              label: Obx(() => Text(controller.status.value)),
              backgroundColor: Colors.amber.shade100,
              labelStyle: TextStyle(color: Colors.amber.shade800, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Client Details'),
              _buildClientDetailsPreview(),
              SizedBox(height: 22.h),
              _buildSectionTitle('Quotation Items'),
              _buildQuotationItemsTable(),
              SizedBox(height: 22.h),
              _buildSummaryPreview(context),
              SizedBox(height: 22.h),
              _buildSectionTitle('Terms & Conditions'),
              _buildTermsAndConditions(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionButtons(context),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.0.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w600, color: Colors.black54, fontSize: 12.sp),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: Colors.black87, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientDetailsPreview() {
    return Obx(() {
      final info = controller.clientInfo.value;
      return Column(
        children: [
          _buildDetailRow('Client Name', info.name.isEmpty ? 'N/A' : info.name),
          _buildDetailRow('Contact Info', info.contact.isEmpty ? 'N/A' : info.contact),
          _buildDetailRow('Address', info.address.isEmpty ? 'N/A' : info.address),
          _buildDetailRow('Project Ref', info.reference.isEmpty ? 'N/A' : info.reference),
          SizedBox(height: 10.h),
          _buildDetailRow('Issue Date', '${controller.issueDate.value.day}/${controller.issueDate.value.month}/${controller.issueDate.value.year}'),
          _buildDetailRow('Expiry Date', '${controller.expiryDate.value.day}/${controller.expiryDate.value.month}/${controller.expiryDate.value.year}'),
        ],
      );
    });
  }

  Widget _buildQuotationItemsTable() {
    return Obx(() {
      if (controller.items.isEmpty) {
        return const Center(child: Text('No items added to the quote.'));
      }
      return Table(
        columnWidths: const {
          0: FlexColumnWidth(4), // Item/Description
          1: FlexColumnWidth(1.5), // Qty
          2: FlexColumnWidth(2), // Rate
          3: FlexColumnWidth(2.5), // Total
        },
        border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(3.r)),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Table Header
          TableRow(
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
            children: const [
              _TableHeader('ITEM / DESCRIPTION'),
              _TableHeader('QTY'),
              _TableHeader('RATE'),
              _TableHeader('TOTAL'),
            ],
          ),
          // Table Rows (Items)
          ...controller.items.map((item) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name.value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp), textAlign: TextAlign.center),
                      if (item.discountPercent.value > 0)
                        Text(
                          '${item.discountPercent.value.toStringAsFixed(0)}% Discount Applied',
                          style: TextStyle(fontSize: 10.sp, color: Colors.red),
                            textAlign: TextAlign.center
                        ),
                    ],
                  ),
                ),
                Text(item.quantity.value.toStringAsFixed(item.quantity.value.truncateToDouble() == item.quantity.value ? 0 : 2), textAlign: TextAlign.center),
                Text(controller.formatCurrency(item.rate.value), textAlign: TextAlign.center),
                Text(controller.formatCurrency(item.total), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            );
          }),
        ],
      );
    });
  }

  Widget _buildSummaryPreview(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 220.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8.r, offset: const Offset(0, 5))],
        ),
        child: Obx(
              () => Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildSummaryLine('Subtotal', controller.subtotal.value, context),
              _buildSummaryLine('Tax (${controller.items.isNotEmpty ? controller.items.first.taxPercent.value.toStringAsFixed(0) : 0}%)', controller.totalTax.value, context),
              Divider(height: 18.h, thickness: 1.5.w, color: Colors.black),
              _buildSummaryLine('GRAND TOTAL', controller.grandTotal.value, context, isGrandTotal: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryLine(String label, double value, BuildContext context, {bool isGrandTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isGrandTotal ? 14.sp : 13.sp,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w600,
              color: isGrandTotal ? Theme.of(context).primaryColor : Colors.black87,
            ),
          ),
          Text(
            controller.formatCurrency(value),
            style: TextStyle(
              fontSize: isGrandTotal ? 14.sp : 13.sp,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
              color: isGrandTotal ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        'Payment is due within 30 days of the invoice date. A 50% deposit is required to commence work. The final balance is due after project completion, prior to the delivery of final files.',
        style: TextStyle(fontSize: 12.sp, color: Colors.black54, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildBottomActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8.r, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () {
              controller.status.value = 'Sent';
              Get.snackbar('Quote Sent', 'The quote has been marked as Sent.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade100, colorText: Colors.green.shade900);
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              side: const BorderSide(color: Colors.blueAccent),
            ),
            child: Text('Send Quote', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
          ),
          SizedBox(width: 10.w),
          ElevatedButton(
            onPressed: () {
              controller.status.value = 'Accepted';
              Get.snackbar('Quote Accepted', 'The quote status has been updated to Accepted.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.blue.shade100, colorText: Colors.blue.shade900);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              elevation: 3,
            ),
            child: Text('Mark as Accepted', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5.sp, color: Colors.black87),
      ),
    );
  }
}