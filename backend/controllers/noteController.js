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
            attachments = req.files.map(file => file.path);
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
        const { id } = req.params;
        await Note.findByIdAndRemove(id);
        res.status(200).json({ message: "Note deleted successfully" });
    } catch (error) {
        res.status(500).json({ message: "Something went wrong", error });
    }
};
