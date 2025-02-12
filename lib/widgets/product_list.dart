import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'product_message_card.dart';
import 'product_detail_view.dart';

class ProductList extends StatelessWidget {
  final List<Map<String, dynamic>>? products;
  final bool isLoading;

  const ProductList({
    Key? key,
    this.products,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (products == null || products!.isEmpty) return SizedBox();

    if (isLoading) {
      return SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 2,
          itemBuilder: (context, index) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 140,
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 60,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: products!.map((product) => 
          ProductMessageCard(
            product: product,
            onDetailsPressed: (name) {
              ProductDetailView.show(context, product);
            },
          ),
        ).toList(),
      ),
    );
  }
} 