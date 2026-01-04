import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // 🔑 1. ضع مفاتيحك هنا (استبدلها بمفاتيحك)
  static const String cloudName = 'dyh9tmwbq'; // مثال: 'myapp123'
  static const String apiKey = '886678486289426'; // مثال: '123456789'
  static const String apiSecret =
      'vq_1XvE3dDuxKf3Xa2cMR_fsDek'; // مثال: 'abc123...'

  // أو استخدم Upload Preset (أسهل وأكثر أماناً)
  static const String uploadPreset =
      'flutter_app_upload'; // اسم الـ preset الذي أنشأته

  // 📸 2. اختيار صورة من المعرض
  static Future<File?> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    return file != null ? File(file.path) : null;
  }

  // ⬆️ 3. رفع الصورة باستخدام Upload Preset (الطريقة الموصى بها)
  static Future<String?> uploadImageWithPreset(
    File imageFile, {
    String userId = '',
    String folder = 'user_profiles',
  }) async {
    print('🚀 Starting upload...');

    try {
      // 1. إنشاء URL الرفع
      final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

      // 2. إعداد الـ request
      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder
        ..fields['timestamp'] = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
            .toString();

      // 3. إضافة الصورة
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          filename:
              'profile_${userId.isEmpty ? 'user' : userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      print('📤 Uploading to: $url');
      print('📁 Folder: $folder');

      // 4. إرسال الطلب
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      print('📥 Response status: ${response.statusCode}');

      // 5. التحقق من النتيجة
      if (response.statusCode == 200) {
        final imageUrl = jsonResponse['secure_url'];
        print('✅ Upload successful!');
        print('🔗 Image URL: $imageUrl');
        return imageUrl;
      } else {
        print('❌ Upload failed!');
        print('Error details: ${jsonResponse['error']}');
        return null;
      }
    } catch (e) {
      print('❌ Upload error: $e');
      return null;
    }
  }

  // 👤 4. رفع صورة البروفايل (وظيفة مخصصة)
  static Future<String?> uploadProfileImage(File image, String userId) async {
    try {
      final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = 'user_profiles'
        ..fields['public_id'] =
            'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}'
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        return data['secure_url'];
      }
      return null;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  // 🗑️ 5. حذف صورة
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      // تنفيذ حذف الصورة
      return true;
    } catch (e) {
      print('Delete error: $e');
      return false;
    }
  }

  // 🔐 6. توليد التوقيع (لعملية الحذف)
  static String _generateSignature(Map<String, dynamic> params) {
    // ترتيب parameters أبجدياً
    final sortedKeys = params.keys.toList()..sort();
    final signatureString =
        sortedKeys.map((key) => '$key=${params[key]}').join('&') + apiSecret;

    // إنشاء SHA1 signature
    final bytes = utf8.encode(signatureString);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  // 🔍 7. استخراج public_id من URL
  static String? _extractPublicId(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;

      // البحث عن المسار بعد upload/
      final uploadIndex = path.indexOf('/upload/');
      if (uploadIndex == -1) return null;

      var publicIdPath = path.substring(uploadIndex + 8);

      // إزالة الإصدار (مثل v1234567890/)
      if (publicIdPath.startsWith('v')) {
        final slashIndex = publicIdPath.indexOf('/');
        if (slashIndex != -1) {
          publicIdPath = publicIdPath.substring(slashIndex + 1);
        }
      }

      // إزالة الامتداد (.jpg, .png, إلخ)
      final dotIndex = publicIdPath.lastIndexOf('.');
      if (dotIndex != -1) {
        publicIdPath = publicIdPath.substring(0, dotIndex);
      }

      return publicIdPath;
    } catch (e) {
      print('❌ Error extracting public_id: $e');
      return null;
    }
  }

  // 🧪 8. اختبار الاتصال
  static Future<void> testConnection() async {
    print('🔗 Testing Cloudinary connection...');

    try {
      final response = await http.get(
        Uri.parse(
          'https://res.cloudinary.com/$cloudName/image/upload/v1/user_profiles/test.jpg',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 404) {
        print('✅ Connection successful! Cloudinary is reachable.');
      } else {
        print('⚠️ Connection test returned status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Connection test failed: $e');
    }
  }
}
