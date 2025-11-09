import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../views/models.dart';

class QuoteFormScreenController extends GetxController {
  //TODO: Implement QuoteFormScreenController

  // Static Quote ID for the preview
  final quoteId = '#2024-${const Uuid().v4().substring(0, 4).toUpperCase()}';

  // State for Client Info
  var clientInfo = ClientInfo().obs;

  // Reactive list of Line Items
  var items = <LineItem>[].obs;

  // Quote Status (Bonus Requirement)
  var status = 'Draft'.obs;
  var issueDate = DateTime.now().obs;
  var expiryDate = DateTime.now().add(const Duration(days: 30)).obs;

  @override
  void onInit() {
    super.onInit();
    // Start with one default line item
    addItem();
  }

  // Real-Time Calculations (Getx Computed Properties)

  // Subtotal (Sum of all taxable amounts across all items)
  RxDouble subtotal = 0.0.obs;

  // Total Tax (Sum of all tax amounts across all items)
  RxDouble totalTax = 0.0.obs;

  // Grand Total (Subtotal + Total Tax)
  RxDouble grandTotal = 0.0.obs;

  // Function to format currency (simulating NumberFormat)
  String formatCurrency(double value) {
    // In a real app, use: NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);
    return '\$${value.toStringAsFixed(2)}';
  }

  // Method to update all aggregate totals
  void _updateTotals() {
    double newSubtotal = 0.0;
    double newTotalTax = 0.0;

    for (var item in items) {
      // Access the calculated properties of the LineItem
      newSubtotal += item.taxableAmount;
      newTotalTax += item.taxAmount;
    }

    subtotal.value = newSubtotal;
    totalTax.value = newTotalTax;
    grandTotal.value = newSubtotal + newTotalTax;

    // Force refresh of the reactive values
    subtotal.refresh();
    totalTax.refresh();
    grandTotal.refresh();
  }

  // --- List Management Methods ---

  void addItem() {
    items.add(LineItem(id: const Uuid().v4()));
    // Add a listener to the new item's reactive properties
    items.last.quantity.listen((_) => _updateTotals());
    items.last.rate.listen((_) => _updateTotals());
    items.last.discountPercent.listen((_) => _updateTotals());
    items.last.taxPercent.listen((_) => _updateTotals());

    _updateTotals(); // Recalculate immediately
  }

  void removeItem(String id) {
    items.removeWhere((item) => item.id == id);
    _updateTotals(); // Recalculate immediately
  }

  void clearAll() {
    items.clear();
    clientInfo.value = ClientInfo();
    addItem(); // Start with one blank item
    _updateTotals();
  }
}
