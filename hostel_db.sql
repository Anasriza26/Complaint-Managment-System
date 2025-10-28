-- --------------------------------------------------------
-- Database: hostel_db
-- --------------------------------------------------------
DROP DATABASE IF EXISTS hostel_db;
CREATE DATABASE hostel_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hostel_db;

-- --------------------------------------------------------
-- Table: admin_info
-- --------------------------------------------------------
CREATE TABLE `admin_info` (
  `admin_id` INT AUTO_INCREMENT PRIMARY KEY,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `password` VARCHAR(150) NOT NULL,
  `name` VARCHAR(150) NOT NULL,
  `phone_no` VARCHAR(15) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `admin_info` (`email`, `password`, `name`, `phone_no`)
VALUES ('admin.ahmed@iiitb.org', 'thanksiiitb', 'Ahmed Khan', '9876543210');

-- --------------------------------------------------------
-- Table: student_info
-- --------------------------------------------------------
CREATE TABLE `student_info` (
  `student_id` INT AUTO_INCREMENT PRIMARY KEY,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `password` VARCHAR(150) NOT NULL,
  `roll_no` VARCHAR(50) NOT NULL UNIQUE,
  `phone_no` VARCHAR(15) NOT NULL UNIQUE,
  `room_no` INT NOT NULL UNIQUE,
  `gender` ENUM('M','F') NOT NULL,
  `name` VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `student_info` (`email`, `password`, `roll_no`, `phone_no`, `room_no`, `gender`, `name`) VALUES
('student.fatima@iiitb.org', 'thanks123', 'MT2023001', '9876543210', 315, 'F', 'Fatima Khan'),
('student.omar@iiitb.org', 'thanks123', 'MT2023002', '9876543211', 316, 'M', 'Omar Ahmed'),
('student.aisha@iiitb.org', 'thanks123', 'MT2023003', '9876543212', 317, 'F', 'Aisha Siddiqui'),
('student.yusuf@iiitb.org', 'thanks123', 'MT2023004', '9876543213', 318, 'M', 'Yusuf Hassan');

-- --------------------------------------------------------
-- Table: handyman_info
-- --------------------------------------------------------
CREATE TABLE `handyman_info` (
  `handyman_id` INT AUTO_INCREMENT PRIMARY KEY,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `password` VARCHAR(150) NOT NULL,
  `name` VARCHAR(150) NOT NULL,
  `phone_no` VARCHAR(15) NOT NULL UNIQUE,
  `category` VARCHAR(30) NOT NULL,
  `slot1` INT DEFAULT 0,
  `slot2` INT DEFAULT 0,
  `slot3` INT DEFAULT 0,
  `issued` INT DEFAULT 0,
  `solved` INT DEFAULT 0,
  `today` INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Preload handymen (one per category at least)
INSERT INTO `handyman_info` (`email`, `password`, `name`, `phone_no`, `category`) VALUES
('handyman.ali@iiitb.org', 'thanks123', 'Mohammed Ali', '918882229991', 'Carpenter'),
('handyman.hussain@iiitb.org', 'thanks123', 'Hussain Ahmed', '918889991112', 'Electrician'),
('handyman.rahman@iiitb.org', 'thanks123', 'Abdul Rahman', '917282991112', 'Plumber'),
('hvac.ravi@iiitb.org', 'thanks123', 'Ravi Kumar', '919999000111', 'HVAC'),
('painter.suresh@iiitb.org', 'thanks123', 'Suresh Mehta', '919999000222', 'Painter'),
('cleaner.jaya@iiitb.org', 'thanks123', 'Jaya Singh', '919999000333', 'Cleaner'),
('pest.rahul@iiitb.org', 'thanks123', 'Rahul Verma', '919999000444', 'PestControl');

-- --------------------------------------------------------
-- Table: master_data
-- --------------------------------------------------------
CREATE TABLE `master_data` (
  `owner` VARCHAR(30) DEFAULT NULL,
  `handyman_category` VARCHAR(30) DEFAULT NULL,
  `equipment` VARCHAR(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `master_data` (`owner`, `handyman_category`, `equipment`) VALUES
('Hostel', 'Carpenter', 'Table'),
('Hostel', 'Carpenter', 'Chair'),
('Hostel', 'Carpenter', 'Cupboard'),
('Hostel', 'Carpenter', 'Door'),
('Hostel', 'Carpenter', 'Bed Frame'),
('Hostel', 'Carpenter', 'Wardrobe'),
('Hostel', 'Carpenter', 'Bookshelf'),
('Hostel', 'Carpenter', 'Drawer'),
('Hostel', 'Electrician', 'Fan'),
('Hostel', 'Electrician', 'Tubelight'),
('Hostel', 'Electrician', 'Regulator'),
('Hostel', 'Electrician', 'Switch'),
('Hostel', 'Electrician', 'Socket'),
('Hostel', 'Electrician', 'Ceiling Light Fixture'),
('Hostel', 'Plumber', 'Wash Basin'),
('Hostel', 'Plumber', 'Tap/Faucet'),
('Hostel', 'Plumber', 'Toilet Flush'),
('Hostel', 'Plumber', 'Water Pipe'),
('Hostel', 'Plumber', 'Shower'),
('Hostel', 'HVAC', 'Room AC'),
('Hostel', 'HVAC', 'Water Heater'),
('Hostel', 'Painter', 'Wall Paint'),
('Hostel', 'Painter', 'Door Varnish'),
('Hostel', 'Cleaner', 'Mattress Cleaning'),
('Hostel', 'Cleaner', 'Pest Control'),
('Hostel', 'PestControl', 'Rodent Trap'),
('Personnel', 'Electrician', 'Iron'),
('Personnel', 'Electrician', 'Kettle'),
('Personnel', 'Electrician', 'Heater'),
('Personnel', 'Electrician', 'Table Lamp'),
('Personnel', 'Electrician', 'Extension Cord'),
('Personnel', 'Plumber', 'Kitchen Sink Tap'),
('Personnel', 'Plumber', 'Bathroom Shower'),
('Personnel', 'Plumber', 'Water Filter Connection'),
('Personnel', 'Carpenter', 'Study Table'),
('Personnel', 'Carpenter', 'Clothes Rack'),
('Personnel', 'Carpenter', 'Bedside Table'),
('Personnel', 'Painter', 'Room Wall Paint'),
('Personnel', 'Painter', 'Wood Polish'),
('Personnel', 'Cleaner', 'Floor Cleaning'),
('Personnel', 'Cleaner', 'Window Cleaning'),
('Personnel', 'Cleaner', 'Laundry Assistance'),
('Personnel', 'HVAC', 'Room Cooler'),
('Personnel', 'HVAC', 'Portable Heater'),
('Personnel', 'PestControl', 'Mosquito Spray'),
('Personnel', 'PestControl', 'Bed Bug Treatment');

-- --------------------------------------------------------
-- Table: complaint_info
-- --------------------------------------------------------
CREATE TABLE `complaint_info` (
  `complaint_id` INT AUTO_INCREMENT PRIMARY KEY,
  `student_id` INT NOT NULL,
  `handyman_id` INT DEFAULT NULL,
  `subject` VARCHAR(200) NOT NULL,
  `description` VARCHAR(500) DEFAULT NULL,
  `category` VARCHAR(30) DEFAULT NULL,
  `time_slot` VARCHAR(45) NOT NULL,
  `priority` INT DEFAULT 1,
  `flag` INT DEFAULT 0,
  `status` INT DEFAULT 0,
  `cost` INT DEFAULT 0,
  `date` DATETIME DEFAULT NULL,
  `rating` INT DEFAULT NULL,
  `feedback` VARCHAR(200) DEFAULT NULL,
  `otp` INT NOT NULL,
  `description_full` VARCHAR(500) DEFAULT '',
  `assign_date` DATETIME DEFAULT NULL,
  KEY `student_id_idx` (`student_id`),
  KEY `handyman_id_idx` (`handyman_id`),
  CONSTRAINT `complaint_student_fk` FOREIGN KEY (`student_id`) REFERENCES `student_info` (`student_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `complaint_handyman_fk` FOREIGN KEY (`handyman_id`) REFERENCES `handyman_info` (`handyman_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Table: feedback_info
-- --------------------------------------------------------
CREATE TABLE `feedback_info` (
  `feedback_id` INT AUTO_INCREMENT PRIMARY KEY,
  `complaint_id` INT NOT NULL,
  `student_id` INT NOT NULL,
  `handyman_id` INT DEFAULT NULL,
  `text` VARCHAR(250) NOT NULL,
  KEY `complaint_id_idx` (`complaint_id`),
  KEY `student_id_idx` (`student_id`),
  KEY `handyman_id_idx` (`handyman_id`),
  CONSTRAINT `feedback_complaint_fk` FOREIGN KEY (`complaint_id`) REFERENCES `complaint_info` (`complaint_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `feedback_student_fk` FOREIGN KEY (`student_id`) REFERENCES `student_info` (`student_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `feedback_handyman_fk` FOREIGN KEY (`handyman_id`) REFERENCES `handyman_info` (`handyman_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
