// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uas/models/event_model.dart';
import 'package:uas/providers/auth_provider.dart';
import 'package:uas/providers/event_provider.dart';
import 'package:uas/screens/auth/login_screen.dart';
import 'package:uas/screens/home/create_event_screen.dart';
import 'package:uas/screens/home/event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final Map<String, IconData> _iconMap = {
    'event': Icons.event,
    'computer': Icons.computer,
    'build': Icons.build,
    'groups': Icons.groups,
    'people': Icons.people,
    'emoji_events': Icons.emoji_events,
    'school': Icons.school,
    'book': Icons.book,
    'mosque': Icons.mosque,
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() {
    return Provider.of<EventProvider>(context, listen: false).fetchEvents();
  }

  void _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  Color _hexToColor(String? hexColor) {
    final defaultColor = Colors.grey.shade400;
    if (hexColor == null) return defaultColor;
    final hexCode = hexColor.replaceAll('#', '');
    if (hexCode.length == 6) {
      return Color(int.parse('FF$hexCode', radix: 16));
    }
    return defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id;
    final bool showMyEventsOnly = _selectedIndex == 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          showMyEventsOnly ? 'Event Saya' : 'Semua Event',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _logout,
            tooltip: 'Logout',
          )
        ],
      ),
      drawer: _buildDrawer(authProvider),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.withOpacity(0.05), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<EventProvider>(
          builder: (context, eventProvider, child) {
            if (eventProvider.isLoading && eventProvider.events.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final List<EventModel> displayedEvents = showMyEventsOnly
                ? eventProvider.events.where((event) => event.creatorId == currentUserId).toList()
                : eventProvider.events;

            if (displayedEvents.isEmpty) {
              return _buildEmptyState(isFiltered: showMyEventsOnly);
            }

            return RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: displayedEvents.length,
                itemBuilder: (context, index) {
                  final EventModel event = displayedEvents[index];
                  final iconData = _iconMap[event.icon] ?? Icons.event;
                  final iconColor = _hexToColor(event.color);

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final result = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
                        );
                        if (result == true) {
                          _fetchData();
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 80,
                            decoration: BoxDecoration(
                              color: iconColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 24,
                            // REVISI: Menggunakan warna dari data event
                            backgroundColor: iconColor.withOpacity(0.15),
                            child: Icon(iconData, color: iconColor, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                _buildInfoRow(Icons.calendar_today, event.startDate),
                                const SizedBox(height: 4),
                                _buildInfoRow(Icons.location_on, event.location),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (context) => const CreateEventScreen()),
          );
          if (result == true) {
            _fetchData();
          }
        },
        tooltip: 'Buat Event Baru',
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Drawer _buildDrawer(AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              authProvider.user?.name ?? 'Guest',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(
              authProvider.user?.email ?? '',
              style: GoogleFonts.poppins(),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                authProvider.user?.name.isNotEmpty == true ? authProvider.user!.name[0] : 'G',
                style: const TextStyle(fontSize: 40.0, color: Colors.indigo),
              ),
            ),
            decoration: const BoxDecoration(color: Colors.indigo),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Semua Event'),
            selected: _selectedIndex == 0,
            selectedTileColor: Colors.indigo.withOpacity(0.1),
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.my_library_books_outlined),
            title: const Text('Event Saya'),
            selected: _selectedIndex == 1,
            selectedTileColor: Colors.indigo.withOpacity(0.1),
            onTap: () {
              setState(() => _selectedIndex = 1);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({bool isFiltered = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 100, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            Text(
              isFiltered ? 'Anda Belum Membuat Event' : 'Belum Ada Event Tersedia',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isFiltered
                  ? 'Buat event pertama Anda dengan menekan tombol (+).'
                  : 'Tarik ke bawah untuk me-refresh atau buat event baru.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
