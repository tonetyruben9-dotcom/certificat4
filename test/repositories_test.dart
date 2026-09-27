import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:certificat4/core/storage/hive_service.dart';
import 'package:certificat4/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:certificat4/features/auth/domain/entities/user_session.dart';
import 'package:certificat4/features/products/data/repositories/product_repository_impl.dart';
import 'package:certificat4/features/posts/data/repositories/post_repository_impl.dart';
import 'package:certificat4/features/products/domain/entities/product.dart';
import 'package:certificat4/features/posts/domain/entities/post.dart';

class MockDio extends Mock implements Dio {}

void main() {
  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    await HiveService.instance.init();
  });
  group('AuthRepositoryImpl', () {
    test('login returns session when API response is valid', () async {
      final dio = MockDio();
      final repository = AuthRepositoryImpl(dio: dio);

      when(() => dio.post(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).thenAnswer((_) async => Response(
        data: {
          'id': 1,
          'username': 'kminchelle',
          'email': 'kminchelle@qq.com',
          'firstName': 'Kim',
          'lastName': 'Shin',
          'gender': 'female',
          'image': 'https://via.placeholder.com/150',
          'token': 'abc123',
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/auth/login'),
      ));

      final session = await repository.login('kminchelle', '0lelplR');

      expect(session, isA<UserSession>());
      expect(session.username, 'kminchelle');
      expect(session.token, 'abc123');
    });
  });

  group('ProductRepositoryImpl', () {
    test('getProducts returns mapped product list from API', () async {
      final dio = MockDio();
      final repository = ProductRepositoryImpl(dio: dio);

      when(() => dio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      )).thenAnswer((_) async => Response(
        data: {
          'products': [
            {
              'id': 1,
              'title': 'iPhone 9',
              'price': 549,
              'description': 'An apple mobile which is nothing like apple',
              'category': 'smartphones',
              'thumbnail': 'https://via.placeholder.com/150',
            }
          ]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/products'),
      ));

      final products = await repository.getProducts();

      expect(products, isA<List<Product>>());
      expect(products.first.title, 'iPhone 9');
      expect(products.first.price, 549);
    });
  });

  group('PostRepositoryImpl', () {
    test('getPosts returns mapped post list from API', () async {
      final dio = MockDio();
      final repository = PostRepositoryImpl(dio: dio);

      when(() => dio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      )).thenAnswer((_) async => Response(
        data: {
          'posts': [
            {
              'id': 1,
              'title': 'Hello world',
              'body': 'A post body',
              'userId': 5,
            }
          ]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/posts'),
      ));

      final posts = await repository.getPosts();

      expect(posts, isA<List<Post>>());
      expect(posts.first.title, 'Hello world');
      expect(posts.first.userId, 5);
    });
  });
}
