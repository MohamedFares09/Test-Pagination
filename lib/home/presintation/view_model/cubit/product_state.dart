import 'package:test_pagination/home/data/models/product_model.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoadingMore extends ProductState {
  final List<ProductModel> products;
  ProductLoadingMore(this.products);
}

class ProductSuccess extends ProductState {
  final List<ProductModel> products;
  final bool hasMore;
  ProductSuccess(this.products, {this.hasMore = true});
}

class ProductError extends ProductState {
  final String error;
  ProductError(this.error);
}