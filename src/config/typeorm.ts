import { registerAs } from "@nestjs/config";
import { config as dotenvConfig } from 'dotenv';
import { join } from 'node:path';
import { DataSource, type DataSourceOptions } from "typeorm";

dotenvConfig({ path: '.env' });

// Resolve relative to this file so paths work both from src (CLI, .ts) and dist (app, .js)
const srcRoot = join(import.meta.dirname, '..');
const ext = import.meta.filename.endsWith('.ts') ? 'ts' : 'js';

const config = {
    type: 'postgres',
    host: process.env.DATABASE_HOST,
    port: Number(process.env.DATABASE_PORT),
    username: process.env.DATABASE_USERNAME,
    password: process.env.DATABASE_PASSWORD,
    database: process.env.DATABASE_NAME,
    entities: [join(srcRoot, `**/*.entity.${ext}`)],
    migrations: [join(srcRoot, `migrations/*.${ext}`)],
    autoLoadEntities: true,
    synchronize: false,
}

export default registerAs('typeorm', () => config)
export const connectionSource = new DataSource(config as DataSourceOptions);
