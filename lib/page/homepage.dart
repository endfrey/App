import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wstore/Chat/chat_room_page.dart';
import 'package:wstore/page/cart_page.dart';
import 'package:wstore/page/category_product.dart';
import 'package:wstore/page/product_detail.dart';
import 'package:wstore/services/shared_pref.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Color accent = const Color(0xFF38BDF8);
  final String fixedStoreId = 'main_store';

  final TextEditingController searchController = TextEditingController();
  String searchText = '';

  String? userName;
  String? userImage;
  String? userId; // ✅ เพิ่ม userId สำหรับใช้เปิดห้องแชท

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    userName = await SharedPreferenceHelper().getUserName();
    userImage = await SharedPreferenceHelper().getUserImage();
    userId = await SharedPreferenceHelper().getUserID(); // ✅ ดึง userId จาก SharedPref
    if (mounted) setState(() {});
  }

  // 🔹 Header (เพิ่มปุ่มแชทไว้ข้างปุ่มตะกร้า)
  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Welcome",
                style: TextStyle(
                  color: Color(0xFF0C4A6E),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${userName ?? 'User'}, READY TO SHOP?",
                style: const TextStyle(color: Colors.black54, fontSize: 15),
              ),
            ],
          ),
        ),

        // 🔹 ปุ่มแชท (แก้ให้ส่ง chatId + currentUserId)
        GestureDetector(
          onTap: () {
            if (userId == null || userId!.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("ไม่พบข้อมูลผู้ใช้")),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatRoomPage(
                  chatId: userId!, // ✅ ใช้ userId เป็น chatId
                  currentUserId: userId!, // ✅ ส่ง currentUserId ด้วย
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Color(0xFF0284C7),
              size: 26,
            ),
          ),
        ),

        // 🔹 ปุ่มตะกร้า
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartPage()),
          ),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xFF0284C7),
              size: 26,
            ),
          ),
        ),

        // 🔹 รูปโปรไฟล์
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: (userImage != null && userImage!.isNotEmpty)
              ? Image.network(userImage!,
                  height: 55, width: 55, fit: BoxFit.cover)
              : Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                ),
        ),
      ],
    );
  }

  // 🔹 หมวดหมู่
  Widget buildCategoryList() {
    final categories = [
      {"img": "assets/images/headphone_icon.png", "name": "Headphone"},
      {"img": "assets/images/laptop.png", "name": "Laptop"},
      {"img": "assets/images/watch.png", "name": "Watch"},
      {"img": "assets/images/TV.png", "name": "TV"},
    ];

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CategoryProduct(category: cat["name"] ?? 'Unknown'),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 18),
              width: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFBAE6FD), Color(0xFF7DD3FC)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(cat["img"]!, height: 48),
                  const SizedBox(height: 6),
                  Text(
                    cat["name"]!,
                    style: const TextStyle(
                      color: Color(0xFF0C4A6E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔹 การ์ดสินค้า
  Widget buildProductCard(Map<String, dynamic> product) {
    final List<String> images =
        (product['images'] != null && product['images'] is List)
            ? List<String>.from(product['images'])
            : (product['Image'] != null ? [product['Image']] : []);

    final String firstImg = images.isNotEmpty ? images[0] : "";
    final String title = product["UpdatedName"] ?? product["Name"] ?? "";
    final String price = product["Price"]?.toString() ?? "0";
    final String productId = product["productId"];
    final variants = product["variants"] != null
        ? List<Map<String, dynamic>>.from(product["variants"])
        : null;

    return Container(
      margin: const EdgeInsets.only(right: 14),
      width: 165,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.45),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetail(
              image: firstImg,
              name: title,
              price: price,
              detail: product["Detail"] ?? "",
              productId: productId,
              storeId: fixedStoreId,
              variants: variants,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: firstImg.startsWith("http")
                  ? Image.network(firstImg,
                      height: 120, width: double.infinity, fit: BoxFit.cover)
                  : Image.asset(firstImg,
                      height: 120, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0C4A6E),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    "฿$price",
                    style: const TextStyle(
                      color: Color(0xFF0284C7),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 หน้า Home หลัก
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Products")
              .where("storeId", isEqualTo: fixedStoreId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            final products = docs.map((d) {
              final m = d.data() as Map<String, dynamic>;
              return {...m, "productId": d.id};
            }).toList();

            final filteredProducts = searchText.isEmpty
                ? products
                : products.where((p) {
                    final name = (p["UpdatedName"] ?? p["Name"] ?? "")
                        .toString()
                        .toLowerCase();
                    final detail =
                        (p["Detail"] ?? "").toString().toLowerCase();
                    return name.contains(searchText) ||
                        detail.contains(searchText);
                  }).toList();

            final best = List<Map<String, dynamic>>.from(filteredProducts)
              ..sort((a, b) =>
                  (b["salesCount"] ?? 0).compareTo(a["salesCount"] ?? 0));

            final newest = List<Map<String, dynamic>>.from(filteredProducts)
              ..sort((a, b) => ((b["createdAt"] ?? Timestamp.now()) as Timestamp)
                  .compareTo(a["createdAt"] ?? Timestamp.now()));

            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 20),
                  // 🔹 Search Bar
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (v) =>
                          setState(() => searchText = v.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: "Search product...",
                        border: InputBorder.none,
                        icon: const Icon(Icons.search,
                            color: Color(0xFF38BDF8)),
                        suffixIcon: searchText.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close,
                                    color: Color(0xFF38BDF8)),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() => searchText = "");
                                },
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text("Categories",
                      style: TextStyle(
                          color: Color(0xFF0C4A6E),
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  buildCategoryList(),
                  const SizedBox(height: 22),
                  const Text("สินค้าขายดี",
                      style: TextStyle(
                          color: Color(0xFF0C4A6E),
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: best.length,
                      itemBuilder: (_, i) => buildProductCard(best[i]),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text("สินค้าใหม่ล่าสุด",
                      style: TextStyle(
                          color: Color(0xFF0C4A6E),
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: newest.length,
                      itemBuilder: (_, i) => buildProductCard(newest[i]),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text("สินค้าเพิ่มเติม",
                      style: TextStyle(
                          color: Color(0xFF0C4A6E),
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: filteredProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (_, i) =>
                        buildProductCard(filteredProducts[i]),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
