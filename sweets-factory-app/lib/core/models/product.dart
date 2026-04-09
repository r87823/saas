class Product {
  final String id;
  final String name;
  final String category;
  final int prepTime; // بالساعات
  final double price;
  final String? imageUrl;
  final bool isActive;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.prepTime,
    required this.price,
    this.imageUrl,
    this.isActive = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['name'] ?? '',
      name: json['item_name'] ?? json['name'] ?? '',
      category: json['item_group'] ?? 'general',
      prepTime: json['custom_preparation_time'] ?? 1,
      price: (json['standard_rate'] ?? 0).toDouble(),
      imageUrl: json['image'],
      isActive: json['disabled'] != 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'prepTime': prepTime,
      'price': price,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }

  // أمثلة على المنتجات
  static List<Product> get sampleProducts => [
    Product(
      id: 'P001',
      name: 'تورتة شوكولاتة',
      category: 'كيك',
      prepTime: 3,
      price: 250.0,
      imageUrl: 'assets/images/chocolate_cake.jpg',
    ),
    Product(
      id: 'P002',
      name: 'تورتة فراولة',
      category: 'كيك',
      prepTime: 3,
      price: 280.0,
      imageUrl: 'assets/images/strawberry_cake.jpg',
    ),
    Product(
      id: 'P003',
      name: 'حلويات ساخنة',
      category: 'حلويات',
      prepTime: 0, // 30 دقيقة
      price: 45.0,
      imageUrl: 'assets/images/hot_sweets.jpg',
    ),
    Product(
      id: 'P004',
      name: 'كيك فانيلا',
      category: 'كيك',
      prepTime: 2,
      price: 200.0,
      imageUrl: 'assets/images/vanilla_cake.jpg',
    ),
  ];
}

enum ProductCategory {
  cake('كيك'),
  sweets('حلويات'),
  delivery('توصيل');

  final String arabicName;
  const ProductCategory(this.arabicName);
}
