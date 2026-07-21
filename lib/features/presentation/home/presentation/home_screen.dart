import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zorrow_cart/core/constants/app_colors.dart';
import 'package:zorrow_cart/core/widgets/Product_card.dart';
import 'package:zorrow_cart/features/presentation/home/presentation/add_product_screen.dart';
import 'package:zorrow_cart/features/presentation/home/presentation/product_details_screen.dart';
import 'package:zorrow_cart/features/presentation/home/provider/home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    context.read<HomeProvider>().getProducts();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    debugPrint(
      "Pixels: ${_scrollController.position.pixels}, "
      "Max: ${_scrollController.position.maxScrollExtent}",
    );

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      debugPrint("Fetching Next Page");
      context.read<HomeProvider>().fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = context.watch<HomeProvider>().bannerProducts;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: ColorConstant.mainWhite),
        backgroundColor: ColorConstant.primaryYellow,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
      ),
      backgroundColor: const Color(0xffF7F7F7),

      body: RefreshIndicator(
        onRefresh: () async {
          context.read<HomeProvider>().refreshProducts();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    final provider = context.read<HomeProvider>();

                    if (value.trim().isEmpty) {
                      provider.getProducts();
                    } else {
                      provider.searchProducts(value);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Search products...",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.grey.shade700,
                      size: 24,
                    ),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorConstant.primaryYellow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: ColorConstant.primaryYellow,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Banner
                    Column(
                      children: [
                        CarouselSlider.builder(
                          itemCount: banners.length,
                          options: CarouselOptions(
                            height: 180,
                            viewportFraction: 1,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 3),
                            enlargeCenterPage: false,
                            onPageChanged: (index, reason) {
                              context.read<HomeProvider>().changeBanner(index);
                            },
                          ),
                          itemBuilder: (context, index, realIndex) {
                            final product = banners[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailsScreen(products: product),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: banners[index].imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const ShimmerLoading(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(24),
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            const Center(
                                              child: Icon(Icons.broken_image),
                                            ),
                                      ),

                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.black.withOpacity(.65),
                                              Colors.transparent,
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                        ),
                                      ),

                                      Positioned(
                                        left: 24,
                                        bottom: 24,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Luxury\nCollection",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 18,
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: const Text(
                                                "Shop Now",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 15),

                        Consumer<HomeProvider>(
                          builder: (_, provider, __) {
                            return AnimatedSmoothIndicator(
                              activeIndex: provider.currentBanner,
                              count: banners.length,
                              effect: const ExpandingDotsEffect(
                                dotHeight: 8,
                                dotWidth: 8,
                                expansionFactor: 3,
                                activeDotColor: Colors.black,
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "New Arrivals",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Consumer<HomeProvider>(
                      builder: (context, addprovider, child) {
                        final products = addprovider.products;
                        return GridView.builder(
                          shrinkWrap: true,

                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 18,
                                childAspectRatio: .62,
                              ),
                          itemBuilder: (context, index) {
                            return product_card(
                              title: products[index].title,
                              price: products[index].price,
                              image: products[index].imageUrl,

                              onTap: () {
                                log(products[index]!.id.toString());
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsScreen(
                                      products: products[index],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
