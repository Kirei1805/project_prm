import 'dart:convert';
import 'package:crypto/crypto.dart';

class VNPayService {
  static const String tmnCode = 'L76C51WV';
  static const String hashSecret = 'SJRLS2EYIY8AAS03WLE44XMPEATWPHD6';
  static const String vnpUrl = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  static const String returnUrl = 'https://electrohub.com/vnpay_return'; // Dummy return URL for interception

  static String generatePaymentUrl({
    required String orderId,
    required double amount,
    required String orderInfo,
  }) {
    final String cleanTmnCode = tmnCode.trim();
    final String cleanHashSecret = hashSecret.trim();

    // App uses VND now, no conversion needed
    final vnpAmount = (amount * 100).toInt(); // VNPay requires multiplying by 100
    
    final createDate = DateTime.now();
    final expireDate = createDate.add(const Duration(minutes: 15));
    
    final String vnpCreateDate = _formatDate(createDate);
    final String vnpExpireDate = _formatDate(expireDate);

    final Map<String, String> vnpParams = {
      'vnp_Version': '2.1.0',
      'vnp_Command': 'pay',
      'vnp_TmnCode': cleanTmnCode,
      'vnp_Amount': vnpAmount.toString(),
      'vnp_CreateDate': vnpCreateDate,
      'vnp_CurrCode': 'VND',
      'vnp_IpAddr': '13.160.92.202', // Public IP dummy
      'vnp_Locale': 'vn',
      'vnp_OrderInfo': orderInfo,
      'vnp_OrderType': 'other',
      'vnp_ReturnUrl': returnUrl.trim(),
      'vnp_TxnRef': orderId,
      'vnp_ExpireDate': vnpExpireDate,
    };

    final sortedKeys = vnpParams.keys.toList()..sort();
    final List<String> queryData = [];

    for (var key in sortedKeys) {
      final value = vnpParams[key];
      if (value != null && value.isNotEmpty) {
        queryData.add('${Uri.encodeComponent(key)}=${Uri.encodeComponent(value)}');
      }
    }

    final String queryStr = queryData.join('&');
    final String hashStr = queryStr; // VNPAY v2.1.0 requires hashing the url-encoded query string

    final hmac = Hmac(sha512, utf8.encode(cleanHashSecret));
    final digest = hmac.convert(utf8.encode(hashStr));
    final String secureHash = digest.toString();

    final finalUrl = '$vnpUrl?$queryStr&vnp_SecureHash=$secureHash';
    return finalUrl;
  }

  static String _formatDate(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}${date.hour.toString().padLeft(2, '0')}${date.minute.toString().padLeft(2, '0')}${date.second.toString().padLeft(2, '0')}';
  }
}
