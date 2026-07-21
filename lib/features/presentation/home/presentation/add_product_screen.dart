import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zorrow_cart/core/constants/app_colors.dart';
import 'package:zorrow_cart/core/constants/app_spacing.dart';
import 'package:zorrow_cart/core/widgets/Cusotme_Textfield.dart';
import 'package:zorrow_cart/features/presentation/bottom_navigartion_bar/bottom_navigation.dart';
import 'package:zorrow_cart/features/presentation/home/model/product_model.dart';
import 'package:zorrow_cart/features/presentation/home/provider/add_product_provider.dart';

class AddProductScreen extends StatefulWidget {
  final bool isEdit;
  final ProductModel? product;
  final String? id;

  AddProductScreen({super.key, this.isEdit = false, this.product, this.id});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final provider = context.read<AddProductProvider>();
      provider.clearImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController(
      text: widget.product?.title ?? '',
    );

    TextEditingController descriptionController = TextEditingController(
      text: widget.product?.desc ?? '',
    );

    TextEditingController priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    final _formkey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        actions: [
          widget.isEdit
              ? InkWell(
                  onTap: () async {
                    final bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: ColorConstant.mainWhite,
                          title: const Text("Delete Product"),
                          content: const Text(
                            "Are you sure you want to delete this product?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  color: ColorConstant.mainblack,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true) {
                      try {
                        await context.read<AddProductProvider>().deleteProduct(
                          widget.id.toString(),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: const [
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Product Removed",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color.fromARGB(
                              255,
                              233,
                              0,
                              0,
                            ), // Premium Green
                            behavior: SnackBarBehavior.floating,
                            elevation: 12,
                            margin: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BottomNavigation(),
                          ),
                          (route) => false,
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text("Failed to delete product"),
                          ),
                        );
                      }
                    }
                  },
                  child: Icon(Icons.delete, color: Colors.red),
                )
              : SizedBox(),
          AppSpacing.width20,
        ],

        backgroundColor: Colors.grey.shade100,
        title: Text(widget.isEdit ? "Update Product" : "Add product"),
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formkey,
            child: Consumer<AddProductProvider>(
              builder: (context, provider, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.height10,
                    InkWell(
                      onTap: () async {
                        await provider.pickImage();
                      },
                      child: Center(
                        child: Container(
                          height: 200,
                          child: provider.selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(
                                    provider.selectedImage!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : widget.isEdit
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.product!.imageUrl,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.broken_image),
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.photo_size_select_actual_rounded,
                                      size: 40,
                                      color: ColorConstant.primaryYellow,
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      "Select Product Image",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    AppSpacing.height20,
                    Text(
                      "Product name",
                      style: TextStyle(
                        color: ColorConstant.mainblack,

                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    CustomeTextfield(
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Required product name";
                        } else {
                          return null;
                        }
                      },
                      icon: Icons.card_travel,
                      label: "Product name",
                    ),
                    AppSpacing.height20,
                    Text(
                      "Description",
                      style: TextStyle(
                        color: ColorConstant.mainblack,

                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    CustomeTextfield(
                      controller: descriptionController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Required description";
                        } else {
                          return null;
                        }
                      },
                      icon: Icons.description,
                      label: "description",
                      maxline: 4,
                    ),
                    AppSpacing.height20,
                    Text(
                      "Price",
                      style: TextStyle(
                        color: ColorConstant.mainblack,

                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    CustomeTextfield(
                      controller: priceController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter a price";
                        }

                        final price = double.tryParse(value);

                        if (price == null) {
                          return "Please enter a valid price";
                        }

                        if (price <= 0) {
                          return "Price must be greater than 0";
                        }

                        return null;
                      },
                      icon: Icons.currency_rupee,
                      label: "Price",
                      keyboardType: TextInputType.number,
                    ),

                    AppSpacing.height20,

                    SizedBox(
                      height: 55,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            ColorConstant.mainblack,
                          ),
                        ),
                        onPressed: () async {
                          if (!widget.isEdit) {
                            if (_formkey.currentState!.validate()) {
                              final imageUrl = await provider.uploadImage();
                              try {
                                await provider.addProducts(
                                  ProductModel(
                                    title: nameController.text,
                                    titleLower: nameController.text
                                        .trim()
                                        .toLowerCase(),
                                    desc: descriptionController.text,
                                    price: int.parse(priceController.text),
                                    imageUrl: imageUrl!,
                                  ),
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: const [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            "Product added",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(
                                      0xFF16A34A,
                                    ), // Premium Green
                                    behavior: SnackBarBehavior.floating,
                                    elevation: 12,
                                    margin: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                provider.clearImage();
                                nameController.clear();
                                descriptionController.clear();
                                priceController.clear();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const BottomNavigation(),
                                  ),
                                  (route) => false,
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: const [
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            "Product added failed",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      199,
                                      0,
                                      0,
                                    ), // Premium Green
                                    behavior: SnackBarBehavior.floating,
                                    elevation: 12,
                                    margin: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          } else {
                            if (_formkey.currentState!.validate()) {
                              String imageUrl;

                              if (provider.selectedImage != null) {
                                imageUrl = (await provider.uploadImage())!;
                              } else {
                                imageUrl = widget.product!.imageUrl;
                              }

                              try {
                                await provider.updateProduct(
                                  ProductModel(
                                    titleLower: nameController.text
                                        .trim()
                                        .toLowerCase(),
                                    id: widget.id,
                                    title: nameController.text,
                                    desc: descriptionController.text,
                                    price: int.parse(priceController.text),
                                    imageUrl: imageUrl,
                                  ),
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text(
                                      "Product Updated Successfully",
                                    ),
                                  ),
                                );

                                provider.clearImage();
                                nameController.clear();
                                descriptionController.clear();
                                priceController.clear();

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const BottomNavigation(),
                                  ),
                                  (route) => false,
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text("Product update failed"),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: provider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                widget.isEdit
                                    ? "Update Products"
                                    : "Save Product",
                                style: TextStyle(
                                  color: ColorConstant.mainWhite,
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
