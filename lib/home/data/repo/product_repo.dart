import 'package:dio/dio.dart';
import 'package:test_pagination/home/data/models/product_model.dart';

abstract class ProductRepo {
  Future<List<ProductModel>> getProducts(int limit, int skip);
}

class ProductRepoImpl implements ProductRepo {
  final Dio dio;
  ProductRepoImpl({required this.dio});
  @override
  Future<List<ProductModel>> getProducts(int limit, int skip) async {
    try {
      final response = await dio.get(
        "https://dummyjson.com/products?limit=$limit&skip=$skip",
      );
      final data = response.data["products"];
      return data.map<ProductModel>((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
