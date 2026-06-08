import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactService {
  static Future<List<Map<String, dynamic>>> getMellowContacts() async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      final mellowContacts = <Map<String, dynamic>>[];
      final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

      // Build a list of all Mellow users with normalized phones
      final mellowUsers = <Map<String, dynamic>>[];
      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        if (data['uid'] != currentUserUid && data['phone'] != null) {
          mellowUsers.add({
            ...data,
            '_normalizedVariants': _getPhoneVariants(data['phone']),
          });
        }
      }

      // For now show all Mellow users
      // When phone contacts are added later, filter by contact list
      for (final user in mellowUsers) {
        String displayName = '';
        if (user['name'] != null &&
            user['name'].toString().trim().isNotEmpty) {
          displayName = user['name'].toString().trim();
        } else {
          displayName = _formatPhoneForDisplay(user['phone'] ?? 'Unknown');
        }

        mellowContacts.add({
          'name': displayName,
          'phone': user['phone'] ?? '',
          'uid': user['uid'] ?? '',
          'about': user['about'] ?? 'Hey there! I am using Mellow 🟢',
          'photoUrl': user['photoUrl'] ?? '',
        });
      }

      return mellowContacts;
    } catch (e) {
      return [];
    }
  }

  // Generate ALL possible variants of a phone number
  // This is how WhatsApp matches numbers in any format
  static List<String> _getPhoneVariants(String phone) {
    // Strip everything except digits
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    final variants = <String>{};

    // Add the raw digits
    variants.add(digitsOnly);

    // Add with + prefix
    variants.add('+$digitsOnly');

    // If starts with country code (more than 10 digits)
    // Generate local version by removing first 1-3 digits
    if (digitsOnly.length > 10) {
      // Remove 1 digit country code (e.g. 1 for USA)
      final local1 = digitsOnly.substring(1);
      variants.add(local1);
      variants.add('0$local1'); // with leading 0
      variants.add('+$local1');

      // Remove 2 digit country code (e.g. 92 for Pakistan, 44 for UK)
      if (digitsOnly.length > 11) {
        final local2 = digitsOnly.substring(2);
        variants.add(local2);
        variants.add('0$local2'); // with leading 0
        variants.add('+$local2');
      }

      // Remove 3 digit country code (e.g. 971 for UAE, 966 for Saudi)
      if (digitsOnly.length > 12) {
        final local3 = digitsOnly.substring(3);
        variants.add(local3);
        variants.add('0$local3'); // with leading 0
        variants.add('+$local3');
      }
    }

    // If starts with 0 (local format)
    if (digitsOnly.startsWith('0')) {
      // Remove leading 0
      final withoutZero = digitsOnly.substring(1);
      variants.add(withoutZero);
      variants.add('+$withoutZero');

      // Common country codes to try
      const countryCodes = ['1', '7', '20', '27', '30', '31', '32', '33',
        '34', '36', '39', '40', '41', '43', '44', '45', '46', '47', '48',
        '49', '51', '52', '53', '54', '55', '56', '57', '58', '60', '61',
        '62', '63', '64', '65', '66', '81', '82', '84', '86', '90', '91',
        '92', '93', '94', '95', '98', '212', '213', '216', '218', '220',
        '221', '222', '223', '224', '225', '226', '227', '228', '229',
        '230', '231', '232', '233', '234', '235', '236', '237', '238',
        '239', '240', '241', '242', '243', '244', '245', '246', '247',
        '248', '249', '250', '251', '252', '253', '254', '255', '256',
        '257', '258', '260', '261', '262', '263', '264', '265', '266',
        '267', '268', '269', '290', '291', '297', '298', '299', '350',
        '351', '352', '353', '354', '355', '356', '357', '358', '359',
        '370', '371', '372', '373', '374', '375', '376', '377', '378',
        '380', '381', '382', '385', '386', '387', '389', '420', '421',
        '423', '500', '501', '502', '503', '504', '505', '506', '507',
        '508', '509', '590', '591', '592', '593', '594', '595', '596',
        '597', '598', '599', '670', '672', '673', '674', '675', '676',
        '677', '678', '679', '680', '681', '682', '683', '685', '686',
        '687', '688', '689', '690', '691', '692', '850', '852', '853',
        '855', '856', '880', '886', '960', '961', '962', '963', '964',
        '965', '966', '967', '968', '970', '971', '972', '973', '974',
        '975', '976', '977', '992', '993', '994', '995', '996', '998'];

      for (final code in countryCodes) {
        variants.add('$code$withoutZero');
        variants.add('+$code$withoutZero');
      }
    }

    return variants.toList();
  }

  // Check if two phone numbers match — WhatsApp style
  static bool phonesMatch(String phone1, String phone2) {
    final variants1 = _getPhoneVariants(phone1).toSet();
    final variants2 = _getPhoneVariants(phone2).toSet();

    // If any variant matches — it's the same number
    return variants1.intersection(variants2).isNotEmpty;
  }

  // Normalize for simple storage/comparison
  static String normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  // Format phone nicely for display
  static String _formatPhoneForDisplay(String phone) {
    String cleaned = phone
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '');
    if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    }
    return cleaned;
  }
}