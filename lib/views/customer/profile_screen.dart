import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/app_colors.dart';
import '../../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController(); // Read-only

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  
  String _avatarUrl = '';
  bool _isUploadingAvatar = false;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    if (authVM.currentUser != null) {
      _nameController.text = authVM.currentUser!.name;
      _phoneController.text = authVM.currentUser!.phone;
      _emailController.text = authVM.currentUser!.email;
      _avatarUrl = authVM.currentUser!.avatarUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _isUploadingAvatar = true;
      });
      
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      String fileName = 'avatar_${authVM.currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}';
      
      String? url = await _storageService.uploadProductImage(File(image.path), fileName);
      
      setState(() {
        _isUploadingAvatar = false;
        if (url != null) {
          _avatarUrl = url;
        }
      });
      
      if (url == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi upload ảnh!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _updateProfile() async {
    if (_profileFormKey.currentState!.validate()) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      bool success = await authVM.updateProfile(_nameController.text, _phoneController.text, _avatarUrl);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hồ sơ đã được cập nhật thành công!'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authVM.errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _changePassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mật khẩu nhập lại không khớp!'), backgroundColor: Colors.red),
        );
        return;
      }
      
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      bool success = await authVM.changePassword(_newPasswordController.text);
      
      if (mounted) {
        if (success) {
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đổi mật khẩu thành công!'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authVM.errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authVM, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar Section
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickAndUploadImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: _avatarUrl.isNotEmpty ? CachedNetworkImageProvider(_avatarUrl) : null,
                              child: _avatarUrl.isEmpty
                                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickAndUploadImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                          if (_isUploadingAvatar)
                            const Positioned.fill(
                              child: CircularProgressIndicator(color: AppColors.accent),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Profile Info Section
                    const Text(
                      'Personal Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _profileFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                            enabled: false, // Cannot change email
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                            validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
                            keyboardType: TextInputType.phone,
                            validator: (value) => value!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _updateProfile,
                            child: const Text('Update Profile'),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    const Divider(),
                    const SizedBox(height: 24),
                    
                    // Password Change Section
                    const Text(
                      'Change Password',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _passwordFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _newPasswordController,
                            decoration: const InputDecoration(labelText: 'New Password', prefixIcon: Icon(Icons.lock)),
                            obscureText: true,
                            validator: (value) => value != null && value.length < 6 ? 'Mật khẩu phải có ít nhất 6 ký tự' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: const InputDecoration(labelText: 'Confirm New Password', prefixIcon: Icon(Icons.lock_outline)),
                            obscureText: true,
                            validator: (value) => value!.isEmpty ? 'Vui lòng xác nhận mật khẩu' : null,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _changePassword,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            child: const Text('Change Password', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (authVM.isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
                ),
            ],
          );
        },
      ),
    );
  }
}
