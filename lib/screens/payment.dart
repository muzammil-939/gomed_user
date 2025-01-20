import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final String address;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;

  const PaymentPage({
    super.key,
    required this.address,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  bool isCardSelected = true;
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _expiryMonthController = TextEditingController();
  final TextEditingController _expiryYearController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  void _togglePaymentMethod(bool isCard) {
    setState(() {
      isCardSelected = isCard;
      _cardNumberController.clear();
      _upiController.clear();
      _expiryMonthController.clear();
      _expiryYearController.clear();
      _cvvController.clear();
    });
  }

  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      // Future API call for payment processing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing payment...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Address: ${widget.address}',
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Date: ${widget.selectedDate.toLocal()}',
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Time: ${widget.selectedTime.format(context)}',
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
                SizedBox(height: screenHeight * 0.03),
                
                // Payment Method Selection
                Text(
                  'Payment Method',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
                Row(
                  children: [
                    Radio(
                      value: true,
                      groupValue: isCardSelected,
                      onChanged: (value) => _togglePaymentMethod(true),
                    ),
                    Text('Card', style: TextStyle(fontSize: screenWidth * 0.04)),
                    Radio(
                      value: false,
                      groupValue: isCardSelected,
                      onChanged: (value) => _togglePaymentMethod(false),
                    ),
                    Text('UPI', style: TextStyle(fontSize: screenWidth * 0.04)),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),

                // Card or UPI Input Fields
                if (isCardSelected)
                  _buildCardFields(screenWidth, screenHeight)
                else
                  _buildUpiFields(screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.04),

                // Pay Now Button
                Center(
                  child: ElevatedButton(
                    onPressed: _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02, horizontal: screenWidth * 0.3),
                    ),
                    child: Text(
                      'Pay Now',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFields(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            hintText: 'Enter Card Number',
            filled: true,
            fillColor: const Color.fromARGB(255, 213, 221, 231),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty || value.length != 16) {
              return 'Enter a valid 16-digit card number';
            }
            return null;
          },
        ),
        SizedBox(height: screenHeight * 0.02),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryMonthController,
                decoration: InputDecoration(
                  hintText: 'MM',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 213, 221, 231),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) > 12) {
                    return 'Invalid month';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: TextFormField(
                controller: _expiryYearController,
                decoration: InputDecoration(
                  hintText: 'YY',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 213, 221, 231),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) < DateTime.now().year % 100) {
                    return 'Invalid year';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: InputDecoration(
                  hintText: 'CVV',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 213, 221, 231),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 3) {
                    return 'Invalid CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpiFields(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _upiController,
          decoration: InputDecoration(
            hintText: 'Enter UPI ID',
            filled: true,
            fillColor: const Color.fromARGB(255, 213, 221, 231),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty || !value.contains('@')) {
              return 'Enter a valid UPI ID';
            }
            return null;
          },
        ),
        SizedBox(height: screenHeight * 0.02),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryMonthController,
                decoration: InputDecoration(
                  hintText: 'MM',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 213, 221, 231),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) > 12) {
                    return 'Invalid month';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: TextFormField(
                controller: _expiryYearController,
                decoration: InputDecoration(
                  hintText: 'YY',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 213, 221, 231),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) < DateTime.now().year % 100) {
                    return 'Invalid year';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
