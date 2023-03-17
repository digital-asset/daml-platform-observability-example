CREATE ROLE canton WITH PASSWORD 'supersafe' LOGIN;
CREATE DATABASE mydomain OWNER canton;
CREATE DATABASE participant1 OWNER canton;
CREATE DATABASE jsonapi OWNER canton;
