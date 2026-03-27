import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_pagination/home/data/models/product_model.dart';
import 'package:test_pagination/home/data/repo/product_repo.dart';
import 'package:test_pagination/home/presintation/view/widget/card_item.dart';
import 'package:test_pagination/home/presintation/view_model/cubit/product_cubit.dart';
import 'package:test_pagination/home/presintation/view_model/cubit/product_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductCubit(
        productRepo: ProductRepoImpl(dio: Dio()),
      )..getProducts(),
      child: const _HomePageView(),
    );
  }
}

class _HomePageView extends StatefulWidget {
  const _HomePageView();

  @override
  State<_HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<_HomePageView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final pixels = _scrollController.position.pixels;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (pixels >= maxExtent - 300) {
      context.read<ProductCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }

          if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    state.error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<ProductCubit>().getProducts(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          List<ProductModel> products = [];
          bool isLoadingMore = false;

          if (state is ProductSuccess) {
            products = state.products;
          } else if (state is ProductLoadingMore) {
            products = state.products;
            isLoadingMore = true;
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 12, bottom: 24),
            itemCount: products.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == products.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.deepPurple),
                  ),
                );
              }

              final product = products[index];
              return CardItem(
                image: product.thumbnail ?? '',
                title: product.title ?? 'No title',
                description: product.description ?? '',
                price: product.price ?? 0.0,
                rating: product.rating ?? 0.0,
                brand: product.brand,
                category: product.category,
              );
            },
          );
        },
      ),
    );
  }
}
