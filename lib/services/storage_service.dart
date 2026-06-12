import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StorageService {
  // Thay thế bằng API Key của ImgBB (Lấy tại: https://api.imgbb.com/)
  final String _imgbbApiKey = 'a1aca279bb1346e15caf12779e7fb279';

  Future<String?> uploadProductImage(File imageFile, String fileName) async {
    try {

      // Đọc file dưới dạng base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Gọi API của ImgBB
      final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$_imgbbApiKey');
      final response = await http.post(uri, body: {
        'image': base64Image,
        'name': fileName,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['url']; // Trả về link ảnh trực tiếp
      } else {
        print('Lỗi upload ảnh lên ImgBB: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> deleteProductImage(String imageUrl) async {
    // ImgBB API miễn phí không hỗ trợ xóa ảnh dễ dàng qua API (cần token đặc biệt).
    // Tuy nhiên trong ứng dụng bán hàng này, nếu xóa sản phẩm thì việc để lại ảnh
    // trên server ImgBB cũng không ảnh hưởng gì, ảnh sẽ tự trôi đi.
    print('Xóa ảnh bị bỏ qua vì đang dùng ImgBB.');
  }
}
