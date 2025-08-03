import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatelessWidget {
  final List<Map<String, String>> competitions = [
    {
      "title": "Data Science Challenge",
      "description": "Kompetisi analisis data dan machine learning tingkat mahasiswa.",
      "category": "Data Science",
      "date": "2025-09-10",
      "location": "Auditorium Kampus",
    },
    {
      "title": "UI/UX Design Sprint",
      "description": "Tantangan desain aplikasi dengan fokus pada pengalaman pengguna.",
      "category": "UI/UX",
      "date": "2025-09-12",
      "location": "Lab Multimedia",
    },
    {
      "title": "CyberHack Competition",
      "description": "Lomba keamanan siber tingkat nasional untuk mahasiswa.",
      "category": "CyberHack",
      "date": "2025-09-14",
      "location": "Cyber Lab",
    },
  ];

  Icon _getCategoryIcon(String? category) {
    switch (category) {
      case 'Data Science':
        return Icon(Icons.analytics, color: Colors.blueAccent);
      case 'UI/UX':
        return Icon(Icons.design_services, color: Colors.purple);
      case 'CyberHack':
        return Icon(Icons.security, color: Colors.redAccent);
      default:
        return Icon(Icons.event);
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Data Science':
        return Colors.blue[50]!;
      case 'UI/UX':
        return Colors.purple[50]!;
      case 'CyberHack':
        return Colors.red[50]!;
      default:
        return Colors.grey[100]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HackVerse Dashboard", style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: competitions.length,
        itemBuilder: (context, index) {
          final comp = competitions[index];
          return Card(
            color: _getCategoryColor(comp['category']),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.symmetric(vertical: 10),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _getCategoryIcon(comp["category"]),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          comp["title"] ?? "",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    comp["description"] ?? "",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                  ),
                  Divider(height: 20),
                  Row(
                    children: [
                      Icon(Icons.category, size: 16),
                      SizedBox(width: 5),
                      Text("Kategori: ${comp["category"]}", style: GoogleFonts.poppins(fontSize: 13)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16),
                      SizedBox(width: 5),
                      Text("Tanggal: ${comp["date"]}", style: GoogleFonts.poppins(fontSize: 13)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16),
                      SizedBox(width: 5),
                      Text("Lokasi: ${comp["location"]}", style: GoogleFonts.poppins(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
