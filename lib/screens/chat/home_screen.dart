import 'package:flutter/material.dart';
import 'chat_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/contact_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ChatsTab(),
    const CallsTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF00BFA5),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Calls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ── CHATS TAB ──────────────────────────────────────────
class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final contacts = await ContactService.getMellowContacts();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        title: const Text(
          'Mellow',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ChatSearchDelegate(contacts: _contacts),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00BFA5)),
            )
          : _contacts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline,
                          size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No contacts on Mellow yet',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Invite your friends to join Mellow!',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadContacts,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BFA5),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadContacts,
                  color: const Color(0xFF00BFA5),
                  child: ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF00BFA5),
                          child: Text(
                            (contact['name'] as String).isNotEmpty
                                ? (contact['name'] as String)[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          contact['name'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          contact['about'] ??
                              'Hey there! I am using Mellow 🟢',
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                userName: contact['name'],
                                userId: contact['uid'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00BFA5),
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: _loadContacts,
      ),
    );
  }
}

// ── CALLS TAB ──────────────────────────────────────────
class CallsTab extends StatelessWidget {
  const CallsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        title: const Text(
          'Calls',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) {
          final types = ['Incoming', 'Outgoing', 'Missed'];
          final icons = [
            Icons.call_received,
            Icons.call_made,
            Icons.call_missed,
          ];
          final colors = [
            Colors.green,
            const Color(0xFF00BFA5),
            Colors.red,
          ];
          final type = types[index % 3];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF00BFA5),
              child: Text(
                'U${index + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              'User ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Row(
              children: [
                Icon(icons[index % 3], size: 14, color: colors[index % 3]),
                const SizedBox(width: 4),
                Text(
                  '$type · Yesterday',
                  style: TextStyle(
                    color: colors[index % 3],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.call, color: Color(0xFF00BFA5)),
              onPressed: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00BFA5),
        child: const Icon(Icons.add_call, color: Colors.white),
        onPressed: () {},
      ),
    );
  }
}

// ── SETTINGS TAB ───────────────────────────────────────
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF00BFA5),
                    child:
                        Icon(Icons.person, color: Colors.white, size: 35),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ghulam',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Hey there! I am using Mellow 🟢',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          _buildTile(Icons.notifications, 'Notifications', () {}),
          _buildTile(Icons.lock, 'Privacy', () {}),
          _buildTile(Icons.data_usage, 'Storage and Data', () {}),
          _buildTile(Icons.language, 'App Language', () {}),
          _buildTile(Icons.help, 'Help', () {}),
          _buildTile(Icons.people, 'Invite a Friend', () {}),
          const SizedBox(height: 24),
          const Text(
            'Mellow v1.0.0',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  static Widget _buildTile(
      IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00BFA5)),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}

// ── SEARCH DELEGATE ────────────────────────────────────
class ChatSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> contacts;
  ChatSearchDelegate({required this.contacts});

  @override
  String get searchFieldLabel => 'Search chats...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF00BFA5),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.white),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final results = contacts
        .where((c) => (c['name'] as String)
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No contacts found',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final contact = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF00BFA5),
            child: Text(
              (contact['name'] as String)[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(contact['name'],
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(contact['about'] ?? '',
              style: const TextStyle(color: Colors.grey)),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  userName: contact['name'],
                  userId: contact['uid'],
                ),
              ),
            );
          },
        );
      },
    );
  }
}