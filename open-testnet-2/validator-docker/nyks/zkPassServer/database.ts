// database.ts
import { Pool } from 'pg';

// Database configuration
const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'zkpassport',
  password: process.env.DB_PASSWORD || 'postgres',
  port: parseInt(process.env.DB_PORT || '5432'),
});

// Save verification data
export async function saveVerification(
  uniqueIdentifier: string,
  address: string | null,
) {
  try {
    const result = await pool.query(
      `INSERT INTO zkpass (address, identifier) 
       VALUES ($1, $2)`,
      [uniqueIdentifier, address]
    );
    
    return result.rows[0];
  } catch (error) {
    console.error('Error saving verification:', error);
    throw error;
  }
}

export { pool };
