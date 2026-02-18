import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../config/api_config.dart';

class BackendService {
  /// ⚠️ UPDATED: Added /api and removed trailing slash
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<void> createUser({
    required String firebaseUid,
    required String name,
    required String email,
    required String role,
    required String phone,
    required String location,
    String? language,
  }) async {
    final url = Uri.parse("$baseUrl/users/create");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true", // Required for ngrok
      },
      body: jsonEncode({
        "firebaseUid": firebaseUid,
        "name": name,
        "email": email,
        "role": role,
        "phone": phone,
        "location": location,
        if (language != null) "language": language,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create Mongo user");
    }
  }

  static Future<void> createListing(Map<String, dynamic> listingData) async {
    final url = Uri.parse("$baseUrl/listings/create");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
      body: jsonEncode(listingData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? "Failed to create listing");
    }
  }

  static Future<void> updateListing(String id, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/listings/update/$id");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? "Failed to update listing");
    }
  }

  static Future<List<Map<String, dynamic>>> getSellerListings(
      String sellerId, String status) async {
    // status should be 'active', 'expired', or 'completed'
    final url =
        Uri.parse("$baseUrl/listings/$status?sellerId=$sellerId");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? "Failed to fetch listings");
    }
  }

  static Future<List<Map<String, dynamic>>> getAllActiveListings() async {
    final url = Uri.parse("$baseUrl/listings/active");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? "Failed to fetch active listings");
    }
  }

  static Future<Map<String, dynamic>> getSellerStats(String sellerId) async {
    final url = Uri.parse("$baseUrl/listings/seller-stats?sellerId=$sellerId");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? "Failed to fetch dashboard stats");
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String firebaseUid) async {
    final url = Uri.parse("$baseUrl/users/firebase/$firebaseUid");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch user profile");
    }
  }

  static Future<String> uploadImage(Uint8List bytes, String filename) async {
    final url = Uri.parse("$baseUrl/upload");
    debugPrint("📤 Uploading image to: $url");
    debugPrint("📁 File: $filename (${bytes.length} bytes)");
    
    final request = http.MultipartRequest("POST", url);

    request.headers.addAll({
      "ngrok-skip-browser-warning": "true",
    });

    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: filename,
      contentType: MediaType('image', filename.split('.').last.toLowerCase()),
    );

    request.files.add(multipartFile);

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("📡 Upload response status: ${response.statusCode}");
      debugPrint("📋 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['imageUrl'];
        debugPrint("✅ Upload successful! URL: $imageUrl");
        return imageUrl;
      } else {
        debugPrint("❌ UPLOAD FAILED with status: ${response.statusCode}");
        debugPrint("Response: ${response.body}");
        throw Exception("Upload failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("💥 Upload exception: $e");
      rethrow;
    }
  }

  static String formatImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      debugPrint("⚠️ formatImageUrl: path is null or empty");
      return "";
    }
    if (path.startsWith('http')) {
      debugPrint("✅ formatImageUrl: Already valid URL: $path");
      return path;
    }
    
    // Remove the /api from baseUrl to get the root
    final root = baseUrl.replaceAll('/api', '');
    final formattedUrl = "$root$path";
    debugPrint("✅ formatImageUrl: Formatted to $formattedUrl");
    return formattedUrl;
  }

  static bool isValidImageUrl(String? url) {
    final isValid = url != null && url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'));
    debugPrint("🔍 isValidImageUrl($url): $isValid");
    return isValid;
  }

  static Future<void> relistListing(String id, Map<String, dynamic> pickupWindow) async {
    final url = Uri.parse("$baseUrl/listings/relist/$id");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
      body: jsonEncode({"pickupWindow": pickupWindow}),
    );

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? "Failed to relist listing");
    }
  }

  static Future<void> updateUserPreferences({
    required String firebaseUid,
    String? language,
    String? uiMode,
  }) async {
    final url = Uri.parse("$baseUrl/users/preferences/$firebaseUid");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
      body: jsonEncode({
        if (language != null) "language": language,
        if (uiMode != null) "uiMode": uiMode,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update user preferences");
    }
  }

  /// Generate aesthetic food images using Unsplash API
  /// Query is the food name (e.g., "chocolate cake", "biryani", "salad")
  static String generateFoodImageUrl(String foodName) {
    // Using Unsplash API with food-related query
    // This provides high-quality, royalty-free images
    final foodImageMap = {
      'cake': 'photo-1578985545062-69928b1d9587',
      'biryani': 'photo-1633686326229-1be0e8c8e501',
      'pizza': 'photo-1604068549290-dea0e4a305ca',
      'salad': 'photo-1546069901-ba9599a7e63c',
      'sandwich': 'photo-1509042239860-f550ce710b93',
      'burger': 'photo-1568901346375-23c9450c58cd',
      'pasta': 'photo-1621996346565-e3dbc646d9a9',
      'rice': 'photo-1610974976856-838c11d4c909',
      'bread': 'photo-1509440159596-0249088772ff',
      'soup': 'photo-1547592166-23ac45744acd',
      'curry': 'photo-1601050690597-df0568f70950',
      'noodles': 'photo-1612874742237-6526221fcf4e',
      'dessert': 'photo-1578985545062-69928b1d9587',
      'fruit': 'photo-1599599810694-b5ac4dd64904',
      'vegetable': 'photo-1512621776951-a57141f2eefd',
      'cookie': 'photo-1499636136210-6f4ee915583e',
      'donut': 'photo-1585518419759-4d3f0c4cdf1c',
      'ice cream': 'photo-1563805042-7684c019e0d0',
      'coffee': 'photo-1495521821757-a1efb6729352',
      'tea': 'photo-1597318788039-29eeae5b7228',
    };

    String imageId = 'photo-1546069901-ba9599a7e63c'; // default: salad
    
    for (final entry in foodImageMap.entries) {
      if (foodName.toLowerCase().contains(entry.key)) {
        imageId = entry.value;
        debugPrint("🍽️  generateFoodImageUrl: Matched '$foodName' to $entry.key");
        break;
      }
    }

    final url = 'https://images.unsplash.com/$imageId?q=80&w=800&auto=format&fit=crop';
    debugPrint("🖼️  Generated food image URL: $url");
    return url;
  }
}
