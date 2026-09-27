import 'package:hive/hive.dart';

class HiveService {
  HiveService._();

  static final HiveService instance = HiveService._();

  Box<dynamic>? _box;

  Future<void> init() async {
    _box ??= await Hive.openBox('certificat4_cache');
  }

  Box<dynamic> get box => _box ?? (throw StateError('HiveService not initialized'));

  Future<void> putJson(String key, dynamic value) async {
    _box ??= await Hive.openBox('certificat4_cache');
    await _box!.put(key, value);
  }

  dynamic getJson(String key) => _box?.get(key);

  Future<void> clear() async {
    _box ??= await Hive.openBox('certificat4_cache');
    await _box!.clear();
  }
}
