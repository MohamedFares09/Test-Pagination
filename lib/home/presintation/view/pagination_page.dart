import 'package:flutter/material.dart';

class PaginationPage extends StatefulWidget {
  const PaginationPage({super.key});

  @override
  State<PaginationPage> createState() => _PaginationPageState();
}

class _PaginationPageState extends State<PaginationPage> {
  final ScrollController controller = ScrollController();
  List<int> items = List.generate(15, (index) => index);
  bool isLoading = false;
  @override
  void initState() {
    controller.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    if (isLoading) return;
    final pixel = controller.position.pixels;
    final max = controller.position.maxScrollExtent;
    print("pixel : $pixel ,  max : $max");

    if (pixel >= max - 200) {
      print("Load more");
      moreSroll();
    }
  }

  void moreSroll() {
    setState(() {
      isLoading = true;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
        items.addAll(List.generate(15, (index) => items.length + index));
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    controller.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pagination")),
      body: ListView.builder(
        controller: controller,
        itemCount: items.length + (isLoading ? 1 : 0),

        itemBuilder: (context, index) {
          if (index == items.length) {
            return Center(child: CircularProgressIndicator());
          }
          return ListTile(title: Text("Item $index"));
        },
      ),
    );
  }
}
