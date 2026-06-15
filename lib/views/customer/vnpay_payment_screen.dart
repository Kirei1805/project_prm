import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/vnpay_service.dart';
import '../../utils/app_colors.dart';

class VNPayPaymentScreen extends StatefulWidget {
  final String paymentUrl;

  const VNPayPaymentScreen({super.key, required this.paymentUrl});

  @override
  State<VNPayPaymentScreen> createState() => _VNPayPaymentScreenState();
}

class _VNPayPaymentScreenState extends State<VNPayPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(VNPayService.returnUrl)) {
              // Intercept the return URL
              _handleVNPayReturn(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handleVNPayReturn(String url) {
    final uri = Uri.parse(url);
    final responseCode = uri.queryParameters['vnp_ResponseCode'];
    
    if (responseCode == '00') {
      // Payment success
      Navigator.pop(context, true);
    } else {
      // Payment failed or canceled
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VNPay Checkout'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
        ],
      ),
    );
  }
}
