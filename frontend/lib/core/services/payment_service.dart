import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // Uncomment if using dotenv

class PaymentService {
  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? _onSuccess;
  Function(PaymentFailureResponse)? _onFailure;
  Function(ExternalWalletResponse)? _onExternalWallet;

  // Singleton pattern
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;

  PaymentService._internal() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void initialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    Function(ExternalWalletResponse)? onExternalWallet,
  }) {
    _onSuccess = onSuccess;
    _onFailure = onFailure;
    _onExternalWallet = onExternalWallet;
  }

  void openCheckout({
    required String orderId,
    required double amount, // In INR (not paise)
    required String contact,
    required String email,
    required String keyId, // Pass from backend or env
    String shopName = "Ahara",
    String description = "Food Order",
  }) {
    var options = {
      'key': keyId,
      'amount': (amount * 100).toInt(), // Convert to paise
      'name': shopName,
      'description': description,
      'header': {
        'logo': 'https://your-logo-url.com/logo.png' // Optional
      },
      'order_id': orderId, // Generate this from backend
      'prefill': {'contact': contact, 'email': email},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_onSuccess != null) {
      _onSuccess!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (_onFailure != null) {
      _onFailure!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (_onExternalWallet != null) {
      _onExternalWallet!(response);
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
