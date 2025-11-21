import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const FindItApp());
}

/* =========================
   Models
   ========================= */

class Comment {
  String id;
  String postId;
  String userId;
  String userName;
  String text;
  DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> j) => Comment(
    id: j['id'],
    postId: j['postId'],
    userId: j['userId'],
    userName: j['userName'],
    text: j['text'],
    createdAt: DateTime.parse(j['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'postId': postId,
    'userId': userId,
    'userName': userName,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };
}

class Post {
  String id;
  String type; // lost / found
  String itemName;
  String? description;
  String street;
  String city;
  List<String> imageUrls; // local paths or network placeholders
  String userName;
  String userPhone;
  DateTime createdAt;
  String userId;
  List<Comment> comments;
  List<String> reports;

  Post({
    required this.id,
    required this.type,
    required this.itemName,
    this.description,
    required this.street,
    required this.city,
    required this.imageUrls,
    required this.userName,
    required this.userPhone,
    required this.createdAt,
    required this.userId,
    List<Comment>? comments,
    List<String>? reports,
  }) : comments = comments ?? [],
       reports = reports ?? [];

  factory Post.fromJson(Map<String, dynamic> j) => Post(
    id: j['id'],
    type: j['type'],
    itemName: j['itemName'],
    description: j['description'],
    street: j['street'],
    city: j['city'],
    imageUrls: List<String>.from(j['imageUrls'] ?? []),
    userName: j['userName'],
    userPhone: j['userPhone'],
    createdAt: DateTime.parse(j['createdAt']),
    userId: j['userId'],
    comments: (j['comments'] as List<dynamic>? ?? [])
        .map((c) => Comment.fromJson(c))
        .toList(),
    reports: List<String>.from(j['reports'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'itemName': itemName,
    'description': description,
    'street': street,
    'city': city,
    'imageUrls': imageUrls,
    'userName': userName,
    'userPhone': userPhone,
    'createdAt': createdAt.toIso8601String(),
    'userId': userId,
    'comments': comments.map((c) => c.toJson()).toList(),
    'reports': reports,
  };
}

class UserModel {
  String id;
  String name;
  String phone;
  String? email;
  DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'],
    name: j['name'],
    phone: j['phone'],
    email: j['email'],
    createdAt: DateTime.parse(j['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'createdAt': createdAt.toIso8601String(),
  };
}

/* =========================
   App State (Provider)
   ========================= */

class AppState extends ChangeNotifier {
  static const _kUserKey = 'findit_user';
  static const _kPostsKey = 'findit_posts';
  final SharedPreferences prefs;

  UserModel? currentUser;
  List<Post> posts = [];

  AppState(this.prefs) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    // load user
    final u = prefs.getString(_kUserKey);
    if (u != null) {
      try {
        currentUser = UserModel.fromJson(json.decode(u));
      } catch (_) {}
    }

    // load posts, otherwise seed mock data
    final p = prefs.getString(_kPostsKey);
    if (p != null) {
      try {
        final list = json.decode(p) as List<dynamic>;
        posts = list.map((j) => Post.fromJson(j)).toList();
      } catch (_) {
        posts = [];
      }
    }

    if (posts.isEmpty) {
      _seedMockData();
      await _savePosts();
    }

    notifyListeners();
  }

  Future<void> _saveUser() async {
    if (currentUser == null) {
      await prefs.remove(_kUserKey);
    } else {
      await prefs.setString(_kUserKey, json.encode(currentUser!.toJson()));
    }
  }

  Future<void> _savePosts() async {
    final encoded = json.encode(posts.map((p) => p.toJson()).toList());
    await prefs.setString(_kPostsKey, encoded);
  }

  // Authentication (frontend-only)
  Future<String?> signup({
    required String name,
    required String phone,
    String? email,
    required String password, // not stored securely here (demo only)
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // simulate loading
    final user = UserModel(
      id: const Uuid().v4(),
      name: name,
      phone: phone,
      email: email,
      createdAt: DateTime.now(),
    );
    currentUser = user;
    await _saveUser();
    notifyListeners();
    return null;
  }

  Future<String?> login({
    required String identifier, // phone or email
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // simulate loading
    final u = prefs.getString(_kUserKey);
    if (u == null) return 'No user found. Please signup first.';
    final stored = UserModel.fromJson(json.decode(u));
    if (stored.phone == identifier ||
        (stored.email != null && stored.email == identifier)) {
      currentUser = stored;
      notifyListeners();
      return null;
    }
    return 'Invalid credentials';
  }

  Future<void> logout() async {
    currentUser = null;
    await _saveUser();
    notifyListeners();
  }

  // Posts
  Future<void> addPost(Post post) async {
    posts.insert(0, post);
    await _savePosts();
    notifyListeners();
  }

  Future<void> deletePost(String postId) async {
    posts.removeWhere((p) => p.id == postId);
    await _savePosts();
    notifyListeners();
  }

  Future<void> addComment(String postId, Comment comment) async {
    final post = posts.firstWhere((p) => p.id == postId);
    post.comments.insert(0, comment);
    await _savePosts();
    notifyListeners();
  }

  Future<void> reportPost(String postId, String userId) async {
    final post = posts.firstWhere((p) => p.id == postId);
    if (!post.reports.contains(userId)) {
      post.reports.add(userId);
      await _savePosts();
      notifyListeners();
    }
  }

  void _seedMockData() {
    posts = [
      Post(
        id: const Uuid().v4(),
        type: 'lost',
        itemName: 'Black Wallet',
        description: 'Leather black wallet with ID card inside.',
        street: 'Main Street',
        city: 'Erbil',
        imageUrls: ['https://picsum.photos/id/100/400/300'],
        userName: 'Ahmed Ali',
        userPhone: '+9647500000001',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        userId: 'user_1',
      ),
      Post(
        id: const Uuid().v4(),
        type: 'found',
        itemName: 'iPhone 13',
        description: 'Found near Park Avenue, screen cracked.',
        street: 'Park Avenue',
        city: 'Sulaymaniyah',
        imageUrls: ['https://picsum.photos/id/101/400/300'],
        userName: 'Sara Mohammed',
        userPhone: '+9647500000002',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'user_2',
      ),
      Post(
        id: const Uuid().v4(),
        type: 'lost',
        itemName: 'Blue Backpack',
        description: 'Contains books and a laptop sleeve.',
        street: 'University Road',
        city: 'Duhok',
        imageUrls: ['https://picsum.photos/id/102/400/300'],
        userName: 'Omar Hassan',
        userPhone: '+9647500000003',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        userId: 'user_3',
      ),
      Post(
        id: const Uuid().v4(),
        type: 'found',
        itemName: 'Car Keys',
        description: 'With a blue keychain, Toyota logo.',
        street: 'Shopping Mall Area',
        city: 'Erbil',
        imageUrls: ['https://picsum.photos/id/103/400/300'],
        userName: 'Ameen',
        userPhone: '+9647500000004',
        createdAt: DateTime.now().subtract(const Duration(hours: 20)),
        userId: 'user_4',
      ),
      Post(
        id: const Uuid().v4(),
        type: 'lost',
        itemName: 'Gold Watch',
        description: 'Gold watch, engraving on back.',
        street: 'Fitness Center',
        city: 'Erbil',
        imageUrls: ['https://picsum.photos/id/104/400/300'],
        userName: 'Salah',
        userPhone: '+9647500000005',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        userId: 'user_5',
      ),
      Post(
        id: const Uuid().v4(),
        type: 'found',
        itemName: 'White Cat',
        description: 'Friendly white cat, collar with tag.',
        street: 'Residential Area',
        city: 'Zakho',
        imageUrls: ['https://picsum.photos/id/105/400/300'],
        userName: 'Nazar',
        userPhone: '+9647500000006',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        userId: 'user_6',
      ),
    ];
  }
}

/* =========================
   App
   ========================= */

class FindItApp extends StatelessWidget {
  const FindItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return ChangeNotifierProvider(
          create: (_) => AppState(snap.data!),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Find It',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2563EB),
              ),
              textTheme: GoogleFonts.andikaTextTheme(),
              scaffoldBackgroundColor: const Color(0xFFF9FAFB),
            ),
            home: const RootRouter(),
          ),
        );
      },
    );
  }
}

/* =========================
   Root Router: Welcome / Auth / Main App
   ========================= */

class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    if (app.currentUser == null) return const WelcomeScreen();
    return const MainPage();
  }
}

/* =========================
   Welcome & Auth Screens
   ========================= */

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF2563EB),
                    child: Text(
                      'F',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Find It',
                    style: GoogleFonts.andika(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Text(
                'Reuniting lost items across Kurdistan',
                style: GoogleFonts.andika(fontSize: 18),
              ),
              const SizedBox(height: 24),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 4,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Get Started',
                        style: GoogleFonts.andika(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // signup
  final _sName = TextEditingController();
  final _sPhone = TextEditingController();
  final _sEmail = TextEditingController();
  final _sPassword = TextEditingController();

  // login
  final _lIdentifier = TextEditingController();
  final _lPassword = TextEditingController();

  final _formKeySignup = GlobalKey<FormState>();
  final _formKeyLogin = GlobalKey<FormState>();
  bool _loading = false;

  // Updated: Accept 11-digit format (0750 222 34 44)
  final phoneReg = RegExp(r'^0\d{10}$');
  final emailReg = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _doSignup() async {
    if (!_formKeySignup.currentState!.validate()) return;
    setState(() => _loading = true);
    final app = Provider.of<AppState>(context, listen: false);
    final err = await app.signup(
      name: _sName.text.trim(),
      phone: _sPhone.text.trim(),
      email: _sEmail.text.trim().isEmpty ? null : _sEmail.text.trim(),
      password: _sPassword.text,
    );
    setState(() => _loading = false);
    if (err == null) {
      if (mounted)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainPage()),
          (r) => false,
        );
    } else {
      _showError(err);
    }
  }

  Future<void> _doLogin() async {
    if (!_formKeyLogin.currentState!.validate()) return;
    setState(() => _loading = true);
    final app = Provider.of<AppState>(context, listen: false);
    final err = await app.login(
      identifier: _lIdentifier.text.trim(),
      password: _lPassword.text,
    );
    setState(() => _loading = false);
    if (err == null) {
      if (mounted)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainPage()),
          (r) => false,
        );
    } else {
      _showError(err);
    }
  }

  void _showError(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: Colors.red[400]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login or Signup', style: GoogleFonts.andika()),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    tabs: [
                      Tab(child: Text('Login', style: GoogleFonts.andika())),
                      Tab(child: Text('Signup', style: GoogleFonts.andika())),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Login
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 16),
                          child: Form(
                            key: _formKeyLogin,
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _lIdentifier,
                                  label: 'Phone (0750 222 34 44) or Email',
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return 'Required';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: _lPassword,
                                  label: 'Password',
                                  obscure: true,
                                  validator: (v) {
                                    if (v == null || v.length < 6)
                                      return 'Minimum 6 chars';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _doLogin,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: Text(
                                      'Login',
                                      style: GoogleFonts.andika(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Signup
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 16),
                          child: Form(
                            key: _formKeySignup,
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _sName,
                                  label: 'Name',
                                  validator: (v) {
                                    if (v == null || v.trim().length < 2)
                                      return 'Enter at least 2 characters';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: _sPhone,
                                  label: 'Phone (0750 222 34 44)',
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return 'Phone is required';
                                    final clean = v.replaceAll(
                                      RegExp(r'\s'),
                                      '',
                                    );
                                    if (!phoneReg.hasMatch(clean))
                                      return 'Enter 11 digits: 0750 222 34 44';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: _sEmail,
                                  label: 'Email (optional)',
                                  validator: (v) {
                                    if (v != null &&
                                        v.isNotEmpty &&
                                        !emailReg.hasMatch(v))
                                      return 'Invalid email';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: _sPassword,
                                  label: 'Password',
                                  obscure: true,
                                  validator: (v) {
                                    if (v == null || v.length < 6)
                                      return 'Minimum 6 chars';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _doSignup,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: Text(
                                      'Create account',
                                      style: GoogleFonts.andika(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      inputFormatters: label.contains('Phone') ? [PhoneInputFormatter()] : [],
      keyboardType: label.contains('Phone')
          ? TextInputType.phone
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/* =========================
   MainPage with Bottom Navigation
   ========================= */

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selected = 0;
  static const _tabs = [HomeScreen(), ActivityScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF2563EB),
              child: Text('F', style: GoogleFonts.andika(color: Colors.white)),
            ),
            const SizedBox(width: 8),
            Text('Find It', style: GoogleFonts.andika()),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _openCreatePost(context),
            icon: const Icon(Icons.add_circle, color: Color(0xFF2563EB)),
            tooltip: 'Post',
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: _tabs[_selected],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selected,
        onTap: (i) => setState(() => _selected = i),
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Activity',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreatePost(context),
        label: Text('Post', style: GoogleFonts.andika()),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF2563EB),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _openCreatePost(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreatePostSheet(),
    );
  }
}

/* =========================
   Home Screen
   ========================= */

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchCtrl = TextEditingController();
  String cityFilter = 'All Cities';
  final cities = [
    'All Cities',
    'Erbil',
    'Sulaymaniyah',
    'Duhok',
    'Halabja',
    'Zakho',
    'Koya',
  ];

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final posts = app.posts.where((p) {
      final matchesCity = cityFilter == 'All Cities' || p.city == cityFilter;
      final q = searchCtrl.text.trim().toLowerCase();
      final matchesSearch =
          q.isEmpty ||
          p.itemName.toLowerCase().contains(q) ||
          p.city.toLowerCase().contains(q) ||
          p.street.toLowerCase().contains(q);
      return matchesCity && matchesSearch;
    }).toList();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        children: [
          TextField(
            controller: searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search items or locations...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cities.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = cities[i];
                final active = c == cityFilter;
                return ChoiceChip(
                  label: Text(
                    c,
                    style: GoogleFonts.andika(
                      color: active ? Colors.white : Colors.black87,
                    ),
                  ),
                  selected: active,
                  onSelected: (_) => setState(() => cityFilter = c),
                  selectedColor: const Color(0xFF2563EB),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: active ? Colors.transparent : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          if (posts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Column(
                  children: [
                    const Text('🔍', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      'No items found',
                      style: GoogleFonts.andika(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try adjusting your filters',
                      style: GoogleFonts.andika(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ...posts.map((p) => PostCard(post: p)).toList(),
          const SizedBox(height: 72),
        ],
      ),
    );
  }
}

/* =========================
   Post Card widget
   ========================= */

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  Widget _imageWidget(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey[200]),
        errorWidget: (_, __, ___) => Container(color: Colors.grey[200]),
      );
    } else {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(color: Colors.grey[200]);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = post.type == 'lost'
        ? const Color(0xFFEF4444)
        : const Color(0xFF10B981);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            // image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 96,
                height: 80,
                child: post.imageUrls.isNotEmpty
                    ? _imageWidget(post.imageUrls.first)
                    : Container(color: Colors.grey[200]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          post.type.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          post.itemName,
                          style: GoogleFonts.andika(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.city}, ${post.street}',
                        style: GoogleFonts.andika(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        timeago.format(post.createdAt),
                        style: GoogleFonts.andika(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        post.userName,
                        style: GoogleFonts.andika(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PostDetailScreen(postId: post.id),
                ),
              ),
              child: Text(
                'View',
                style: GoogleFonts.andika(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================
   Activity Screen
   ========================= */

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Activity', style: GoogleFonts.andika())),
      body: Center(
        child: Text(
          'Coming soon...',
          style: GoogleFonts.andika(color: Colors.grey),
        ),
      ),
    );
  }
}

/* =========================
   Profile Screen
   ========================= */

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final user = app.currentUser;
    if (user == null) {
      return Center(child: Text('Please log in', style: GoogleFonts.andika()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.andika()),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: implement settings
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user.name}',
              style: GoogleFonts.andika(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF2563EB),
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.andika(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.phone,
                        style: GoogleFonts.andika(color: Colors.grey[700]),
                      ),
                      if (user.email != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          user.email!,
                          style: GoogleFonts.andika(color: Colors.grey[700]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Your Posts',
              style: GoogleFonts.andika(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  ...app.posts
                      .where((p) => p.userId == user.id)
                      .map(
                        (p) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 96,
                                  height: 80,
                                  child: p.imageUrls.isNotEmpty
                                      ? (p.imageUrls.first.startsWith('http')
                                            ? CachedNetworkImage(
                                                imageUrl: p.imageUrls.first,
                                                fit: BoxFit.cover,
                                                placeholder: (_, __) =>
                                                    Container(
                                                      color: Colors.grey[200],
                                                    ),
                                                errorWidget: (_, __, ___) =>
                                                    Container(
                                                      color: Colors.grey[200],
                                                    ),
                                              )
                                            : Image.file(
                                                File(p.imageUrls.first),
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                  );
                                                },
                                              ))
                                      : Container(color: Colors.grey[200]),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: p.type == 'lost'
                                                ? const Color(0xFFEF4444)
                                                : const Color(0xFF10B981),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            p.type.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            p.itemName,
                                            style: GoogleFonts.andika(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${p.city}, ${p.street}',
                                          style: GoogleFonts.andika(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          timeago.format(p.createdAt),
                                          style: GoogleFonts.andika(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Icons.person,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          p.userName,
                                          style: GoogleFonts.andika(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PostDetailScreen(postId: p.id),
                                  ),
                                ),
                                child: Text(
                                  'View',
                                  style: GoogleFonts.andika(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================
   Post Detail Screen
   ========================= */

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _contactWhatsApp(String phone, String itemName) async {
    final msg = Uri.encodeComponent('Hi, I saw your post about: $itemName');
    final url = Uri.parse(
      'https://wa.me/${phone.replaceAll('+', '')}?text=$msg',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
    }
  }

  Future<void> _confirmReport(AppState app, Post post) async {
    final userId = app.currentUser?.id ?? 'anon';
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Report Post', style: GoogleFonts.andika()),
        content: Text(
          'Report this post as fake or inappropriate?',
          style: GoogleFonts.andika(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.andika()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Report', style: GoogleFonts.andika(color: Colors.red)),
          ),
        ],
      ),
    );
    if (res == true) {
      await app.reportPost(post.id, userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post reported. Thank you!')),
      );
    }
  }

  Future<void> _addComment(AppState app, Post post) async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    final user = app.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login to comment')));
      return;
    }
    final c = Comment(
      id: const Uuid().v4(),
      postId: post.id,
      userId: user.id,
      userName: user.name,
      text: text,
      createdAt: DateTime.now(),
    );
    await app.addComment(post.id, c);
    _commentCtrl.clear();
    setState(() {}); // refresh comments
  }

  Future<void> _deletePost(AppState app, Post post) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Post', style: GoogleFonts.andika()),
        content: Text(
          'Are you sure you want to delete this post?',
          style: GoogleFonts.andika(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.andika()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: GoogleFonts.andika(color: Colors.red)),
          ),
        ],
      ),
    );
    if (res == true) {
      await app.deletePost(post.id);
      Navigator.of(context).pop(); // back to previous screen
    }
  }

  Widget _imageWidget(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey[200]),
        errorWidget: (_, __, ___) => Container(color: Colors.grey[200]),
      );
    } else {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(color: Colors.grey[200]);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final post = app.posts.firstWhere((p) => p.id == widget.postId);

    return Scaffold(
      appBar: AppBar(title: Text('Post Details', style: GoogleFonts.andika())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Post images (single image - placeholder for carousel)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 240,
                child: post.imageUrls.isNotEmpty
                    ? _imageWidget(post.imageUrls.first)
                    : Container(color: Colors.grey[200]),
              ),
            ),
            const SizedBox(height: 16),
            // Post info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: post.type == 'lost'
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          post.type.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _confirmReport(app, post),
                        child: Text(
                          'Report',
                          style: GoogleFonts.andika(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.itemName,
                    style: GoogleFonts.andika(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${post.city}, ${post.street}',
                    style: GoogleFonts.andika(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeago.format(post.createdAt),
                        style: GoogleFonts.andika(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        post.userName,
                        style: GoogleFonts.andika(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _contactWhatsApp(post.userPhone, post.itemName),
                      icon: const Icon(Icons.message),
                      label: Text(
                        'Contact via WhatsApp',
                        style: GoogleFonts.andika(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: GoogleFonts.andika(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.description ?? 'No description provided.',
                    style: GoogleFonts.andika(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Comments',
                    style: GoogleFonts.andika(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Comments list
                  ...post.comments.map(
                    (c) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFF2563EB),
                                child: Text(
                                  c.userName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                c.userName,
                                style: GoogleFonts.andika(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                timeago.format(c.createdAt),
                                style: GoogleFonts.andika(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(c.text, style: GoogleFonts.andika()),
                        ],
                      ),
                    ),
                  ),
                  // Add comment field
                  const SizedBox(height: 16),
                  Text('Add a comment', style: GoogleFonts.andika()),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          decoration: InputDecoration(
                            hintText: 'Type your comment...',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _addComment(app, post),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Send', style: GoogleFonts.andika()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (app.currentUser != null &&
                      app.currentUser!.id == post.userId)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _deletePost(app, post),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Delete Post',
                          style: GoogleFonts.andika(color: Colors.red),
                        ),
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
}

/* =========================
   Create Post Sheet
   ========================= */

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  String _type = 'lost';
  final _itemName = TextEditingController();
  final _description = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final List<String> _imageUrls = [];
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _itemName.dispose();
    _description.dispose();
    _street.dispose();
    _city.dispose();
    super.dispose();
  }

  Widget _imageWidget(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        height: 120,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey[200]),
        errorWidget: (_, __, ___) => Container(color: Colors.grey[200]),
      );
    } else {
      return Image.file(
        File(url),
        width: double.infinity,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(color: Colors.grey[200]);
        },
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (_imageUrls.length < 3) _imageUrls.add(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Post',
                style: GoogleFonts.andika(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Type (Lost / Found)
                    Row(
                      children: [
                        ChoiceChip(
                          label: Text('Lost', style: GoogleFonts.andika()),
                          selected: _type == 'lost',
                          onSelected: (selected) =>
                              setState(() => _type = 'lost'),
                          selectedColor: const Color(0xFF2563EB),
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('Found', style: GoogleFonts.andika()),
                          selected: _type == 'found',
                          onSelected: (selected) =>
                              setState(() => _type = 'found'),
                          selectedColor: const Color(0xFF10B981),
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Item name
                    TextFormField(
                      controller: _itemName,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Description
                    TextFormField(
                      controller: _description,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Location
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _city,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Required';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'City',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _street,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Required';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Street',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Images
                    Column(
                      children: [
                        for (var url in _imageUrls)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _imageWidget(url),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _imageUrls.remove(url)),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_imageUrls.isEmpty)
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Center(
                              child: Text(
                                'No images selected',
                                style: GoogleFonts.andika(color: Colors.grey),
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Add Images',
                            style: GoogleFonts.andika(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;
                                final app = Provider.of<AppState>(
                                  context,
                                  listen: false,
                                );
                                if (app.currentUser == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please login to post'),
                                    ),
                                  );
                                  return;
                                }
                                setState(() => _loading = true);
                                final newPost = Post(
                                  id: const Uuid().v4(),
                                  type: _type,
                                  itemName: _itemName.text.trim(),
                                  description: _description.text.trim().isEmpty
                                      ? null
                                      : _description.text.trim(),
                                  street: _street.text.trim(),
                                  city: _city.text.trim(),
                                  imageUrls: List.from(_imageUrls),
                                  userName: app.currentUser!.name,
                                  userPhone: app.currentUser!.phone,
                                  createdAt: DateTime.now(),
                                  userId: app.currentUser!.id,
                                );
                                await app.addPost(newPost);
                                setState(() => _loading = false);
                                if (mounted) Navigator.of(context).pop();
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Submit',
                                style: GoogleFonts.andika(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* =========================
   Phone Input Formatter
   ========================= */

// Auto-format phone numbers: 0750 222 34 44
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.isEmpty) return newValue.copyWith(text: '');
    if (text.length > 11) return oldValue;

    StringBuffer formatted = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 4 || i == 7 || i == 9) {
        formatted.write(' ');
      }
      formatted.write(text[i]);
    }

    return newValue.copyWith(
      text: formatted.toString(),
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
