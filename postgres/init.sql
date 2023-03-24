ALTER SYSTEM SET max_connections = 1000;
CREATE ROLE canton WITH PASSWORD 'supersafe' LOGIN;
CREATE DATABASE mydomain OWNER canton;
CREATE DATABASE participant1 OWNER canton;
CREATE DATABASE http_json OWNER canton;
CREATE DATABASE trigger_service OWNER canton;
