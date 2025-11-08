-- Create nocodb user if it doesn't exist
DO $$
BEGIN
  CREATE ROLE nocodb_user WITH LOGIN PASSWORD 'INSERT_PASSWORD_HERE' CREATEDB; -- Replace INSERT_PASSWORD_HERE with actual password
EXCEPTION WHEN duplicate_object THEN
  ALTER ROLE nocodb_user WITH PASSWORD 'INSERT_PASSWORD_HERE'; -- Replace INSERT_PASSWORD_HERE with actual password
END $$;

-- Create nocodb database if it doesn't exist
SELECT 'CREATE DATABASE nocodb' WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'nocodb')\gexec

-- Grant permissions on the nocodb database
GRANT ALL PRIVILEGES ON DATABASE nocodb TO nocodb_user;
ALTER DATABASE nocodb OWNER TO nocodb_user;

-- Now grant schema permissions explicitly
REVOKE CREATE ON SCHEMA public FROM public;
GRANT CREATE ON SCHEMA public TO nocodb_user;
GRANT USAGE ON SCHEMA public TO nocodb_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO nocodb_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO nocodb_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO nocodb_user;