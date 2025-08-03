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
    'event': Icons.event, 'computer': Icons.computer, 'build': Icons.build,
    'groups': Icons.groups, 'people': Icons.people, 'emoji_events': Icons.emoji_events,
    'school': Icons.school, 'book': Icons.book, 'mosque': Icons.mosque,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      await Provider.of<EventProvider>(context, listen: false).fetchEvents(token);
    }
  }

  void _logout() async {
    final navigator = Navigator.of(context);
    await Provider.of<AuthProvider>(context, listen: false).logout();
    if (!mounted) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
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
        title: Text(showMyEventsOnly ? 'Event Saya' : 'Semua Event'),
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
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (eventProvider.errorMessage.isNotEmpty) {
            return Center(child: Text('Gagal memuat data: ${eventProvider.errorMessage}'));
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
                final bool isEventFull = event.currentParticipants >= event.maxParticipants;

                return Card(
                  elevation: 3,
                  shadowColor: Colors.black.withOpacity(0.1),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
                      );
                      if (result == true && mounted) {
                        await _fetchData();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: iconColor.withAlpha(38),
                                child: Icon(iconData, color: iconColor, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(
                                  event.category,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: iconColor.withAlpha(51),
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                              )
                            ],
                          ),
                          const Divider(height: 20),
                          _buildInfoRow(Icons.calendar_today, event.startDate),
                          const SizedBox(height: 6),
                          _buildInfoRow(Icons.location_on, event.location),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoRow(
                                Icons.people_outline,
                                '${event.currentParticipants} / ${event.maxParticipants} Peserta',
                              ),
                              Text(
                                isEventFull ? 'PENUH' : 'TERSEDIA',
                                style: GoogleFonts.poppins(
                                  color: isEventFull ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (context) => const CreateEventScreen()),
          );
          if (result == true && mounted) {
            await _fetchData();
          }
        },
        tooltip: 'Buat Event Baru',
        backgroundColor: Theme.of(context).colorScheme.primary,
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
            accountName: Text(authProvider.user?.name ?? 'Guest', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text(authProvider.user?.email ?? '', style: GoogleFonts.poppins()),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                authProvider.user?.name.isNotEmpty == true ? authProvider.user!.name[0] : 'G',
                style: TextStyle(fontSize: 40.0, color: Theme.of(context).colorScheme.primary),
              ),
            ),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Semua Event'),
            selected: _selectedIndex == 0,
            selectedTileColor: Colors.black.withAlpha(12),
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.my_library_books_outlined),
            title: const Text('Event Saya'),
            selected: _selectedIndex == 1,
            selectedTileColor: Colors.black.withAlpha(12),
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
        const SizedBox(width: 8),
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
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
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
