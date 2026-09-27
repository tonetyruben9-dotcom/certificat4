import 'package:certificat4/app.dart';
import 'package:certificat4/core/connectivity/network_info.dart';
import 'package:certificat4/core/network/dio_client.dart';
import 'package:certificat4/features/posts/data/repositories/post_repository_impl.dart';
import 'package:certificat4/features/posts/domain/entities/post.dart';
import 'package:certificat4/features/products/data/repositories/product_repository_impl.dart';
import 'package:certificat4/features/products/domain/entities/product.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _networkInfo = NetworkInfo(connectivity: Connectivity());
  late final ProductRepository _productRepository = ProductRepositoryImpl(dio: AppDio.create());
  late final PostRepository _postRepository = PostRepositoryImpl(dio: AppDio.create());

  List<Product> _products = [];
  List<Post> _posts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final hasNetwork = await _networkInfo.isConnected;
      if (!hasNetwork) {
        setState(() {
          _error = 'Mode hors ligne : données locales affichées.';
        });
      }

      final products = await _productRepository.getProducts();
      final posts = await _postRepository.getPosts();
      setState(() {
        _products = products;
        _posts = posts;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              onPressed: () {
                widget.appState.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              icon: const Icon(Icons.logout),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.shopping_bag), text: 'Produits'),
              Tab(icon: Icon(Icons.article), text: 'Posts'),
              Tab(icon: Icon(Icons.person), text: 'Profil'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildProductsTab(),
                  _buildPostsTab(),
                  _buildProfileTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildProductsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.orange)),
            ),
          ..._products.map((product) => Card(
                child: ListTile(
                  leading: product.thumbnail.isNotEmpty
                      ? Image.network(product.thumbnail, width: 60, height: 60, fit: BoxFit.cover)
                      : const Icon(Icons.image),
                  title: Text(product.title),
                  subtitle: Text('${product.category} • ${product.price.toStringAsFixed(2)} €'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _posts.map((post) => Card(
        child: ListTile(
          title: Text(post.title),
          subtitle: Text(post.body),
        ),
      )).toList(),
    );
  }

  Widget _buildProfileTab() {
    final session = widget.appState.session;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CircleAvatar(
          radius: 42,
          backgroundImage: session != null && session.image.isNotEmpty ? NetworkImage(session.image) : null,
          child: session == null || session.image.isEmpty ? const Icon(Icons.person, size: 42) : null,
        ),
        const SizedBox(height: 16),
        Text(session?.username ?? 'Utilisateur', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(session?.email ?? 'email@demo.com'),
        const SizedBox(height: 16),
        const Text('Mode hors ligne : disponible via cache local.'),
      ],
    );
  }
}
