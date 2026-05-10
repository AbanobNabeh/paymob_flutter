import 'package:flutter/material.dart';
import 'package:paymob_flutter/paymob_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paymob Flutter Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: const ProductScreen(),
    );
  }
}

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool _isLoading = false;
  String? _resultMessage;
  bool? _isSuccess;

  final _config = PaymobConfig(
    apiKey: 'YOUR_API_KEY',
    integrationId: 123456,
    iframeId: 789,
    isSandbox: true,
  );

  Future<void> _checkout() async {
    setState(() {
      _isLoading = true;
      _resultMessage = null;
    });

    try {
      final result = await Paymob.pay(
        context: context,
        config: _config,
        order: PaymobOrder(
          amount: 299.99,
          currency: 'EGP',
          items: [
            OrderItem(
              name: 'Wireless Noise-Cancelling Headphones',
              amount: 299.99,
              quantity: 1,
            ),
          ],
        ),
        billing: BillingData(
          firstName: 'Abanob',
          lastName: 'Nabeh',
          email: 'Abanobnabeh5@example.com',
          phone: '+20128661021',
        ),
      );

      setState(() {
        _isSuccess = result.isSuccess;
        _resultMessage = result.isSuccess
            ? 'Payment successful!\nTransaction ID: ${result.transactionId}'
            : 'Payment failed: ${result.errorMessage}';
      });
    } on PaymobException catch (e) {
      setState(() {
        _isSuccess = false;
        _resultMessage = 'Error: ${e.message}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading:
            const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: double.infinity,
              height: 280,
              color: Colors.white,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EEFF),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Icon(
                        Icons.headphones,
                        size: 100,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Info
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand
                  const Text(
                    'SONY',
                    style: TextStyle(
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Name
                  const Text(
                    'Wireless Noise-Cancelling\nHeadphones',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Rating
                  Row(
                    children: [
                      ...List.generate(
                          5,
                          (i) => Icon(
                                i < 4 ? Icons.star : Icons.star_half,
                                color: Colors.amber,
                                size: 18,
                              )),
                      const SizedBox(width: 8),
                      const Text(
                        '4.5  (2.3k reviews)',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Row(
                    children: [
                      const Text(
                        'EGP 299.99',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'EGP 399.99',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade400,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '25% OFF',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Experience premium sound quality with industry-leading noise cancellation. '
                    '30-hour battery life, comfortable over-ear design, and crystal-clear calls.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Result Message
                  if (_resultMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: _isSuccess == true
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isSuccess == true
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                        ),
                      ),
                      child: Text(
                        _resultMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isSuccess == true
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),

                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _checkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_outline, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Checkout  •  EGP 299.99',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Powered by
                  Center(
                    child: Text(
                      'Secured by Paymob',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
