import 'package:certificat4/core/errors/exceptions.dart';
import 'package:certificat4/core/storage/hive_service.dart';
import 'package:certificat4/features/products/domain/entities/product.dart';
import 'package:dio/dio.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
}

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({required this.dio});

  final Dio dio;
  static const _cacheKey = 'cached_products';

  @override
  Future<List<Product>> getProducts() async {
    try {
      final response = await dio.get(
        '/products',
        queryParameters: {'limit': 10},
        options: Options(headers: {'Accept': 'application/json'}),
      );

      final list = response.data is Map ? response.data['products'] as List? ?? [] : <dynamic>[];
      final products = list.map((item) => Product.fromMap(Map<String, dynamic>.from(item))).toList();
      await HiveService.instance.putJson(_cacheKey, list);
      return products;
    } on DioException catch (e) {
      final cached = HiveService.instance.getJson(_cacheKey);
      if (cached is List && cached.isNotEmpty) {
        return cached.map((item) => Product.fromMap(Map<String, dynamic>.from(item))).toList();
      }
      throw NetworkException(e.message ?? 'Erreur de chargement des produits');
    }
  }
}
