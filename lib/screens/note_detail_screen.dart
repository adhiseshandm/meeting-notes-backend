import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notes_provider.dart';
import '../models/note_model.dart';

class NoteDetailScreen extends StatelessWidget {
  static const routeName = '/note-detail';
  const NoteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final noteId = ModalRoute.of(context)?.settings.arguments as String?;
    
    if (noteId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No note selected')),
      );
    }
    
    final note = Provider.of<NotesProvider>(context).notes.firstWhere(
      (note) => note.id == noteId,
      orElse: () => Note(title: 'Not Found', content: 'Note not found', dateTime: DateTime.now()),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(note.title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share feature coming soon!')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM dd, yyyy • hh:mm a').format(note.dateTime).toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                note.content,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 20),
              if (note.attachments.isNotEmpty) ...[
                const Text(
                  'Attachments:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                ...note.attachments.map((path) {
                  // Since we are running on emulator, localhost needs to be 10.0.2.2
                  // The backend returns 'uploads/filename'.
                  // We need to construct full URL.
                  final url = 'http://10.0.2.2:5000/$path'; 
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () {
                         // Open file logic (use url_launcher or similar if needed)
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File at: $url')));
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.attach_file, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(child: Text(path.split('/').last, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline))),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
