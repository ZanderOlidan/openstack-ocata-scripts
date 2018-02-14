-- SQL for KeyStone table setup

-- Create db
CREATE DATABASE keystone;

-- Grant Access
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'letmein';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'letmein';

