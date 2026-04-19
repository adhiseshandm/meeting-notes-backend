const mongoose = require('mongoose');
const dns = require('dns');

// Force use of Google DNS to resolve Atlas SRV records
dns.setServers(['8.8.8.8', '8.8.4.4']);

// --- CONFIGURATION ---
const LOCAL_URI = 'mongodb://localhost:27017/meeting_notes_app';
const ATLAS_URI = 'mongodb+srv://adhiseshandm_db_user:fakeaccount9700@cluster0.eewbcew.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';

async function migrate() {
    let localConn, atlasConn;
    try {
        console.log('--- STARTING MIGRATION ---');

        // 1. Connect to Local
        localConn = await mongoose.createConnection(LOCAL_URI).asPromise();
        console.log('Connected to Local MongoDB');

        // 2. Connect to Atlas
        atlasConn = await mongoose.createConnection(ATLAS_URI).asPromise();
        console.log('Connected to Atlas MongoDB');

        // 3. Define Schemas (Must match the models)
        const UserSchema = new mongoose.Schema({
            username: String,
            email: { type: String, unique: true },
            password: { type: String, required: true },
            role: { type: String, default: 'user' }
        }, { strict: false });

        const NoteSchema = new mongoose.Schema({
            title: { type: String, required: true },
            content: { type: String, required: true },
            audioUrl: String,
            attachments: [String],
            createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
            dateTime: { type: Date, default: Date.now }
        }, { strict: false });

        const LocalUser = localConn.model('User', UserSchema);
        const LocalNote = localConn.model('Note', NoteSchema);
        
        const AtlasUser = atlasConn.model('User', UserSchema);
        const AtlasNote = atlasConn.model('Note', NoteSchema);

        // 4. Migrate Users
        const users = await LocalUser.find({});
        console.log(`Found ${users.length} users to migrate.`);
        if (users.length > 0) {
            // Use insertMany and bypass validation to preserve IDs
            await AtlasUser.deleteMany({}); // Clear existing to avoid conflicts
            await AtlasUser.insertMany(users);
            console.log('Users migrated successfully.');
        }

        // 5. Migrate Notes
        const notes = await LocalNote.find({});
        console.log(`Found ${notes.length} notes to migrate.`);
        if (notes.length > 0) {
            await AtlasNote.deleteMany({}); // Clear existing
            await AtlasNote.insertMany(notes);
            console.log('Notes migrated successfully.');
        }

        console.log('--- MIGRATION COMPLETE ---');

    } catch (error) {
        console.error('Migration failed:', error);
    } finally {
        if (localConn) await localConn.close();
        if (atlasConn) await atlasConn.close();
        process.exit(0);
    }
}

migrate();
