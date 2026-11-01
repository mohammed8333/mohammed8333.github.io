import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';
import '../../core/utils/whatsapp_launcher.dart';
import '../../models/order_model.dart';
import '../../providers/settings_provider.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final ApiService _apiService = ApiService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  OrderStatus? _selectedStatusFilter;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final list = await _apiService.getAdminOrders();
      setState(() => _orders = list);
    } catch (_) {
      final local = await StorageService.loadOrders();
      setState(() => _orders = local);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changeStatus(OrderModel order, OrderStatus newStatus) async {
    await _apiService.updateOrderStatus(order.id, newStatus);
    setState(() {
      order.status = newStatus;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text('تم تحديث حالة الطلب ${order.orderReference} إلى "${order.statusArabic}"'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isArabic = settings.isArabic;

    var filtered = _orders;
    if (_selectedStatusFilter != null) {
      filtered = filtered.where((o) => o.status == _selectedStatusFilter).toList();
    }
    if (_search.trim().isNotEmpty) {
      final q = _search.toLowerCase().trim();
      filtered = filtered
          .where((o) =>
              o.orderReference.toLowerCase().contains(q) ||
              o.customerName.toLowerCase().contains(q) ||
              o.customerPhone.contains(q) ||
              o.area.toLowerCase().contains(q))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إدارة ومتابعة الطلبات' : 'Order Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: isArabic ? 'تحديث' : 'Refresh',
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: isArabic ? 'بحث برقم الطلب، اسم العميل، الهاتف...' : 'Search by order #, name, phone...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onChanged: (val) => setState(() => _search = val),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          selected: _selectedStatusFilter == null,
                          label: Text(isArabic ? 'جميع الطلبات' : 'All Orders'),
                          onSelected: (_) => setState(() => _selectedStatusFilter = null),
                        ),
                      ),
                      ...OrderStatus.values.map((status) {
                        final isSel = _selectedStatusFilter == status;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            selected: isSel,
                            label: Text(
                              _getStatusLabel(status, isArabic),
                              style: TextStyle(color: isSel ? Colors.white : null),
                            ),
                            selectedColor: _getStatusColor(status),
                            onSelected: (_) => setState(() => _selectedStatusFilter = status),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inbox, size: 60, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              isArabic ? 'لا توجد طلبات مطابقة حالياً' : 'No matching orders found',
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (context, index) {
                          final order = filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: _getStatusColor(order.status).withAlpha(120),
                                width: 1.2,
                              ),
                            ),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(order.status).withAlpha(30),
                                child: Icon(
                                  _getStatusIcon(order.status),
                                  color: _getStatusColor(order.status),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    order.orderReference,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(order.status).withAlpha(30),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getStatusLabel(order.status, isArabic),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(order.status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                '${order.customerName} • ${order.totalAmount.toStringAsFixed(0)} ج • ${order.orderType == OrderType.delivery ? 'توصيل' : 'تيك أواي'}',
                                style: const TextStyle(fontSize: 12.5),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Customer Info Row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('الهاتف: ${order.customerPhone}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.phone, color: AppColors.primary, size: 20),
                                                tooltip: 'اتصال',
                                                onPressed: () => WhatsAppLauncher.makePhoneCall(order.customerPhone),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.chat, color: AppColors.whatsApp, size: 20),
                                                tooltip: 'واتساب',
                                                onPressed: () => WhatsAppLauncher.launchWhatsAppWithMessage(
                                                  'مرحباً أستاذ ${order.customerName}، معك مطعم بيتزا أولاد الشيخ بخصوص طلبك ${order.orderReference}.',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (order.deliveryAddress.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text('العنوان: ${order.deliveryAddress} (${order.area})'),
                                      ],
                                      if (order.latitude != null && order.longitude != null) ...[
                                        const SizedBox(height: 6),
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.map, size: 16),
                                          label: const Text('موقع العميل على الخريطة', style: TextStyle(fontSize: 12)),
                                          onPressed: () => WhatsAppLauncher.openGoogleMaps(
                                            lat: order.latitude,
                                            lng: order.longitude,
                                          ),
                                        ),
                                      ],
                                      const Divider(height: 16),
                                      const Text('الأصناف المطلوبة:', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      ...order.items.map((item) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2),
                                            child: Text(
                                              '• ${item.quantity}x ${item.productNameAr} (${item.selectedSizeNameAr}) = ${item.totalPrice} جنيه',
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                          )),
                                      const Divider(height: 16),
                                      // Status Update Buttons
                                      const Text('تغيير حالة الطلب:', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: OrderStatus.values.map((s) {
                                          return ActionChip(
                                            backgroundColor: order.status == s ? _getStatusColor(s) : null,
                                            label: Text(
                                              _getStatusLabel(s, isArabic),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: order.status == s ? Colors.white : null,
                                              ),
                                            ),
                                            onPressed: () => _changeStatus(order, s),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(OrderStatus status, bool isArabic) {
    switch (status) {
      case OrderStatus.pending:
        return isArabic ? 'قيد الانتظار' : 'Pending';
      case OrderStatus.confirmed:
        return isArabic ? 'مؤكد' : 'Confirmed';
      case OrderStatus.preparing:
        return isArabic ? 'جاري التجهيز' : 'Preparing';
      case OrderStatus.outForDelivery:
        return isArabic ? 'في الطريق' : 'Out for Delivery';
      case OrderStatus.delivered:
        return isArabic ? 'تم التسليم' : 'Delivered';
      case OrderStatus.cancelled:
        return isArabic ? 'ملغي' : 'Cancelled';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.preparing:
        return AppColors.secondary;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_top;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.preparing:
        return Icons.soup_kitchen;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}
