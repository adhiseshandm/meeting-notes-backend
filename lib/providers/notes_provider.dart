import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/note_model.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> fetchNotes() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> response = await _apiService.get('/notes');
      _notes = response.map((json) => Note.fromMap(json)).toList();
    } catch (error) {
      print('Error fetching notes: $error');
      // Handle error accordingly (maybe set an error state)
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(String title, String content, String? audioUrl, List<String> filePaths) async {
    try {
      if (filePaths.isEmpty) {
        await _apiService.post('/notes', {
          'title': title,
          'content': content,
          'audioUrl': audioUrl,
        });
      } else {
        await _apiService.postMultipart('/notes', {
          'title': title,
          'content': content,
          if (audioUrl != null) 'audioUrl': audioUrl,
        }, filePaths);
      }
      await fetchNotes();
    } catch (error) {
      print('Error adding note: $error');
      throw error;
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _apiService.delete('/notes/$id');
      await fetchNotes();
    } catch (error) {
      print('Error deleting note: $error');
      throw error;
    }
  }
}
