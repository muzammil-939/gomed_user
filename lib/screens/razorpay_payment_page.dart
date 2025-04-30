import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPaymentPage extends StatefulWidget {
  final double amount;
  final String contact;
  final String email;
  final VoidCallback onSuccess;

  const RazorpayPaymentPage({
    Key? key,
    required this.amount,
    required this.contact,
    required this.email,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<RazorpayPaymentPage> createState() => _RazorpayPaymentPageState();
}


class _RazorpayPaymentPageState extends State<RazorpayPaymentPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternal);
    _startPayment();
  }

  void _startPayment() {
    var options = {
      'key': 'rzp_live_6tvrYJlTwFFGiV', // your actual Razorpay key
      'amount': (widget.amount ).toInt(),
      'name': 'Gomed',
      'description': 'Product Booking',
      'prefill': {
        'contact': widget.contact,
        'email': widget.email,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error: $e');
      Navigator.pop(context);
    }
  }


  void _handleSuccess(PaymentSuccessResponse response) async {
    widget.onSuccess(); // ✅ Correct name based on your constructor

    Navigator.pop(context);
  }

  void _handleError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('❌ Payment failed')),
    );
    Navigator.pop(context);
  }

  void _handleExternal(ExternalWalletResponse response) {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}