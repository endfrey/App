import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:wstore/page/login.dart';
import 'package:wstore/services/auth.dart';
import 'package:wstore/services/shared_pref.dart';
import 'package:wstore/widget/support_widget.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? image, name, email;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  bool _isLoading = true; // ✅ ตัวแปรสถานะโหลด

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final helper = SharedPreferenceHelper();
      image = await helper.getUserImage();
      name = await helper.getUserName();
      email = await helper.getUserEmail();
    } catch (e) {
      debugPrint("❌ Error loading profile: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // ✅ โหลดเสร็จแล้ว
        });
      }
    }
  }

  Future<void> getImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      selectedImage = File(picked.path);
      await uploadItem();
      if (mounted) setState(() {});
    }
  }

  Future<void> uploadItem() async {
    if (selectedImage == null) return;

    try {
      String addId = randomAlphaNumeric(10);
      Reference ref =
          FirebaseStorage.instance.ref().child("profileImages").child(addId);

      final UploadTask task = ref.putFile(selectedImage!);
      final snapshot = await task.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await SharedPreferenceHelper().saveUserImage(downloadUrl);
      image = downloadUrl;
    } catch (e) {
      debugPrint("❌ Upload failed: $e");
    }
  }

  Widget profileInfoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0288D1), size: 30),
        title: Text(title, style: AppWidget.lightTextFieldStyle()),
        subtitle: Text(value, style: AppWidget.semiBoldTextStyle()),
      ),
    );
  }

  Widget actionCard(
      IconData icon, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: color, size: 30),
          title: Text(
            text,
            style: AppWidget.semiBoldTextStyle().copyWith(color: color),
          ),
          trailing: const Icon(Icons.arrow_forward_ios,
              size: 20, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // ✅ แสดงโหลดเฉพาะตอนยังไม่เสร็จจริง ๆ
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF64B5F6)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            GestureDetector(
              onTap: getImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.white,
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : (image != null && image!.isNotEmpty
                            ? NetworkImage(image!)
                            : const AssetImage("assets/images/w.jpg"))
                        as ImageProvider,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF64B5F6),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child:
                        const Icon(Icons.edit, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Text(
              name ?? "",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              email ?? "",
              style:
                  const TextStyle(color: Colors.blueGrey, fontSize: 15),
            ),
            const SizedBox(height: 25),

            profileInfoCard(Icons.person_outline, "Name", name ?? ""),
            profileInfoCard(Icons.email_outlined, "Email", email ?? ""),
            const SizedBox(height: 10),

            actionCard(
              Icons.logout,
              "Logout",
              Colors.orangeAccent,
              () async {
                await AuthMethod().SignOut();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LogIn()),
                  );
                }
              },
            ),
            actionCard(
              Icons.delete_outline,
              "Delete Account",
              Colors.redAccent,
              () async {
                await AuthMethod().deleteUser();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LogIn()),
                  );
                }
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
