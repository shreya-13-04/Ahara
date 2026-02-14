import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/backend_service.dart';

class AppAuthProvider extends ChangeNotifier {

  //---------------------------------------------------------
  /// SERVICES
  //---------------------------------------------------------

  final AuthService _authService = AuthService();
  final GoogleAuthService _googleService = GoogleAuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppAuthProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        refreshMongoUser();
      } else {
        _mongoUser = null;
        notifyListeners();
      }
    });
  }

  //---------------------------------------------------------
  /// STATE
  //---------------------------------------------------------

  bool _loading = false;

  bool get loading => _loading;

  Stream<User?> get authState => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Map<String, dynamic>? _mongoUser;
  Map<String, dynamic>? get mongoUser => _mongoUser;

  Map<String, dynamic>? _mongoProfile;
  Map<String, dynamic>? get mongoProfile => _mongoProfile;

  Future<void> refreshMongoUser() async {
    if (currentUser == null) return;
    
    try {
      final data = await BackendService.getUserProfile(currentUser!.uid);
      _mongoUser = data['user'];
      _mongoProfile = data['profile'];
      notifyListeners();
    } catch (e) {
      debugPrint("Error refreshing mongo user: $e");
    }
  }

  //---------------------------------------------------------
  /// EMAIL LOGIN
  /// 🔥 IMPORTANT:
  /// Mongo sync SHOULD NOT happen here.
  /// Only Firebase authentication.
  //---------------------------------------------------------

  Future<User?> login(String email, String password) async {

    _setLoading(true);

    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        await refreshMongoUser();
      }
      return user;

    } catch (e) {
      rethrow;

    } finally {
      _setLoading(false);
    }
  }

  //---------------------------------------------------------
  /// REGISTER USER
  /// ✅ Mongo sync happens INSIDE AuthService
  //---------------------------------------------------------

  Future<User?> registerUser({
    required String role,
    required String name,
    required String phone,
    required String email,
    required String password,
    required String location,
    String? businessName,
    String? businessType,
    String? fssaiNumber,
    String? transportMode,
    String? dateOfBirth,
  }) async {

    _setLoading(true);

    try {

      final user = await _authService.registerUser(
        role: role,
        name: name,
        phone: phone,
        email: email,
        password: password,
        location: location,
        businessName: businessName,
        businessType: businessType,
        fssaiNumber: fssaiNumber,
        transportMode: transportMode,
        dateOfBirth: dateOfBirth,
      );

      if (user != null) {
        await refreshMongoUser();
      }

      return user;

    } catch (e) {
      rethrow;

    } finally {
      _setLoading(false);
    }
  }

  //---------------------------------------------------------
  /// GOOGLE SIGN-IN
  /// 🔥 DO NOT sync Mongo here.
  /// Google users should complete profile first.
  //---------------------------------------------------------

  Future<User?> signInWithGoogle() async {

  _setLoading(true);

  try {

    final user = await _googleService.signInWithGoogle();

    if (user != null) {

      /// 🔥 THIS IS THE MAGIC LINE
      await _authService.registerUser(
        role: "buyer", // later make dynamic
        name: user.displayName ?? "Google User",
        phone: "",
        email: user.email!,
        password: "google-auth", // dummy, not used
        location: "",
      );
    }

    return user;

  } catch (e) {
    rethrow;
  } finally {
    _setLoading(false);
  }
}

  //---------------------------------------------------------
  /// LOGOUT
  //---------------------------------------------------------

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  
  //---------------------------------------------------------
  /// INTERNAL LOADING HANDLER
  //---------------------------------------------------------

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
