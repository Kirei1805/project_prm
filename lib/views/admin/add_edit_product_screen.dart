import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_colors.dart';

class AddEditProductScreen extends StatefulWidget {
  const AddEditProductScreen({super.key});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  ProductModel? _existingProduct;
  bool _isInit = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _brandController = TextEditingController();
  final _voltageController = TextEditingController();
  
  String _categoryId = '';
  String _imageUrl = '';
  File? _imageFile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is ProductModel) {
        _existingProduct = args;
        _nameController.text = _existingProduct!.name;
        _skuController.text = _existingProduct!.sku;
        _descriptionController.text = _existingProduct!.description;
        _priceController.text = _existingProduct!.price.toString();
        _stockController.text = _existingProduct!.stock.toString();
        _brandController.text = _existingProduct!.brand;
        _voltageController.text = _existingProduct!.voltage;
        _categoryId = _existingProduct!.categoryId;
        _imageUrl = _existingProduct!.imageUrl;
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _voltageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      String finalImageUrl = _imageUrl;
      if (_imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final uploadedUrl = await _storageService.uploadProductImage(_imageFile!, fileName);
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        }
      }

      final product = ProductModel(
        id: _existingProduct?.id ?? '',
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        stock: int.tryParse(_stockController.text) ?? 0,
        imageUrl: finalImageUrl,
        categoryId: _categoryId,
        brand: _brandController.text.trim(),
        voltage: _voltageController.text.trim(),
      );

      if (_existingProduct == null) {
        await _firestoreService.addProduct(product);
      } else {
        await _firestoreService.updateProduct(_existingProduct!.id, product);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existingProduct == null ? 'Add Product' : 'Edit Product'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.textSecondary),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_imageFile!, fit: BoxFit.cover),
                              )
                            : _imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: _imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, size: 50, color: AppColors.textSecondary),
                                      SizedBox(height: 8),
                                      Text('Tap to add image', style: TextStyle(color: AppColors.textSecondary)),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Product Name'),
                      validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Price'),
                            validator: (value) => value!.isEmpty ? 'Enter a price' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Stock Quantity'),
                            validator: (value) => value!.isEmpty ? 'Enter stock' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _skuController,
                      decoration: const InputDecoration(labelText: 'SKU'),
                      validator: (value) => value!.isEmpty ? 'Enter SKU' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(labelText: 'Brand'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _voltageController,
                      decoration: const InputDecoration(labelText: 'Voltage Spec'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('SAVE PRODUCT'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
