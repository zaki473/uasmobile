import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  UserModel? get currentUser => _user;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    _user = await AuthService().login(email, password);
    _isLoading = false;
    notifyListeners();
    
    return _user != null;
  }
  

  void logout() {
    _user = null;
    notifyListeners();
  }
}

