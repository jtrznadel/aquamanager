// Database initialization utility
// This will run automatically when the backend starts

const fs = require('fs');
const path = require('path');

class DatabaseInitializer {
    constructor(dbClient) {
        this.client = dbClient;
    }

    async initialize() {
        try {
            console.log('🚀 Initializing database...');
            
            // Check if tables exist
            const tableCheck = await this.client.query(`
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name IN ('aquariums', 'fish', 'tasks')
            `);

            if (tableCheck.rows.length === 0) {
                console.log('📋 No tables found, creating database schema...');
                
                // Read and execute init script
                const initScript = fs.readFileSync(
                    path.join(__dirname, '../../../database/init_auto.sql'), 
                    'utf8'
                );
                
                await this.client.query(initScript);
                console.log('✅ Database initialized successfully!');
            } else {
                console.log('✅ Database already initialized');
            }
            
        } catch (error) {
            console.error('❌ Database initialization failed:', error);
            throw error;
        }
    }

    async healthCheck() {
        try {
            const result = await this.client.query('SELECT NOW()');
            console.log('💚 Database connection healthy:', result.rows[0].now);
            return true;
        } catch (error) {
            console.error('❌ Database health check failed:', error);
            return false;
        }
    }
}

module.exports = DatabaseInitializer;
