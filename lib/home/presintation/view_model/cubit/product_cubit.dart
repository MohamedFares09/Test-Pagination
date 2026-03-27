import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_pagination/home/data/models/product_model.dart';
import 'package:test_pagination/home/data/repo/product_repo.dart';
import 'package:test_pagination/home/presintation/view_model/cubit/product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepo productRepo;

  static const int _limit = 10;
  final List<ProductModel> _products = [];
  int _skip = 0;
  bool _hasMore = true;
  bool _isFetching = false;

  ProductCubit({required this.productRepo}) : super(ProductInitial());

  Future<void> getProducts() async {
    _products.clear();
    _skip = 0;
    _hasMore = true;
    _isFetching = false;
    emit(ProductLoading());
    try {
      final fetched = await productRepo.getProducts(_limit, _skip);
      _products.addAll(fetched);
      _skip += fetched.length;
      _hasMore = fetched.length == _limit;
      emit(ProductSuccess(List.unmodifiable(_products), hasMore: _hasMore));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (_isFetching || !_hasMore) return;
    _isFetching = true;

    final currentState = state;
    if (currentState is ProductSuccess) {
      emit(ProductLoadingMore(List.unmodifiable(_products)));
    }

    try {
      final fetched = await productRepo.getProducts(_limit, _skip);
      _products.addAll(fetched);
      _skip += fetched.length;
      _hasMore = fetched.length == _limit;
      emit(ProductSuccess(List.unmodifiable(_products), hasMore: _hasMore));
    } catch (e) {
      emit(ProductError(e.toString()));
    } finally {
      _isFetching = false;
    }
  }
}