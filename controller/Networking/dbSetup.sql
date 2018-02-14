-- -------
-- SETUP THE NETWORKING IN CONTROLLER NODE
-- --------


-- Create db
CREATE DATABASE neutron;

GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' \
  IDENTIFIED BY 'letmein';

GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' \
  IDENTIFIED BY 'letmein';
