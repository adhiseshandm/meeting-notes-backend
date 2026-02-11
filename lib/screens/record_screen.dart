import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';

import 'package:file_picker/file_picker.dart';

class RecordScreen extends StatefulWidget {
  static const routeName = '/record';
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;
  List<String> _selectedFiles = [];

  void _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'png'],
    );

    if (result != null) {
       setState(() {
        _selectedFiles = result.paths.whereType<String>().toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      // Explicitly request permission
      var status = await Permission.microphone.status;
      if (status.isDenied) {
        status = await Permission.microphone.request();
      }

      if (status.isGranted) {
        bool available = await _speech.initialize(
          onStatus: (val) {
            debugPrint('onStatus: $val');
            if (!mounted) return;
            if (val == 'done' || val == 'notListening') {
              setState(() => _isListening = false);
            }
          },
          onError: (val) {
             debugPrint('onError: $val');
             if (!mounted) return;
             setState(() {
               _isListening = false;
               if (val.errorMsg == 'error_speech_timeout') {
                 // specific handling for timeout - don't show as a scary error, just stop.
                 // optionally we could show a snackbar saying "Stopped due to silence"
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listening stopped due to silence')));
               } else {
                 _text = 'Error: ${val.errorMsg}';
               }
             });
          },
        );
        if (!mounted) return;
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) {
              if (!mounted) return;
              setState(() {
                _text = val.recognizedWords;
                if (val.hasConfidenceRating && val.confidence > 0) {
                  _confidence = val.confidence;
                }
              });
            },
            listenFor: const Duration(seconds: 60),
            pauseFor: const Duration(seconds: 10),
            listenOptions: stt.SpeechListenOptions(
              partialResults: true,
              cancelOnError: true,
              listenMode: stt.ListenMode.dictation,
            ),
          );
        } else {
          setState(() {
            _isListening = false;
            _text = 'Speech recognition not available on this device';
          });
        }
      } else {
         if (!mounted) return;
         setState(() {
            _text = 'Microphone permission denied';
          });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _saveNote() async {
    if (_text.isNotEmpty &&
        _text != 'Press the button and start speaking' &&
        _text != 'Speech recognition not available') {
      
      String? title = await showDialog<String>(
        context: context,
        builder: (context) {
          String tempTitle = '';
          return AlertDialog(
            title: const Text('Enter Note Title'),
            content: TextField(
              onChanged: (value) => tempTitle = value,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, tempTitle),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (title != null && title.isNotEmpty) {
        if (!mounted) return;
        Provider.of<NotesProvider>(context, listen: false)
            .addNote(title, _text, null, _selectedFiles);
        Navigator.of(context).pop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save empty note')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Recording (${(_confidence * 100.0).toStringAsFixed(0)}%)',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6750A4),
              const Color(0xFFE91E63).withValues(alpha: 0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    _text,
                    style: const TextStyle(
                      fontSize: 22.0,
                      color: Color(0xFF1C1B1F),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 50, top: 20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _listen,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _isListening ? 100 : 80,
                      width: _isListening ? 100 : 80,
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.redAccent : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? Colors.redAccent : Colors.white).withValues(alpha: 0.5),
                            blurRadius: _isListening ? 30 : 10,
                            spreadRadius: _isListening ? 10 : 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        color: _isListening ? Colors.white : const Color(0xFF6750A4),
                        size: _isListening ? 40 : 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_text.isNotEmpty && !_isListening && _text != 'Press the button and start speaking')
                    Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickFiles,
                          icon: const Icon(Icons.attach_file),
                          label: Text(_selectedFiles.isEmpty ? 'Attach Files' : '${_selectedFiles.length} files attached'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6750A4),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _saveNote,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Note'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6750A4),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ],
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
