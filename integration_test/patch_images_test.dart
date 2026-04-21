// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_application/main_real_seed.dart' as real;

// Maps the last 10 digits of userPhone → image URLs
// Matching by suffix avoids any +964 formatting differences
const _imagesByPhoneSuffix = {
  '7501111001': [
    'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1581795669633-91ef7c9699a8?auto=format&fit=crop&w=800&q=80',
  ],
  '7701111002': [
    'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=800&q=80',
  ],
  '7501111003': [
    'https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=800&q=80',
  ],
  '7771111004': [
    'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=800&q=80',
  ],
  '7811111005': [
    'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1573865526739-10659fec78a5?auto=format&fit=crop&w=800&q=80',
  ],
  '7901111006': [
    'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=800&q=80',
  ],
  '7501111007': [
    'https://images.unsplash.com/photo-1575505586569-646b2ca898fc?auto=format&fit=crop&w=800&q=80',
  ],
  '7701111008': [
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?auto=format&fit=crop&w=800&q=80',
  ],
  '7801111009': [
    'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1525547719571-a2d4ac8945e2?auto=format&fit=crop&w=800&q=80',
  ],
};

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Patch imageUrls on existing seeded posts', (tester) async {
    await real.setupRealFirebase();

    final firestore = FirebaseFirestore.instance;

    // Fetch ALL posts so we can see exactly what phones are stored
    final allPosts = await firestore.collection('posts').get();
    print('\n── Found ${allPosts.docs.length} posts in Firestore ──');
    for (final doc in allPosts.docs) {
      final phone = doc.data()['userPhone'] as String? ?? '';
      final item = doc.data()['itemName'] as String? ?? '';
      final images = (doc.data()['imageUrls'] as List?)?.length ?? 0;
      print('  $item | phone: $phone | images: $images');
    }

    int patched = 0;

    for (final doc in allPosts.docs) {
      final phone = (doc.data()['userPhone'] as String? ?? '').replaceAll(RegExp(r'\D'), '');
      // Match by last 10 digits (e.g. 9647501111001 → 7501111001)
      final suffix = phone.length >= 10 ? phone.substring(phone.length - 10) : phone;

      final images = _imagesByPhoneSuffix[suffix];
      if (images == null) {
        print('⚠️  No image mapping for suffix $suffix');
        continue;
      }

      await doc.reference.update({'imageUrls': images});
      final item = doc.data()['itemName'] as String? ?? '';
      print('✅ Patched "$item" ($suffix) — ${images.length} image(s)');
      patched++;
    }

    print('\n🎉 Done — $patched post(s) patched.');
  });
}
