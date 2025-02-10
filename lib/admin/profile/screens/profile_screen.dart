// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:attendance2/auth/screens/login_screen.dart';
import 'package:attendance2/auth/userdata_bloc/bloc.dart';
import 'package:attendance2/auth/userdata_bloc/state.dart';
import 'package:attendance2/config/global.dart';
import 'package:attendance2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';

class AProfileScreen extends StatefulWidget {
  final int userIdd;
  const AProfileScreen({super.key, required this.userIdd});

  @override
  State<AProfileScreen> createState() => _AProfileScreenState();
}

class _AProfileScreenState extends State<AProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final savedImageUrl = await _secureStorage.read(key: 'image');
    print('Loaded Image URL from Secure Storage: $savedImageUrl');

    if (savedImageUrl != null) {
      setState(() {
        _image = XFile(savedImageUrl.startsWith('http')
            ? savedImageUrl
            : '$baseurl$savedImageUrl');
      });
      print('Final Image Path: ${_image?.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.05),
            _buildProfileImage(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8), // Reduced padding
                minimumSize: const Size(
                    100, 36), // Set a smaller minimum size for the button
              ),
              child: const Text(
                'Upload Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14, // Optionally reduce the font size
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            BlocBuilder<UserDataBloc, UserDataState>(
              builder: (context, state) {
                if (state is UserDataLoadedState) {
                  return Column(
                    children: [
                      Text(
                        ' ${state.firstName} ${state.lastName}',
                        style: TextStyle(
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Designation : ${state.designation}",
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  );
                } else if (state is UserDataFailure) {
                  return Center(child: Text(state.errorMessage));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            const SizedBox(height: 20),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildListTile(
                  size,
                  iconPath: 'assets/icons/insurance.png',
                  titleColor: Colors.purple,
                  title: "Privacy Policy",
                  onTap: () {},
                ),
                _buildListTile(
                  size,
                  icon: Icons.logout,
                  iconColor: const Color.fromARGB(255, 248, 62, 48),
                  title: "Log Out",
                  titleColor: const Color.fromARGB(255, 248, 62, 48),
                  onTap: _showLogoutDialog,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 120, // Reduced size
      height: 120, // Reduced size
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: _image != null
            ? Image.network(
                _image!.path,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  return loadingProgress == null
                      ? child
                      : const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image,
                      size: 80, color: Colors.grey);
                },
              )
            : Container(
                width: 120,
                height: 120,
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 70, color: Colors.grey),
              ),
      ),
    );
  }

  Future<void> _uploadImage() async {
    // Request permission based on the platform
    final status = Platform.isAndroid
        ? await Permission.storage.request()
        : await Permission.photos.request();

    // Handle denied or permanently denied permissions
    if (status.isDenied || status.isPermanentlyDenied) {
      await openAppSettings();
      return;
    }

    // Proceed if permission is granted
    if (status.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final mimeType = lookupMimeType(pickedFile.path);
        if (mimeType != null && mimeType.startsWith('image')) {
          setState(() => _image = pickedFile);
        }
      }
    }

    // Exit if no image is selected
    if (_image == null) return;

    // Prepare the API request
    var uri = Uri.parse('$baseurl/api/users/${widget.userIdd}/');
    var request = http.MultipartRequest('PATCH', uri);
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    try {
      // Send the request
      var response = await request.send();

      // Handle successful response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = await response.stream.bytesToString();
        final decodedData = jsonDecode(responseData);
        final imageUrl = decodedData['image'];

        if (imageUrl != null) {
          // Save the image URL to secure storage
          await _secureStorage.write(key: 'image', value: imageUrl);

          // Update the state with the new image URL
          setState(() => _image = XFile(imageUrl));
        }
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
          ],
        );
      },
    );

    if (result == true) _logout();
  }

  Widget _buildListTile(Size size,
      {String? iconPath,
      IconData? icon,
      Color? iconColor,
      required String title,
      Color? titleColor,
      required VoidCallback onTap}) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 3,
        horizontal: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            EdgeInsets.symmetric(horizontal: size.width * 0.03, vertical: 12),
        leading: Material(
          elevation: 1,
          shape: const CircleBorder(),
          child: CircleAvatar(
            radius: size.width * 0.04,
            backgroundColor: Colors.white,
            child: iconPath != null
                ? Image.asset(iconPath,
                    width: size.width * 0.05,
                    height: size.width * 0.05,
                    fit: BoxFit.cover)
                : Icon(icon, color: iconColor, size: size.width * 0.05),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: size.width * 0.04,
            color: titleColor ?? Colors.black,
            fontWeight:
                titleColor == null ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: size.width * 0.03),
        onTap: onTap,
      ),
    );
  }

  Future<void> _logout() async {
    await _secureStorage.deleteAll();
    Navigator.pushReplacement(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
