import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../data/services/backend_service.dart';
import '../../../shared/styles/app_colors.dart';
import 'buyer_order_rate_page.dart';

class BuyerOrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const BuyerOrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? "unknown";
    final isCompleted = status == "delivered" || status == "completed";
    final isCancelled = status == "cancelled";
    final listing = order['listingId'] ?? {};
    final seller = order['sellerId'] ?? {};
    final volunteer = order['volunteerId'];
    final isDelivery = order['fulfillment'] == 'volunteer_delivery';
    final hasOtp = order['handoverOtp'] != null && 
        (status == 'volunteer_assigned' || status == 'picked_up' || status == 'awaiting_volunteer' || status == 'placed');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Order Details",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStatusBanner(status),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. Seller Info Card
                _buildInfoCard(
                  title: "Store Details",
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _buildImage(listing, size: 60),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              seller['name'] ?? "Unknown Donor",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              listing['pickupAddressText'] ?? "No address",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Call Seller logic
                        },
                        icon: const Icon(Icons.phone_in_talk_outlined, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Security Section (OTP)
                if (hasOtp && !isCompleted && !isCancelled)
                  _buildSecurityCard(order['handoverOtp']),

                if (hasOtp && !isCompleted && !isCancelled)
                  const SizedBox(height: 20),

                // 3. Volunteer Section (If assigned & Delivery)
                if (isDelivery && volunteer != null && !isCompleted && !isCancelled) ...[
                  _buildInfoCard(
                    title: "Volunteer Assigned",
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.person, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                volunteer['name'] ?? "Ravi Kumar (Volunteer)",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                "Your hero for this rescue!",
                                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textLight),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 4. Order Summary Card
                _buildInfoCard(
                  title: "Order Summary",
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        "${order['quantityOrdered']}x ${listing['foodName'] ?? 'Item'}",
                        "₹${order['pricing']?['itemTotal'] ?? 0}",
                      ),
                      if (isDelivery)
                        _buildSummaryRow(
                          "Delivery Fee",
                          "₹${order['pricing']?['deliveryFee'] ?? 0}",
                        ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(),
                      ),
                      _buildSummaryRow(
                        "Total",
                        "₹${order['pricing']?['total'] ?? 0}",
                        isTotal: true,
                      ),
                      if (order['specialInstructions'] != null && order['specialInstructions'].toString().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Note for Delivery:",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                order['specialInstructions'],
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.amber.shade900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 5. Timeline Tracking
                _buildInfoCard(
                  title: "Order Timeline",
                  child: _buildTimeline(order),
                ),

                const SizedBox(height: 32),

                // Rate Button
                if (isCompleted)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BuyerOrderRatePage(order: order),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Rate Order & Feedback"),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(String status) {
    Color color = Colors.blue;
    String message = "Your order is being processed";

    switch (status) {
      case "placed":
        color = Colors.blue;
        message = "Order placed successfully!";
        break;
      case "awaiting_volunteer":
        color = Colors.orange;
        message = "Finding a volunteer near you...";
        break;
      case "volunteer_assigned":
        color = Colors.indigo;
        message = "Volunteer assigned & heading to store";
        break;
      case "picked_up":
        color = Colors.purple;
        message = "Food picked up! Arriving soon";
        break;
      case "delivered":
        color = Colors.green;
        message = "Order delivered. Enjoy your meal!";
        break;
      case "cancelled":
        color = Colors.red;
        message = "This order was cancelled";
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: color.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            message,
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSecurityCard(dynamic otp) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.grey.shade900],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_person_outlined, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                "HANDOVER CODE",
                style: GoogleFonts.inter(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            otp.toString(),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Share this OTP with the volunteer/seller ONLY after you receive the food.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(Map<String, dynamic> order) {
    final timeline = order['timeline'] ?? {};
    final status = order['status'] ?? "placed";
    final stages = ['placed', 'volunteer_assigned', 'picked_up', 'delivered'];
    
    return Column(
      children: stages.map((stage) {
        int index = stages.indexOf(stage);
        bool isLast = index == stages.length - 1;
        bool isDone = _isStageDone(status, stage);
        bool isCurrent = status == stage;
        
        DateTime? timeAttr;
        String label = "Pending";
        
        if (stage == 'placed') {
          timeAttr = timeline['placedAt'] != null ? DateTime.parse(timeline['placedAt']) : null;
          label = "Order Received";
        } else if (stage == 'volunteer_assigned') {
          timeAttr = order['volunteerAssignedAt'] != null ? DateTime.parse(order['volunteerAssignedAt']) : null;
          label = "Volunteer Assigned";
        } else if (stage == 'picked_up') {
          timeAttr = timeline['pickedUpAt'] != null ? DateTime.parse(timeline['pickedUpAt']) : null;
          label = "Picked Up from Store";
        } else if (stage == 'delivered') {
          timeAttr = timeline['deliveredAt'] != null ? DateTime.parse(timeline['deliveredAt']) : null;
          label = "Delivered";
        }

        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? AppColors.primary : Colors.grey.shade300,
                      border: isCurrent ? Border.all(color: AppColors.primary, width: 3) : null,
                    ),
                    child: isDone ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isDone ? AppColors.primary : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                          color: isDone ? AppColors.textDark : AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                      if (timeAttr != null)
                        Text(
                          DateFormat('hh:mm a').format(timeAttr),
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textLight),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  bool _isStageDone(String currentStatus, String stage) {
    const order = ['placed', 'awaiting_volunteer', 'volunteer_assigned', 'picked_up', 'delivered'];
    int currentIdx = order.indexOf(currentStatus);
    int stageIdx = order.indexOf(stage);
    return currentIdx >= stageIdx;
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? AppColors.primary : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(Map<String, dynamic> listing, {double size = 50}) {
    final images = listing['images'] as List?;
    final imageUrl = (images != null && images.isNotEmpty) 
        ? BackendService.formatImageUrl(images.first) 
        : null;

    if (imageUrl == null) {
      return Container(
        width: size,
        height: size,
        color: Colors.grey.shade100,
        child: Icon(Icons.fastfood, size: size * 0.4, color: Colors.grey),
      );
    }
    return Image.network(
      imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          color: Colors.grey.shade100,
          child: Icon(Icons.image_not_supported_outlined, size: size * 0.4, color: Colors.grey),
        );
      },
    );
  }
}
