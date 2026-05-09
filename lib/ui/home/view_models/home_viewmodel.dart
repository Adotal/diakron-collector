// home_viewmodel.dart
import 'package:diakron_collectors/data/repositories/auth/auth_repository.dart';
import 'package:diakron_collectors/utils/command.dart';
import 'package:diakron_collectors/utils/result.dart';
import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    // Command0 is used because logout doesn't require input parameters
    logout = Command0<void>(_logout);
  }
  // Estado para controlar el toggle (false = Inactivo, true = Activo)
  bool _isActive = false;
  bool get isActive => _isActive;

  final AuthRepository _authRepository;
  late Command0<void> logout;

  void toggleActive() {
    _isActive = !_isActive;
    notifyListeners();
  }

  Future<Result<void>> _logout() async {
    return await _authRepository.logout();
  }
}
