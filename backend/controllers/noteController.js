const Note = require('../models/Note');

// Get all notes for the logged-in user
exports.getNotes = async (req, res) => {
    try {
        const notes = await Note.find({ createdBy: req.userId }).sort({ createdAt: -1 });
        res.status(200).json(notes);
    } catch (error) {
        res.status(500).json({ message: "Something went wrong", error });
    }
};

// Create a new note
exports.createNote = async (req, res) => {
    try {
        const { title, content, audioUrl } = req.body;

        let attachments = [];
        if (req.files) {
            // Replace backslashes with forward slashes for URL compatibility
            attachments = req.files.map(file => file.path.replace(/\\/g, '/'));
        }

        const newNote = new Note({
            title,
            content,
            audioUrl,
            attachments,
            createdBy: req.userId,
            createdAt: new Date()
        });
        await newNote.save();
        res.status(201).json(newNote);
    } catch (error) {
        res.status(500).json({ message: "Something went wrong", error });
    }
};

// Delete a note
exports.deleteNote = async (req, res) => {
    try {
        const mongoose = require('mongoose');
        const { id } = req.params;
        
        console.log(`[Server] DELETE REQUEST: ID=${id}, User=${req.userId}`);

        if (!mongoose.Types.ObjectId.isValid(id)) {
            console.log(`[Server] Invalid ID format: ${id}`);
            return res.status(400).json({ message: "Invalid ID format" });
        }

        // Explicitly cast to ObjectId
        const noteId = new mongoose.Types.ObjectId(id);
        const userId = new mongoose.Types.ObjectId(req.userId);

        const deletedNote = await Note.findOneAndDelete({ _id: noteId, createdBy: userId });
        
        if (!deletedNote) {
            console.log(`[Server] Note not found or permission denied: ${id}`);
            return res.status(404).json({ message: "Note not found or you don't have permission" });
        }
        
        console.log(`[Server] SUCCESS: Note ${id} deleted`);
        res.status(200).json({ message: "Note deleted successfully" });
    } catch (error) {
        console.error("[Server] Critical Delete Error:", error);
        res.status(500).json({ message: "Something went wrong", error: error.message });
    }
};

// Update an existing note
exports.updateNote = async (req, res) => {
    try {
        const { id } = req.params;
        const { title, content } = req.body;
        
        // Find the note and ensure it belongs to the logged-in user
        const note = await Note.findOneAndUpdate(
            { _id: id, createdBy: req.userId },
            { title, content },
            { new: true } // return updated document
        );

        if (!note) {
            return res.status(404).json({ message: "Note not found or unauthorized." });
        }

        res.status(200).json(note);
    } catch (error) {
        res.status(500).json({ message: "Something went wrong", error });
    }
};
