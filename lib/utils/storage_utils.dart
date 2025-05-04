// utils/storage_utils.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:emababyspa/data/models/owner.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class StorageUtils {
  static final StorageUtils _instance = StorageUtils._internal();
  factory StorageUtils() => _instance;
  StorageUtils._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final GetStorage _box = GetStorage();

  // Keys
  static const String tokenKey = 'token';
  static const String ownerKey = 'owner';
  static const String themeKey = 'theme';

  // Token methods - now using secure storage
  Future<String?> getToken() async => await _secureStorage.read(key: tokenKey);
  Future<void> setToken(String token) async =>
      await _secureStorage.write(key: tokenKey, value: token);
  Future<void> clearToken() async => await _secureStorage.delete(key: tokenKey);
  Future<bool> hasToken() async =>
      (await _secureStorage.read(key: tokenKey)) != null;

  // JWT token validation methods
  Future<bool> isTokenExpired() async {
    final token = await getToken();
    if (token == null) return true;

    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      // Invalid token format
      return true;
    }
  }

  Future<DateTime?> getTokenExpirationDate() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      return null;
    }
  }

  // Owner methods - continue using GetStorage
  Owner? getOwner() {
    final String? ownerData = _box.read<String>(ownerKey);
    if (ownerData == null) return null;
    return Owner.fromJson(json.decode(ownerData));
  }

  Future<void> setOwner(Owner owner) =>
      _box.write(ownerKey, json.encode(owner.toJson()));
  Future<void> clearOwner() => _box.remove(ownerKey);
  bool hasOwner() => _box.hasData(ownerKey);

  // Theme methods - continue using GetStorage
  String? getTheme() => _box.read<String>(themeKey);
  Future<void> setTheme(String theme) => _box.write(themeKey, theme);

  // Clear all data - now clears both storages
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _box.erase();
  }
}
