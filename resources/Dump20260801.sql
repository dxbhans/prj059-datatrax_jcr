-- MySQL dump 10.13  Distrib 8.0.34, for Win64 (x86_64)
--
-- Host: tthubdb-cluster-1.cluster-che9ka0taxng.eu-west-1.rds.amazonaws.com    Database: mezurit
-- ------------------------------------------------------
-- Server version	5.7.12

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '';

--
-- Table structure for table `_sensor_name_map`
--

DROP TABLE IF EXISTS `_sensor_name_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `_sensor_name_map` (
  `configuration_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `comment` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `map_array` varchar(1023) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`configuration_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `_station_configuration`
--

DROP TABLE IF EXISTS `_station_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `_station_configuration` (
  `configuration_id` int(11) NOT NULL AUTO_INCREMENT,
  `station_id` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `configuration_end` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Just a date. it will be local to the environmental monitoring station and relative to the sensor readings',
  `configuration_start` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `configuration_data` varchar(1024) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'No Configuration Available',
  PRIMARY KEY (`configuration_id`)
) ENGINE=InnoDB AUTO_INCREMENT=70 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `its_mezurit_alert_enablement`
--

DROP TABLE IF EXISTS `its_mezurit_alert_enablement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `its_mezurit_alert_enablement` (
  `enablement_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `change_authority` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'unknown',
  `enablement_action` enum('enable','disable') COLLATE utf8_unicode_ci DEFAULT NULL,
  `when_changed` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `mezurit_user_id` int(10) unsigned NOT NULL DEFAULT '0',
  `snapshot` varchar(4096) COLLATE utf8_unicode_ci NOT NULL,
  `success` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`enablement_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1552 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `its_mezurit_alert_log`
--

DROP TABLE IF EXISTS `its_mezurit_alert_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `its_mezurit_alert_log` (
  `alert_log_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `rule_dump_id` int(10) unsigned NOT NULL,
  `rule_set_id` int(10) unsigned NOT NULL,
  `conjoined_rule` tinyint(4) NOT NULL DEFAULT '0',
  `station_id` int(10) unsigned NOT NULL,
  `sensor_id` int(10) unsigned NOT NULL,
  `sensor_reading` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `condition_met_at` datetime DEFAULT NULL,
  `contact_detail` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `contact_method` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `alert_sent` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `sent_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `send_result` varchar(1024) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'OK',
  `confirm_result` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirm_at` datetime DEFAULT NULL,
  PRIMARY KEY (`alert_log_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1081813 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `its_mezurit_rule_dump`
--

DROP TABLE IF EXISTS `its_mezurit_rule_dump`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `its_mezurit_rule_dump` (
  `rule_dump_id` int(11) NOT NULL AUTO_INCREMENT,
  `rule_hash` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleted` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `rule_dump` text COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`rule_dump_id`),
  UNIQUE KEY `unique_hash` (`rule_hash`)
) ENGINE=InnoDB AUTO_INCREMENT=1134 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `its_mezurit_rule_meta`
--

DROP TABLE IF EXISTS `its_mezurit_rule_meta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `its_mezurit_rule_meta` (
  `rule_meta_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rule_dump_id` int(10) unsigned NOT NULL,
  `user_id` int(11) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleted` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`rule_meta_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1076 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='This table is not in current use. However, it has to exist in order for automated processes to not fail';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `its_mezurit_rule_notify`
--

DROP TABLE IF EXISTS `its_mezurit_rule_notify`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `its_mezurit_rule_notify` (
  `rule_notify_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rule_dump_id` int(10) unsigned NOT NULL,
  `user_id` int(11) NOT NULL,
  `local_timezone` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Europe/London',
  `contact_detail` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `contact_method` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleted` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`rule_notify_id`),
  KEY `index_rule_dump_id` (`rule_dump_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1563 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `its_mezurit_rule_schedule`
--

DROP TABLE IF EXISTS `its_mezurit_rule_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `its_mezurit_rule_schedule` (
  `rule_schedule_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rule_dump_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `days` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `start_time` time NOT NULL DEFAULT '00:00:00',
  `end_time` time NOT NULL DEFAULT '00:00:00',
  `start_date` date NOT NULL DEFAULT '0000-00-00',
  `end_date` date NOT NULL DEFAULT '0000-00-00',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleted` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`rule_schedule_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1078 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `its_mezurit_rule_set`
--

DROP TABLE IF EXISTS `its_mezurit_rule_set`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `its_mezurit_rule_set` (
  `rule_set_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rule_dump_id` int(10) unsigned NOT NULL,
  `user_id` int(11) NOT NULL,
  `station_id` int(10) unsigned NOT NULL,
  `client_station` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sensor_id` int(10) unsigned NOT NULL,
  `client_sensor` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sensor_units` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `condition_action` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `condition_value` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `condition_frequency` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `condition_conjunction` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `next_rule_id` int(11) NOT NULL DEFAULT '0',
  `condition_met` tinyint(4) NOT NULL DEFAULT '0',
  `condition_met_at` timestamp NULL DEFAULT NULL,
  `alert_inactive` tinyint(4) NOT NULL DEFAULT '0',
  `alert_enabled` tinyint(4) NOT NULL DEFAULT '1',
  `alert_sent` tinyint(8) NOT NULL DEFAULT '0',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleted` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`rule_set_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1353 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `its_mezurit_session`
--

DROP TABLE IF EXISTS `its_mezurit_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `its_mezurit_session` (
  `session_id` int(11) NOT NULL AUTO_INCREMENT,
  `system` enum('prod','unk','dev01','dev02') CHARACTER SET utf8 NOT NULL DEFAULT 'unk' COMMENT 'Iindicates which System made the insert: ',
  `actioned_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `action` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `php_session` varchar(26) COLLATE utf8_unicode_ci NOT NULL,
  `laissez_fare` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `expires` int(11) DEFAULT '-1',
  PRIMARY KEY (`session_id`),
  UNIQUE KEY `session_id_UNIQUE` (`session_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1179494 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_readings`
--

DROP TABLE IF EXISTS `station_readings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_readings` (
  `reading_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `station_id` int(10) unsigned NOT NULL,
  `reading_date` date NOT NULL,
  `reading_delta_time` mediumint(8) unsigned NOT NULL,
  `reading_epoch` int(10) unsigned DEFAULT NULL,
  `reading_count` smallint(5) unsigned NOT NULL,
  `not_live_data` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `is_simulation_data` tinyint(4) NOT NULL DEFAULT '0',
  `is_summary_data` tinyint(3) unsigned DEFAULT NULL,
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_00` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_01` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_02` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_03` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_04` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_05` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_06` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_07` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_08` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_09` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_10` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_11` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_12` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_13` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_14` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_15` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_16` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_17` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_18` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_19` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_20` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_21` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_22` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_23` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_24` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_25` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_26` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_27` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_28` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_29` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_30` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_31` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`reading_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_readings_delta`
--

DROP TABLE IF EXISTS `station_readings_delta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_readings_delta` (
  `delta_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `reading_id` int(10) unsigned NOT NULL,
  `station_id` int(10) unsigned NOT NULL,
  `reading_date` date NOT NULL,
  `reading_delta_time` mediumint(8) unsigned NOT NULL,
  `reading_epoch` int(10) unsigned DEFAULT NULL,
  `reading_count` smallint(5) unsigned NOT NULL,
  `not_live_data` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `is_simulation_data` tinyint(4) NOT NULL DEFAULT '0',
  `is_summary_data` tinyint(3) unsigned DEFAULT NULL,
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_00` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_01` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_02` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_03` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_04` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_05` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_06` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_07` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_08` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_09` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_10` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_11` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_12` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_13` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_14` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_15` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_16` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_17` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_18` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_19` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_20` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_21` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_22` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_23` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_24` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_25` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_26` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_27` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_28` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_29` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_30` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_31` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`delta_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `worker_cv`
--

DROP TABLE IF EXISTS `worker_cv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `worker_cv` (
  `worker_cv_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Auto-increment unique ID',
  `worker_cv_application` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'mezurit',
  `worker_cv_update` timestamp NULL DEFAULT NULL COMMENT 'Updated to reflect the time the entry was last modified.',
  `worker_cv_process_id` mediumint(9) DEFAULT '0' COMMENT 'The Host System Process ID of the Worker. This will be supplied by the Worker when it is registered',
  `worker_cv_activated` tinyint(1) unsigned DEFAULT '0' COMMENT 'On creation of a New Worker it will be set TRUE  by the Worker when it registers itself. On resuscitation it will be set TRUE by the Worker Monitor to "enable" the Worker. The default value is 0 "inactive"',
  `worker_cv_retired` tinyint(3) unsigned DEFAULT '0' COMMENT 'The Worker will set this when it is approaching its "end of life". There should be sufficient time for the Worker Monitor to initiate a request for a replacement.',
  `worker_cv_heartbeat` int(10) unsigned DEFAULT '0' COMMENT 'Countdown timer for the Worker. Each time the Worker completes a report cycle, this counter will be decremented. As it approaches zero, a replacement worker can be prepared. At zero, the Worker is maked for deletion. The default value is 0. See worker_cv_grace',
  `worker_cv_station_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'The ID of the Weather Station than the Worker wil cause (in combination witrh the senor id) to be monitored. The default value is 0, although it constrained by look up to the Hub Weather Station Id',
  `worker_cv_sensor_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'The ID of the Sensor than the Worker wil cause (in combination witrh the station id) to be monitored. The default value is 0, although it constrained by look up to the Hub Weather Station Id / configuration',
  `worker_cv_interval` int(10) unsigned DEFAULT '0' COMMENT 'The nominl ltime interval in micro seconds between Worker Reports. Essentially the maximum is expected to be aproximately 35 minutes (2147 seconds) with a minimum of 1 micro second. A value of 0 or a negative value will prevent the Worker from reporting.The Worker will not have the capability to continually report. The default value is 0',
  `worker_cv_created` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'The Date and Time the Worker was created. The default will be the time the record was created',
  `worker_cv_grace` smallint(5) unsigned DEFAULT '5' COMMENT 'A period of time that a Worker can be" inactive" and "expired" before it removal is forced. The default value is 0 seconds. The New Worker will determine a grace period based on its Interval time. Normally expected to be @5 seconds.',
  `worker_cv_dupdate` mediumint(6) unsigned DEFAULT '0' COMMENT 'Update delta time in milli seconds. The default is 0',
  `worker_cv_dcreate` mediumint(6) unsigned DEFAULT '0' COMMENT 'Create delta time in milli seconds. The default is 0',
  `worker_cv_exit_code` smallint(5) unsigned DEFAULT NULL COMMENT 'The Workers Exit Code, if available on its termination',
  `worker_cv_last_processed` varchar(45) CHARACTER SET utf8 DEFAULT NULL COMMENT 'A "text" copy of the last update and dupdat time. Provided by the Worker Report on receipt of a message from a worker.',
  PRIMARY KEY (`worker_cv_id`),
  UNIQUE KEY `id_worker_cv_UNIQUE` (`worker_cv_id`)
) ENGINE=InnoDB AUTO_INCREMENT=26401098 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Tracks the creation and activity of a Worker. An entry is created by the Worker Factory when it creates a Worker. The Worker will validate the entry on it''s first reporting run. On each Report Cycle the Worker will update its Heartbeat, which will also provide a "last update time". The Worker Monitor will use these to determine if a new Worker is required, an existing or stalled one should be terminated. When the Worker Reporter receives a message from the Worker it will record the time of receipt here - worker_cv_received';
/*!40101 SET character_set_client = @saved_cs_client */;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-01 19:12:34
-- MySQL dump 10.13  Distrib 8.0.34, for Win64 (x86_64)
--
-- Host: tthubdb-cluster-1.cluster-che9ka0taxng.eu-west-1.rds.amazonaws.com    Database: bha_api
-- ------------------------------------------------------
-- Server version	5.7.12

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '';

--
-- Table structure for table `bha_api_fixture_conditions`
--

DROP TABLE IF EXISTS `bha_api_fixture_conditions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bha_api_fixture_conditions` (
  `make_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fixture_hash` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `fixture_id` int(10) unsigned NOT NULL,
  `fixture_year` year(4) NOT NULL,
  `fixture_date` date NOT NULL,
  `course_id` int(11) NOT NULL,
  `course_name` varchar(512) CHARACTER SET utf8 NOT NULL,
  `going` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `ground` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `ground_comment` varchar(1024) COLLATE utf8_unicode_ci DEFAULT '',
  `ground_in_places` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `ground_in_places_comment` varchar(1024) COLLATE utf8_unicode_ci DEFAULT '',
  `going_stick` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `going_stick_value` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `going_stick_available` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `going_stick_updated_at` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `going_stick_comment` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `rails` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `stalls` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `weather` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `weather_comment` varchar(1024) COLLATE utf8_unicode_ci DEFAULT '',
  `other` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `inspection` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `inspected_at` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `inspection_comment` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `pre_cautionary_inspection` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `watering` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `watering_status` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `abandonment` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `abandoned_when` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `abandonment_comment` varchar(512) COLLATE utf8_unicode_ci DEFAULT '',
  `tt_processed` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`fixture_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bha_api_fixture_dump`
--

DROP TABLE IF EXISTS `bha_api_fixture_dump`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bha_api_fixture_dump` (
  `make_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date / Time downloaded',
  `fixture_hash` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `success` tinyint(1) DEFAULT NULL COMMENT 'True or false',
  `tt_processed` tinyint(1) unsigned DEFAULT '0',
  `count` tinyint(3) unsigned DEFAULT NULL COMMENT 'Count of Fixtures Data array',
  `data` longtext COLLATE utf8_unicode_ci COMMENT 'The Fixtures Data Array',
  PRIMARY KEY (`fixture_hash`),
  KEY `idx_make_date` (`make_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bha_api_fixture_races`
--

DROP TABLE IF EXISTS `bha_api_fixture_races`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bha_api_fixture_races` (
  `make_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `refresh_date` timestamp NULL DEFAULT NULL,
  `races_hash` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `fixture_id` int(11) NOT NULL,
  `race_id` int(11) unsigned NOT NULL,
  `year_of_race` year(4) DEFAULT NULL,
  `division_sequence` int(11) DEFAULT NULL,
  `race_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `race_distance_value` int(11) DEFAULT NULL,
  `race_distance_text` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `race_date` date DEFAULT NULL,
  `race_time` time DEFAULT NULL,
  `distance_change` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `abandonment` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `going` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `stalls` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`races_hash`,`race_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bha_api_fixture_tracks`
--

DROP TABLE IF EXISTS `bha_api_fixture_tracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bha_api_fixture_tracks` (
  `make_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `refresh_date` timestamp NULL DEFAULT NULL,
  `tracks_hash` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `fixture_id` int(11) NOT NULL,
  `track_id` int(11) unsigned NOT NULL,
  `race_type` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sub_track` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sub_course` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ground` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ground_in_places` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `going_stick` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `going_stick_available` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `going_stick_updated_at` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`tracks_hash`,`fixture_id`,`track_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bha_api_sent_reports`
--

DROP TABLE IF EXISTS `bha_api_sent_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bha_api_sent_reports` (
  `report_hash` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `course_id` int(11) DEFAULT NULL,
  `type` tinyint(3) unsigned DEFAULT NULL,
  `make_date` datetime DEFAULT NULL,
  `official_going` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL,
  `weather_comments` varchar(2048) COLLATE utf8_unicode_ci DEFAULT NULL,
  `track` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `stick_comments` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL,
  `stalls` varchar(2048) COLLATE utf8_unicode_ci DEFAULT NULL,
  `rails` varchar(2048) COLLATE utf8_unicode_ci DEFAULT NULL,
  `watering` varchar(2048) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` tinyint(3) unsigned DEFAULT NULL,
  `clerk_name` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `race_date` date DEFAULT NULL,
  `additional_comments` varchar(2048) COLLATE utf8_unicode_ci DEFAULT NULL,
  `abandoned` varchar(2048) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`report_hash`),
  UNIQUE KEY `report_hash_UNIQUE` (`report_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `bha_course_id`
--

DROP TABLE IF EXISTS `bha_course_id`;
/*!50001 DROP VIEW IF EXISTS `bha_course_id`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `bha_course_id` AS SELECT 
 1 AS `course_id`,
 1 AS `course_name`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `bha_going_stick`
--

DROP TABLE IF EXISTS `bha_going_stick`;
/*!50001 DROP VIEW IF EXISTS `bha_going_stick`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `bha_going_stick` AS SELECT 
 1 AS `make_date`,
 1 AS `bha_fixture_id`,
 1 AS `bha_course_id`,
 1 AS `bha_track_id`,
 1 AS `course_name`,
 1 AS `conditions_going_stick`,
 1 AS `conditions_going_stick_value`,
 1 AS `conditions_going_stick_available`,
 1 AS `tracks_going_stick_available`,
 1 AS `conditions_going_stick_update_at`,
 1 AS `tracks_going_stick_updated_at`,
 1 AS `conditions_going_stick_comment`,
 1 AS `bha_race_type`,
 1 AS `bha_sub_track`,
 1 AS `track_going_stick`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `bha_course_id`
--

/*!50001 DROP VIEW IF EXISTS `bha_course_id`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`turftrax`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `bha_course_id` AS select distinct `bha_api_fixture_conditions`.`course_id` AS `course_id`,`bha_api_fixture_conditions`.`course_name` AS `course_name` from `bha_api_fixture_conditions` order by `bha_api_fixture_conditions`.`course_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `bha_going_stick`
--

/*!50001 DROP VIEW IF EXISTS `bha_going_stick`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`turftrax`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `bha_going_stick` AS select `conditions`.`make_date` AS `make_date`,`conditions`.`fixture_id` AS `bha_fixture_id`,`conditions`.`course_id` AS `bha_course_id`,`tracks`.`track_id` AS `bha_track_id`,`conditions`.`course_name` AS `course_name`,`conditions`.`going_stick` AS `conditions_going_stick`,`conditions`.`going_stick_value` AS `conditions_going_stick_value`,`conditions`.`going_stick_available` AS `conditions_going_stick_available`,`tracks`.`going_stick_available` AS `tracks_going_stick_available`,`conditions`.`going_stick_updated_at` AS `conditions_going_stick_update_at`,`tracks`.`going_stick_updated_at` AS `tracks_going_stick_updated_at`,`conditions`.`going_stick_comment` AS `conditions_going_stick_comment`,`tracks`.`race_type` AS `bha_race_type`,`tracks`.`sub_track` AS `bha_sub_track`,`tracks`.`going_stick` AS `track_going_stick` from (`bha_api_fixture_conditions` `conditions` join `bha_api_fixture_tracks` `tracks` on((`conditions`.`fixture_id` = `tracks`.`fixture_id`))) order by `conditions`.`fixture_id` desc,`conditions`.`make_date` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-01 19:12:49
-- MySQL dump 10.13  Distrib 8.0.34, for Win64 (x86_64)
--
-- Host: tthubdb-cluster-1.cluster-che9ka0taxng.eu-west-1.rds.amazonaws.com    Database: emdb
-- ------------------------------------------------------
-- Server version	5.7.12

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '';

--
-- Table structure for table `data_content_audit`
--

DROP TABLE IF EXISTS `data_content_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `data_content_audit` (
  `audit_id` date NOT NULL COMMENT 'The Calendar Date',
  `audit_year` year(4) NOT NULL COMMENT 'The year component of the Date',
  `audit_month` tinyint(4) NOT NULL COMMENT 'The month component of the Date',
  `audit_day` tinyint(4) NOT NULL COMMENT 'The day component of the Date',
  `dlt_count` tinyint(4) NOT NULL DEFAULT '0',
  `wtx_count` tinyint(4) NOT NULL DEFAULT '0',
  `all_data` mediumint(8) unsigned NOT NULL DEFAULT '0' COMMENT 'A count of all Data Sets for this day',
  `60_second_data` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Data readings at 1 minute intervals. Traditionally WTX Live Data',
  `300_second_data` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Data readings at 5 minute intervals. Traditionally DLT Live Data',
  `1800_second_data` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '30 minute Summary Data',
  `3600_second_data` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '1 hour Summary Data',
  `14400_second_data` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '4 hour Summary Data',
  `21600_second_data` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '6 hour Summary Data',
  `43200_second_data` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '12 hour Summary Data',
  `86400_second_data` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Daily Summary Data',
  `refreshed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'The last time that the data sources were scanned for "updates"',
  `updated_at` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(4096) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'If there were any issues during the last Operation, an appropriate Message (JSON Object) should be  here',
  PRIMARY KEY (`audit_id`),
  KEY `idx_unique_key` (`audit_year`,`audit_month`,`audit_day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Provides a bottom line count of the data rows collected each day and, specifically, by sample frequency';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `data_content_coverage`
--

DROP TABLE IF EXISTS `data_content_coverage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `data_content_coverage` (
  `coverage_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Essentially just a sequence ID',
  `generic_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL COMMENT 'The original Terramet name for DLT Stations. I.e. the Ascot in wtx-Ascot (or the implied dlt-Ascot) etc. Something between the Station and Course Name. There will be weather stations that will not have a EMDB Location ID (HUB Course ID)',
  `station_tech` enum('other','dlt','wtx') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'other' COMMENT 'A list of Station Technolog: 0="other"; 1="dlt"; 2="wtx"',
  `data_store` enum('other','backoffice','terramet','emdb') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'other' COMMENT 'Where the data is: 0=other; 1=TT Servers; 2=Terramet Server; 3=EMDB)',
  `coverage_year` year(4) NOT NULL COMMENT 'The Calendar Year to which this applies',
  `leap_year` tinyint(3) unsigned NOT NULL COMMENT 'We actually want "0" or "1" ( True or False: Yes it is a leap year or no it isn''t). We are assuming that there are 365 days in a year and that we can just "add" this value to get 366 for a leap year',
  `60_second_coverage` decimal(6,1) unsigned NOT NULL DEFAULT '0.0' COMMENT 'Data readings at 1 minute intervals. Traditionally WTX Live Data\\\\\\\\n',
  `300_second_coverage` decimal(6,1) unsigned NOT NULL DEFAULT '0.0' COMMENT 'Data readings at 5 minute intervals. Traditionally DLT Live Data',
  `1800_second_coverage` decimal(6,1) unsigned NOT NULL DEFAULT '0.0' COMMENT '30 minute Summay Data - all Station Techs',
  `3600_second_coverage` decimal(6,1) unsigned NOT NULL DEFAULT '0.0' COMMENT '1 hour Summary Data - all Station Techs',
  `14400_second_coverage` decimal(6,1) unsigned NOT NULL DEFAULT '0.0' COMMENT '4 hour Summary Data - all Station Techs',
  `21600_second_coverage` decimal(6,1) unsigned NOT NULL DEFAULT '0.0' COMMENT '6 hour Summary Data - all Station Techs',
  `43200_second_coverage` decimal(6,1) unsigned NOT NULL DEFAULT '0.0' COMMENT '12 hour Summary Data - all Staion Techs',
  `86400_second_coverage` decimal(6,1) unsigned NOT NULL DEFAULT '0.0' COMMENT 'Daily Summary Data - all Station Techs',
  `dlt_integrity` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'With the DLT Station Tech: a percentage match of the data files with the dates.dat list: 100 full match; <100 less files than entries; >100 more entries than files',
  `wtx_integrity` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'To Be Determined',
  `refreshed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'The last time that the data sources were scanned for "updates"',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  `error_status` varchar(1023) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'If there was an Error during the last Operation, an appropriate Message should be displayed here',
  `store_meta` varchar(4095) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'This Should be a "pretty print" JSON Packet - details to be determined BUT entries should be appended / merged',
  PRIMARY KEY (`coverage_id`),
  UNIQUE KEY `idx_unique_key` (`generic_name`,`station_tech`,`data_store`,`coverage_year`),
  KEY `idx_generic_name` (`generic_name`),
  KEY `idx_station_tech` (`station_tech`),
  KEY `idx_data_store` (`data_store`)
) ENGINE=InnoDB AUTO_INCREMENT=1144 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Details what weather data we have and where but limited to coverage per year';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `data_map`
--

DROP TABLE IF EXISTS `data_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `data_map` (
  `reading_date` date NOT NULL,
  `station_id` mediumint(8) unsigned NOT NULL,
  `year_month` decimal(6,0) NOT NULL,
  `live` mediumint(8) unsigned DEFAULT NULL,
  `summary_60` mediumint(8) unsigned DEFAULT NULL,
  `summary_300` smallint(5) unsigned DEFAULT NULL,
  `summary_1800` tinyint(3) unsigned DEFAULT NULL,
  `diagnostic` mediumint(8) unsigned DEFAULT NULL,
  `simulation` mediumint(8) unsigned DEFAULT NULL,
  `development` mediumint(8) unsigned DEFAULT NULL,
  `modified` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`reading_date`,`station_id`),
  KEY `idx_primary` (`reading_date`,`station_id`),
  KEY `idx_station` (`station_id`),
  KEY `idx_era` (`year_month`),
  KEY `idx_station_era` (`station_id`,`year_month`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nec_station_readings`
--

DROP TABLE IF EXISTS `nec_station_readings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nec_station_readings` (
  `reading_id` int(10) unsigned NOT NULL DEFAULT '0',
  `station_id` int(10) unsigned NOT NULL,
  `reading_date` date NOT NULL COMMENT 'Date (YYYY-MM-DD) - local to the recording Station, when the sensor readings were taken.',
  `reading_delta_time` mediumint(8) unsigned NOT NULL COMMENT 'Seconds since midnight (of local recording Station) when the sensor readings were taken.',
  `reading_epoch` int(10) unsigned DEFAULT NULL COMMENT 'Unix / Epoch equivalence of reading_date and reading_delta_time. This is mostly here to simplify time interval calculation etc.',
  `reading_count` smallint(5) unsigned NOT NULL COMMENT 'Number of sensor readings. Currently this is expected to be the same as the number of sensors attached to the Station.',
  `not_live_data` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'BOOLEAN: Default is 0 i.e. "no". Set to 1 if the Station was "in diagnostic mode" when the sensor readings were taken. Essentially: if set, then the sensor data will (should) be ignored by main stream applications.',
  `is_simulation_data` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT 'BOOLEAN: Default is 0 i.e. "no". Set to 1 if the sensor data is simulated (not real). This could be a "replay" of old data or completely random data. Either way, it should be ignored by main stream applications.',
  `is_summary_data` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'Default is 0 i.e. "no". Entered value should be the number of sensor readings that have been summarised.',
  `is_dev_data` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'The time, according to the DB Server, when the data record was written.',
  `update_date` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `dba_comment` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_00` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_01` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_02` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_03` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_04` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_05` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_06` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_07` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_08` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_09` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_10` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_11` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_12` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_13` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_14` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_15` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_16` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_17` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_18` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_19` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_20` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_21` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_22` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_23` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_24` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_25` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_26` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_27` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_28` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_29` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_30` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_31` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `raw_station_readings`
--

DROP TABLE IF EXISTS `raw_station_readings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `raw_station_readings` (
  `raw_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `station_id` int(10) unsigned NOT NULL,
  `reading_date` date NOT NULL COMMENT 'Date (YYYY-MM-DD) - local to the recording Station, when the sensor readings were taken.',
  `reading_delta_time` mediumint(8) unsigned NOT NULL COMMENT 'Seconds since midnight (of local recording Station) when the sensor readings were taken.',
  `reading_epoch` int(10) unsigned DEFAULT NULL COMMENT 'Unix / Epoch equivalence of reading_date and reading_delta_time. This is mostly here to simplify time interval calculation etc.',
  `reading_count` smallint(5) unsigned NOT NULL COMMENT 'Number of sensor readings. Currently this is expected to be the same as the number of sensors attached to the Station.',
  `not_live_data` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'BOOLEAN: Default is 0 i.e. "no". Set to 1 if the Station was "in diagnostic mode" when the sensor readings were taken. Essentially: if set, then the sensor data will (should) be ignored by main stream applications.',
  `is_simulation_data` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT 'BOOLEAN: Default is 0 i.e. "no". Set to 1 if the sensor data is simulated (not real). This could be a "replay" of old data or completely random data. Either way, it should be ignored by main stream applications.',
  `is_dev_data` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'The time, according to the DB Server, when the data record was written.',
  `update_date` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `dba_comment` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_00` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_01` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_02` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_03` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_04` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_05` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_06` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_07` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_08` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_09` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_10` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_11` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_12` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_13` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_14` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_15` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_16` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_17` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_18` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_19` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_20` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_21` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_22` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_23` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_24` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_25` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_26` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_27` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_28` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_29` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_30` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_31` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`raw_id`),
  UNIQUE KEY `unique_key` (`station_id`,`reading_date`,`reading_delta_time`,`not_live_data`,`is_simulation_data`,`is_dev_data`),
  KEY `idx_raw_station_readings_station_id` (`station_id`),
  KEY `idx_raw_station_readings_reading_date` (`reading_date`),
  KEY `idx_raw_station_readings_reading_epoch` (`reading_epoch`),
  KEY `idx_raw_station_readings_station_id_date` (`station_id`,`reading_date`),
  KEY `idx_raw_station_readings_station_id_epoch` (`station_id`,`reading_epoch`)
) ENGINE=InnoDB AUTO_INCREMENT=31871 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reading_update_audit`
--

DROP TABLE IF EXISTS `reading_update_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reading_update_audit` (
  `audit_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `reading_id` int(10) unsigned NOT NULL COMMENT 'The UID of the station_readings table that was modified',
  `data_channel` varchar(8) COLLATE utf8_unicode_ci NOT NULL COMMENT 'The Sensor Data Channel that was modified - data_00, data_1 etc',
  `data_value` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'The "new" Sensor Reading: NULL, "****", FLOAT (as STRING)',
  `when_changed` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `changed_by` varchar(45) COLLATE utf8_unicode_ci NOT NULL COMMENT 'The UID of the User making the change',
  PRIMARY KEY (`audit_id`),
  KEY `idx_audit_trace` (`reading_id`,`data_channel`)
) ENGINE=InnoDB AUTO_INCREMENT=14212 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Records an Audit Trail of changes made to sensor readings in the main station_readings table. If such changes are made via the Proceedure UpdateReading(), then this is done as part of that process';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sensor_name_map`
--

DROP TABLE IF EXISTS `sensor_name_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sensor_name_map` (
  `configuration_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `comment` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `map_array` varchar(1023) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`configuration_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_calculated`
--

DROP TABLE IF EXISTS `station_calculated`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_calculated` (
  `calculated_id` int(11) NOT NULL AUTO_INCREMENT,
  `station_id` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `configuration_end` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Just a date. it will be local to the environmental monitoring station and relative to the sensor readings',
  `configuration_start` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `configuration_data` varchar(1024) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'No Configuration Available',
  `configuration_sensor` varchar(8192) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'No Configuration Available',
  PRIMARY KEY (`calculated_id`)
) ENGINE=InnoDB AUTO_INCREMENT=115 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_configuration`
--

DROP TABLE IF EXISTS `station_configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_configuration` (
  `configuration_id` int(11) NOT NULL AUTO_INCREMENT,
  `station_id` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `configuration_end` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Just a date. it will be local to the environmental monitoring station and relative to the sensor readings',
  `configuration_start` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `configuration_data` varchar(1024) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'No Configuration Available',
  `configuration_sensor` varchar(8192) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'No Configuration Available' COMMENT 'JSON version of Station Configuration. NOTE: MUST BE STRINGIFIED "pretty print" breaks Workbench table editor',
  PRIMARY KEY (`configuration_id`),
  KEY `idx_station_id` (`station_id`),
  KEY `idx_configuration_start` (`configuration_start`),
  KEY `idx_configuration_end` (`configuration_end`),
  KEY `idx_configuration_era` (`configuration_start`,`configuration_end`),
  KEY `idx_relevant_config` (`station_id`,`configuration_end`)
) ENGINE=InnoDB AUTO_INCREMENT=198 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_information`
--

DROP TABLE IF EXISTS `station_information`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_information` (
  `information_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `station_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `alias_start` varchar(50) COLLATE utf8_unicode_ci DEFAULT '' COMMENT 'This attribute (when named "alias-list" seems to clash with that in the stations table. Based on the single entry, a date for flemington, the intention seems to be an attempt to record "when" the station was aliased. Renamed the coulmn to "alias_start". BOTH should be a csv list',
  `latitude` decimal(8,5) NOT NULL,
  `longitude` decimal(8,5) NOT NULL,
  `altitude` smallint(6) NOT NULL,
  `time_zone` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Europe/London',
  `local_time_zone` varchar(10) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'GMT',
  `time_zone_offset` smallint(6) NOT NULL DEFAULT '0',
  `live_interval` smallint(6) NOT NULL DEFAULT '300',
  `summary_interval` smallint(6) NOT NULL DEFAULT '1800',
  `update_delay` smallint(6) NOT NULL DEFAULT '3600',
  `active_time` varchar(11) COLLATE utf8_unicode_ci NOT NULL DEFAULT '07:00|18:00',
  `send_alert` tinyint(4) NOT NULL DEFAULT '1',
  `et_status` tinyint(4) NOT NULL DEFAULT '-1' COMMENT 'The ET Sataus / Capability of the EMM Station: -1 Not Eligible; 0 Eligible; 1 disabled',
  PRIMARY KEY (`information_id`),
  KEY `idx_et_status` (`et_status`)
) ENGINE=InnoDB AUTO_INCREMENT=131 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_monitor`
--

DROP TABLE IF EXISTS `station_monitor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_monitor` (
  `monitor_id` int(11) NOT NULL AUTO_INCREMENT,
  `station_id` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `enabled` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Boolean: TRUE - Monitor this Station, FALSE - Do not monitoer this Station',
  `configuration_end` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Just a date. it will be local to the environmental monitoring station and relative to the sensor readings',
  `configuration_start` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `simple_check` varchar(8192) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'No Configuration Available',
  `sensor_spectrum` varchar(8192) COLLATE utf8_unicode_ci NOT NULL DEFAULT '{}' COMMENT 'Which sensors to include for soensor spectrum testing, organised by "display groups". This may be left empty in order to have the default configuration used i.e. Station 0',
  PRIMARY KEY (`monitor_id`),
  KEY `idx_station_id` (`station_id`),
  KEY `idx_configuration_start` (`configuration_start`),
  KEY `idx_configuration_end` (`configuration_end`),
  KEY `idx_configuration_era` (`configuration_start`,`configuration_end`),
  KEY `idx_relevant_config` (`station_id`,`configuration_end`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_readings`
--

DROP TABLE IF EXISTS `station_readings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_readings` (
  `reading_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `station_id` int(10) unsigned NOT NULL,
  `reading_date` date NOT NULL COMMENT 'Date (YYYY-MM-DD) - local to the recording Station, when the sensor readings were taken.',
  `reading_delta_time` mediumint(8) unsigned NOT NULL COMMENT 'Seconds since midnight (of local recording Station) when the sensor readings were taken.',
  `reading_epoch` int(10) unsigned DEFAULT NULL COMMENT 'Unix / Epoch equivalence of reading_date and reading_delta_time. This is mostly here to simplify time interval calculation etc.',
  `reading_count` smallint(5) unsigned NOT NULL COMMENT 'Number of sensor readings. Currently this is expected to be the same as the number of sensors attached to the Station.',
  `not_live_data` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'BOOLEAN: Default is 0 i.e. "no". Set to 1 if the Station was "in diagnostic mode" when the sensor readings were taken. Essentially: if set, then the sensor data will (should) be ignored by main stream applications.',
  `is_simulation_data` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT 'BOOLEAN: Default is 0 i.e. "no". Set to 1 if the sensor data is simulated (not real). This could be a "replay" of old data or completely random data. Either way, it should be ignored by main stream applications.',
  `is_summary_data` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'Default is 0 i.e. "no". Entered value should be the number of sensor readings that have been summarised.',
  `is_dev_data` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'The time, according to the DB Server, when the data record was written.',
  `update_date` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `dba_comment` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_00` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_01` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_02` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_03` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_04` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_05` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_06` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_07` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_08` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_09` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_10` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_11` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_12` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_13` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_14` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_15` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_16` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_17` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_18` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_19` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_20` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_21` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_22` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_23` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_24` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_25` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_26` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_27` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_28` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_29` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_30` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_31` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`reading_id`),
  UNIQUE KEY `unique_key` (`station_id`,`reading_date`,`reading_delta_time`,`not_live_data`,`is_simulation_data`,`is_summary_data`,`is_dev_data`),
  KEY `idx_station_readings_station_id` (`station_id`),
  KEY `idx_sequence` (`reading_epoch`),
  KEY `idx_reading_date` (`reading_date`),
  KEY `idx_summary_data` (`is_summary_data`),
  KEY `idx_reading_epoch` (`reading_epoch`),
  KEY `idx_reading_date_reading_epoch` (`reading_date`,`reading_epoch`),
  KEY `idx_station_id_reading_epoch` (`station_id`,`reading_epoch`),
  KEY `idx_station_id_reading_date_live` (`station_id`,`reading_date`,`is_summary_data`),
  KEY `idx_reading_date_reading_delta` (`reading_date`,`reading_delta_time`),
  KEY `idx_data_flags` (`not_live_data`,`is_simulation_data`,`is_summary_data`,`is_dev_data`),
  KEY `idx_is_dev_data` (`is_dev_data`)
) ENGINE=InnoDB AUTO_INCREMENT=190076366 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_readings_audit`
--

DROP TABLE IF EXISTS `station_readings_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_readings_audit` (
  `audit_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `access_api` varchar(25) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'unknown',
  `station_id` int(10) unsigned NOT NULL,
  `entry_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `inserted_ok` smallint(6) NOT NULL DEFAULT '-1',
  `primary_key` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `redo_count` smallint(6) NOT NULL DEFAULT '0',
  `return_status` varchar(3) COLLATE utf8_unicode_ci DEFAULT NULL,
  `request_data` varchar(4096) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`audit_id`),
  KEY `idx_reading_audit_station` (`station_id`),
  KEY `idx_reading_audit_access` (`access_api`),
  KEY `idx_reading_audit_date` (`entry_date`),
  KEY `idx_reading_audit_insert` (`inserted_ok`)
) ENGINE=InnoDB AUTO_INCREMENT=77930323 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_readings_calculated`
--

DROP TABLE IF EXISTS `station_readings_calculated`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_readings_calculated` (
  `calculated_id` int(11) NOT NULL AUTO_INCREMENT,
  `reading_id` int(10) unsigned NOT NULL,
  `station_id` int(10) unsigned NOT NULL,
  `reading_date` date NOT NULL,
  `reading_delta_time` mediumint(8) unsigned NOT NULL,
  `reading_epoch` int(10) unsigned DEFAULT NULL,
  `reading_count` smallint(5) unsigned NOT NULL DEFAULT '0',
  `not_live_data` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `is_simulation_data` tinyint(4) unsigned NOT NULL DEFAULT '0',
  `is_summary_data` smallint(5) unsigned NOT NULL DEFAULT '0',
  `is_dev_data` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `dba_comment` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `calc_00` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `calc_01` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `calc_02` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `calc_03` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `calc_04` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `calc_05` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `calc_06` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `calc_07` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`calculated_id`),
  UNIQUE KEY `unique_key` (`station_id`,`reading_date`,`reading_delta_time`,`not_live_data`,`is_simulation_data`,`is_summary_data`,`is_dev_data`),
  KEY `idx_calculated_station_id` (`station_id`),
  KEY `idx_calculated_date_delta` (`reading_date`,`reading_delta_time`),
  KEY `idx_calculated_backref` (`reading_id`)
) ENGINE=InnoDB AUTO_INCREMENT=74048550 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_readings_delta`
--

DROP TABLE IF EXISTS `station_readings_delta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_readings_delta` (
  `delta_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `reading_id` int(10) unsigned NOT NULL,
  `station_id` int(10) unsigned NOT NULL,
  `reading_date` date NOT NULL,
  `reading_delta_time` mediumint(8) unsigned NOT NULL,
  `reading_epoch` int(10) unsigned DEFAULT NULL,
  `reading_count` smallint(5) unsigned NOT NULL,
  `not_live_data` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `is_simulation_data` tinyint(4) unsigned NOT NULL DEFAULT '0',
  `is_summary_data` smallint(5) unsigned NOT NULL DEFAULT '0',
  `is_dev_data` tinyint(4) NOT NULL DEFAULT '0',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_00` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_01` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_02` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_03` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_04` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_05` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_06` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_07` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_08` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_09` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_10` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_11` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_12` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_13` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_14` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_15` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_16` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_17` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_18` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_19` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_20` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_21` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_22` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_23` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_24` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_25` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_26` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_27` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_28` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_29` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_30` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_31` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`delta_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_readings_simulation`
--

DROP TABLE IF EXISTS `station_readings_simulation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_readings_simulation` (
  `reading_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `station_id` int(10) unsigned NOT NULL,
  `reading_date` date NOT NULL COMMENT 'Date (YYYY-MM-DD) - local to the recording Station, when the sensor readings were taken.',
  `reading_delta_time` mediumint(8) unsigned NOT NULL COMMENT 'Seconds since midnight (of local recording Station) when the sensor readings were taken.',
  `reading_epoch` int(10) unsigned DEFAULT NULL COMMENT 'Unix / Epoch equivalence of reading_date and reading_delta_time. This is mostly here to simplify time interval calculation etc.',
  `reading_count` smallint(5) unsigned NOT NULL COMMENT 'Number of sensor readings. Currently this is expected to be the same as the number of sensors attached to the Station.',
  `not_live_data` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'BOOLEAN: Default is 0 i.e. "no". Set to 1 if the Station was "in diagnostic mode" when the sensor readings were taken. Essentially: if set, then the sensor data will (should) be ignored by main stream applications.',
  `is_simulation_data` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT 'BOOLEAN: Default is 0 i.e. "no". Set to 1 if the sensor data is simulated (not real). This could be a "replay" of old data or completely random data. Either way, it should be ignored by main stream applications.',
  `is_summary_data` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'Default is 0 i.e. "no". Entered value should be the number of sensor readings that have been summarised.',
  `is_dev_data` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'The time, according to the DB Server, when the data record was written.',
  `update_date` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `dba_comment` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_00` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_01` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_02` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_03` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_04` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_05` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_06` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_07` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_08` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_09` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_10` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_11` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_12` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_13` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_14` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_15` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_16` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_17` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_18` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_19` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_20` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_21` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_22` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_23` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_24` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_25` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_26` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_27` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_28` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_29` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_30` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_31` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`reading_id`),
  UNIQUE KEY `unique_key` (`station_id`,`reading_date`,`reading_delta_time`,`not_live_data`,`is_simulation_data`,`is_summary_data`,`is_dev_data`),
  KEY `idx_sim_station_readings_station_id` (`station_id`),
  KEY `idx_sim_sequence` (`reading_epoch`),
  KEY `idx_sim_reading_date` (`reading_date`),
  KEY `idx_sim_summary_data` (`is_summary_data`),
  KEY `idx_sim_reading_epoch` (`reading_epoch`),
  KEY `idx_sim_reading_date_reading_epoch` (`reading_date`,`reading_epoch`),
  KEY `idx_sim_station_id_reading_epoch` (`station_id`,`reading_epoch`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_reprocess`
--

DROP TABLE IF EXISTS `station_reprocess`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_reprocess` (
  `reprocess_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `reprocess_exec` varchar(255) COLLATE utf8_unicode_ci NOT NULL COMMENT 'Full OS Path of the Processing Executable to be redone',
  `reprocess_station` int(10) unsigned NOT NULL COMMENT 'EMM Station ID to be re-processed',
  `reprocess_date` date NOT NULL COMMENT 'The Day to be re-processed',
  `reprocess_inprogress` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'This will be set by the "re-processor" when it starts to re-process the Weather Data',
  `reprocess_code` smallint(5) DEFAULT '-1' COMMENT 'Exit Code',
  `reprocess_message` varchar(1023) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Exit Message',
  `reprocess_request` datetime DEFAULT NULL COMMENT 'When the request was made',
  `reprocess_complete` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'When it was completed',
  `reprocess_initiator` varchar(255) COLLATE utf8_unicode_ci NOT NULL COMMENT 'Who initiated the Redo Request',
  `reprocess_error_email` enum('none','fail','create','all','sent','ack') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'none' COMMENT 'Whether on not an email should be sent: none=None;fail=If the re-processing fails; create=When the re-process was requested;all=All of the previous;sent=the email has been set; ack=The email has been acknowledged',
  `reprocess_ignore` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Indiates that the Request, successfully resolved or not, should be ignored for general purposes. Similar to being deleted',
  PRIMARY KEY (`reprocess_id`),
  UNIQUE KEY `idx_redo_unique` (`reprocess_exec`,`reprocess_station`,`reprocess_date`,`reprocess_inprogress`,`reprocess_complete`)
) ENGINE=InnoDB AUTO_INCREMENT=69938 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Acts as a Queue for the re-processing of Weather Data. Unprocessed requests will be "replaced" by by the most recently requested identical requests.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_type`
--

DROP TABLE IF EXISTS `station_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_type` (
  `station_type` int(11) NOT NULL,
  `reference_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(1024) COLLATE utf8_unicode_ci NOT NULL,
  `live_interval` smallint(6) NOT NULL DEFAULT '300',
  `summary_interval` smallint(6) NOT NULL DEFAULT '1800',
  `update_delay` smallint(6) NOT NULL DEFAULT '3600',
  PRIMARY KEY (`station_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_update_status`
--

DROP TABLE IF EXISTS `station_update_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_update_status` (
  `update_status_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `status_as_of` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `station_id` int(10) unsigned NOT NULL,
  `status_metric` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `current_status` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status_change` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `previous_status` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email_sent` varchar(19) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email_acknowledged` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`update_status_id`)
) ENGINE=InnoDB AUTO_INCREMENT=877 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stations`
--

DROP TABLE IF EXISTS `stations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stations` (
  `station_id` int(10) unsigned NOT NULL,
  `station_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `location_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Typically this would be the HUB Course ID. For legacy reasons EMM Stations were given an ID that matched the Course ID. Where this was not possible they were registered as a "course". A Location can have one or more EMM Stations performing similar or different roles.',
  `station_type` smallint(6) NOT NULL DEFAULT '-1',
  `alias_list` varchar(45) COLLATE utf8_unicode_ci DEFAULT '' COMMENT 'A CSV list of (histoic) EMM Station ID''s in the same location. An entry should only be made when an existing Station is replaced or significantly upgraded. ',
  `alternate_list` varchar(45) COLLATE utf8_unicode_ci DEFAULT '' COMMENT 'A CSV list of EMM Stations that can be used as alternates for each other. Ideally, they should have identical roles',
  `configuration_id` int(10) unsigned NOT NULL DEFAULT '0',
  `calculated_id` int(10) unsigned NOT NULL DEFAULT '0',
  `contact_id` int(10) unsigned NOT NULL DEFAULT '0',
  `information_id` int(10) unsigned NOT NULL DEFAULT '0',
  `monitor_id` int(10) unsigned NOT NULL DEFAULT '0',
  `simulation` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `diagnostic` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `active` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `decommissioned` smallint(6) NOT NULL DEFAULT '-1',
  `is_monitored` tinyint(1) NOT NULL DEFAULT '-1',
  `terramet` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `mobile` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `weathertrax_live` smallint(6) NOT NULL DEFAULT '0' COMMENT 'WeatherTrax Live Visualiser 0 = No, 1 = yes, -1 = Demo',
  PRIMARY KEY (`station_id`),
  UNIQUE KEY `station_id_UNIQUE` (`station_id`),
  UNIQUE KEY `station_name_UNIQUE` (`station_name`),
  KEY `idx_station_type` (`station_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='"Master" table for Environmental Monitoring Stations.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `temp_restore`
--

DROP TABLE IF EXISTS `temp_restore`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `temp_restore` (
  `reading_id` int(11) DEFAULT NULL,
  `data_17` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_18` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `unit_conversion`
--

DROP TABLE IF EXISTS `unit_conversion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `unit_conversion` (
  `conversion_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `category` set('speed','linear','angular','temperature','pressure','power','percent','other') COLLATE utf8_unicode_ci DEFAULT NULL,
  `conversion_list` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `conversion_matrix` varchar(1024) COLLATE utf8_unicode_ci DEFAULT '{}',
  PRIMARY KEY (`conversion_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `v_terramet_name`
--

DROP TABLE IF EXISTS `v_terramet_name`;
/*!50001 DROP VIEW IF EXISTS `v_terramet_name`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_terramet_name` AS SELECT 
 1 AS `station_name`,
 1 AS `location_id`,
 1 AS `terramet_name`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `v_terramet_name`
--

/*!50001 DROP VIEW IF EXISTS `v_terramet_name`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`turftrax`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_terramet_name` AS select `emdb`.`stations`.`station_name` AS `station_name`,`emdb`.`stations`.`location_id` AS `location_id`,`tthub`.`courses`.`terra_name` AS `terramet_name` from (`emdb`.`stations` left join `tthub`.`courses` on((`emdb`.`stations`.`location_id` = `tthub`.`courses`.`id`))) order by `emdb`.`stations`.`location_id`,`emdb`.`stations`.`station_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-01 19:13:28
-- MySQL dump 10.13  Distrib 8.0.34, for Win64 (x86_64)
--
-- Host: tthubdb-cluster-1.cluster-che9ka0taxng.eu-west-1.rds.amazonaws.com    Database: tthub
-- ------------------------------------------------------
-- Server version	5.7.12

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '';

--
-- Table structure for table `areas`
--

DROP TABLE IF EXISTS `areas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `areas` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `locale` varchar(3) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'en',
  PRIMARY KEY (`id`),
  UNIQUE KEY `areas_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `clerks`
--

DROP TABLE IF EXISTS `clerks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clerks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `course_id` int(10) unsigned NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `clerks_course_id_foreign` (`course_id`),
  CONSTRAINT `clerks_course_id_foreign` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=145 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `course_user`
--

DROP TABLE IF EXISTS `course_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_user` (
  `course_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`course_id`,`user_id`),
  KEY `course_user_user_id_foreign` (`user_id`),
  CONSTRAINT `course_user_course_id_foreign` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `course_user_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `courses` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `area_id` int(10) unsigned NOT NULL,
  `name` varchar(50) CHARACTER SET latin1 NOT NULL,
  `code` varchar(10) CHARACTER SET latin1 NOT NULL,
  `country` varchar(20) CHARACTER SET latin1 NOT NULL,
  `post_code` varchar(10) CHARACTER SET latin1 NOT NULL,
  `country_order` varchar(10) CHARACTER SET latin1 NOT NULL,
  `forecast_file` varchar(50) CHARACTER SET latin1 NOT NULL,
  `terra_name` varchar(50) CHARACTER SET latin1 NOT NULL,
  `special_code` varchar(50) CHARACTER SET latin1 NOT NULL,
  `accu_town` varchar(50) CHARACTER SET latin1 NOT NULL,
  `pa_code` varchar(50) CHARACTER SET latin1 NOT NULL,
  `is_all_weather` int(11) DEFAULT NULL,
  `alternative_name` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `csv_dial_times` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `no_maps` int(11) DEFAULT NULL,
  `show_days_in_adv` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `goingpage` varchar(100) CHARACTER SET latin1 DEFAULT NULL,
  `countryorder` varchar(100) CHARACTER SET latin1 DEFAULT NULL,
  `twitter_username` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `course_short_url` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `default_map_id` int(10) unsigned DEFAULT NULL,
  `logo_path` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `logo_banner_path` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `address` text CHARACTER SET latin1,
  `default_map_type` varchar(10) CHARACTER SET latin1 NOT NULL,
  `publicpage_weather_summary` tinyint(1) DEFAULT NULL,
  `publicpage_weather_graph` tinyint(1) DEFAULT NULL,
  `publicpage_weather_downloadcsv` tinyint(1) DEFAULT NULL,
  `publicpage_weather_forecast` tinyint(1) DEFAULT NULL,
  `publicpage_weather_requestupdate` tinyint(1) DEFAULT NULL,
  `publicpage_weather_et` tinyint(1) DEFAULT NULL,
  `publicpage_css` varchar(1000) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `courses_area_id_foreign` (`area_id`),
  KEY `courses_default_map_id_foreign` (`default_map_id`),
  KEY `courses_name` (`name`),
  CONSTRAINT `courses_area_id_foreign` FOREIGN KEY (`area_id`) REFERENCES `areas` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `courses_default_map_id_foreign` FOREIGN KEY (`default_map_id`) REFERENCES `maps` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=382 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `distribution`
--

DROP TABLE IF EXISTS `distribution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `distribution` (
  `course_id` int(10) unsigned NOT NULL,
  `notifiable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `notifiable_id` int(10) unsigned NOT NULL,
  `distribution_type` int(11) NOT NULL,
  KEY `course_recipients_group_course_id_foreign` (`course_id`),
  KEY `course_recipients_group_recipients_group_id_foreign` (`notifiable_id`),
  CONSTRAINT `course_recipients_group_course_id_foreign` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `emdbv_station_schedule`
--

DROP TABLE IF EXISTS `emdbv_station_schedule`;
/*!50001 DROP VIEW IF EXISTS `emdbv_station_schedule`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `emdbv_station_schedule` AS SELECT 
 1 AS `information_id`,
 1 AS `station_name`,
 1 AS `time_zone`,
 1 AS `local_time_zone`,
 1 AS `time_zone_offset`,
 1 AS `live_interval`,
 1 AS `summary_interval`,
 1 AS `update_delay`,
 1 AS `active_time`,
 1 AS `send_alert`,
 1 AS `station_id`,
 1 AS `station_type`,
 1 AS `active`,
 1 AS `decommissioned`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `emdbv_station_type`
--

DROP TABLE IF EXISTS `emdbv_station_type`;
/*!50001 DROP VIEW IF EXISTS `emdbv_station_type`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `emdbv_station_type` AS SELECT 
 1 AS `station_type`,
 1 AS `reference_name`,
 1 AS `description`,
 1 AS `live_interval`,
 1 AS `summary_interval`,
 1 AS `update_delay`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `emdbv_stations`
--

DROP TABLE IF EXISTS `emdbv_stations`;
/*!50001 DROP VIEW IF EXISTS `emdbv_stations`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `emdbv_stations` AS SELECT 
 1 AS `station_id`,
 1 AS `station_name`,
 1 AS `location_id`,
 1 AS `station_type`,
 1 AS `alias_list`,
 1 AS `configuration_id`,
 1 AS `calculated_id`,
 1 AS `contact_id`,
 1 AS `information_id`,
 1 AS `monitor_id`,
 1 AS `simulation`,
 1 AS `diagnostic`,
 1 AS `active`,
 1 AS `decommissioned`,
 1 AS `terramet`,
 1 AS `mobile`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `emm_event`
--

DROP TABLE IF EXISTS `emm_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emm_event` (
  `event_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique EMM Event ID',
  `user_id` int(10) unsigned NOT NULL COMMENT 'Hub User ID',
  `emm_event` int(10) unsigned NOT NULL DEFAULT '1' COMMENT 'One of a list of "defined events" - a Foriegn Key into table ...emm_event_list',
  `emm_context` varchar(128) DEFAULT NULL COMMENT 'Essentially the Station or Sensor affected etc',
  `occurred` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'When the Event occurred',
  `response` varchar(128) NOT NULL DEFAULT 'Unknown Response' COMMENT 'The response to an Event i.e. A request to exclude an EMM Station from Tes Monitoring was successful. Normally this would be a Status Code but a text response is possible. This may will be an "evolving" metric for the foreseeable future',
  `preserve_until` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'At time at which the Event will no longer be listed. The idea is to have some sort of "sunset rule" for Events. This may will be an "evolving" metric for the foreseeable future',
  PRIMARY KEY (`event_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_event` (`emm_event`),
  CONSTRAINT `fk_emm_event` FOREIGN KEY (`emm_event`) REFERENCES `emm_event_list` (`emm_event_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COMMENT='This Table will record EMM Station Events e.g. When an EMM Station was excluded from Test Monitoring; who excluded it; when it was excluded and if the exclusion was successful';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `emm_event_list`
--

DROP TABLE IF EXISTS `emm_event_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emm_event_list` (
  `emm_event_id` int(10) unsigned NOT NULL,
  `event_description` varchar(128) NOT NULL,
  KEY `idx_emm_event_list` (`emm_event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='A list of possible EMM Station Events';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `emmav_service_ttote`
--

DROP TABLE IF EXISTS `emmav_service_ttote`;
/*!50001 DROP VIEW IF EXISTS `emmav_service_ttote`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `emmav_service_ttote` AS SELECT 
 1 AS `ttote_id`,
 1 AS `ttote_token`,
 1 AS `ttote_code_base`,
 1 AS `ttote_request`,
 1 AS `ttote_response`,
 1 AS `ttote_parameters`,
 1 AS `ttote_created`,
 1 AS `ttote_ttl`,
 1 AS `ttote_expires`,
 1 AS `ttote_refreshes`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `events` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `target_id` int(10) unsigned NOT NULL,
  `target_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `event_type` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `data` text COLLATE utf8_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `events_user_id_foreign` (`user_id`),
  KEY `events_event_type_id_foreign` (`event_type`),
  CONSTRAINT `events_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=369820 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `forecast_locations`
--

DROP TABLE IF EXISTS `forecast_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `forecast_locations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `course_name` varchar(50) CHARACTER SET latin1 NOT NULL,
  `post_code` varchar(10) CHARACTER SET latin1 NOT NULL,
  `forecast_file` varchar(50) CHARACTER SET latin1 NOT NULL,
  `forecast_name` varchar(50) CHARACTER SET latin1 NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=303 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='For the Mezurit Weather Forecast Feature we need the postcode of the Weather Station in order to use the alternate Forecasting Service. Previously such a look-up used the Terramet Name as a filter but that field is "deleted" as a means to indicate that the station has been decommissioned (TT Backoffice legacy code).';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `going_changes`
--

DROP TABLE IF EXISTS `going_changes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `going_changes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `indexable_id` int(10) unsigned NOT NULL,
  `indexable_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `going_report_id` int(10) unsigned NOT NULL,
  `going_id` int(10) unsigned NOT NULL,
  `saved_by` int(10) unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `going_changes_indexable_id_indexable_type_index` (`indexable_id`,`indexable_type`),
  KEY `fk_going_changes_users` (`saved_by`),
  KEY `going_changes_going_report_id_foreign` (`going_report_id`),
  CONSTRAINT `fk_going_changes_users` FOREIGN KEY (`saved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `going_changes_going_report_id_foreign` FOREIGN KEY (`going_report_id`) REFERENCES `going_reports` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=964747 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `going_reports`
--

DROP TABLE IF EXISTS `going_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `going_reports` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned DEFAULT NULL,
  `map_id` int(10) unsigned NOT NULL,
  `make_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `official_going` varchar(1200) CHARACTER SET latin1 DEFAULT NULL,
  `additional_comments` varchar(1200) CHARACTER SET latin1 DEFAULT NULL,
  `weather_comments` varchar(1200) CHARACTER SET latin1 DEFAULT NULL,
  `stick_comments` varchar(1200) CHARACTER SET latin1 DEFAULT NULL,
  `archived` tinyint(1) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL,
  `type` tinyint(1) NOT NULL,
  `complete` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT 'ndicates Report is "ready to be Published" i.e. No more edits - the Report is Final. Added to provied a "Publish" alternative for Greyhound Reports that don''t need to be published in the classic HUB sense but still require something to trigger a next action - like nofifying that a Rport is available for "collection"',
  `clerk_name` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `waypoint_map` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `track` varchar(20) CHARACTER SET latin1 DEFAULT NULL,
  `zone_map` varchar(100) CHARACTER SET latin1 DEFAULT NULL,
  `race_date` date DEFAULT NULL,
  `abandoned` tinyint(1) NOT NULL DEFAULT '0',
  `uploaded_map` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `watering` varchar(1200) CHARACTER SET latin1 DEFAULT NULL,
  `rails` varchar(1200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `stalls` varchar(1200) CHARACTER SET latin1 DEFAULT NULL,
  `version` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `default_map` varchar(255) CHARACTER SET latin1 NOT NULL,
  `pdf_path` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `meeting_description` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `pdf_created` timestamp NULL DEFAULT NULL COMMENT 'When the PDF was last created - should be the" last save"',
  PRIMARY KEY (`id`),
  KEY `going_reports_course_id_foreign` (`map_id`),
  KEY `going_reports_user_id_foreign` (`user_id`),
  KEY `going_reports_race_date_index` (`race_date`),
  KEY `going_reports_type_index` (`type`),
  CONSTRAINT `going_reports_map_id_foreign` FOREIGN KEY (`map_id`) REFERENCES `maps` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `going_reports_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=341030 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `goings`
--

DROP TABLE IF EXISTS `goings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `goings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `color` varchar(20) CHARACTER SET utf8 NOT NULL,
  `min` decimal(4,2) DEFAULT NULL,
  `max` decimal(4,2) DEFAULT NULL,
  `label` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  `goings_group_id` int(10) unsigned NOT NULL,
  `order` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_goings_goings_groups_id` (`goings_group_id`),
  CONSTRAINT `fk_goings_goings_groups_id` FOREIGN KEY (`goings_group_id`) REFERENCES `goings_groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=914 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `goings_groups`
--

DROP TABLE IF EXISTS `goings_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `goings_groups` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `label` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `uploaded_legend_path` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=127 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `maps`
--

DROP TABLE IF EXISTS `maps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `maps` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `course_id` int(10) unsigned NOT NULL,
  `label` varchar(60) COLLATE utf8_unicode_ci NOT NULL,
  `path` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `goings_group_id` int(10) unsigned NOT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `maps_course_id_foreign` (`course_id`),
  KEY `fk_maps_goings_groups_id` (`goings_group_id`),
  CONSTRAINT `fk_maps_goings_groups_id` FOREIGN KEY (`goings_group_id`) REFERENCES `goings_groups` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `maps_course_id_foreign` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=867 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `meetings`
--

DROP TABLE IF EXISTS `meetings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meetings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `course_id` int(10) unsigned NOT NULL,
  `race_date` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `migration` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `recipient_recipients_group`
--

DROP TABLE IF EXISTS `recipient_recipients_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recipient_recipients_group` (
  `recipient_id` int(10) unsigned NOT NULL,
  `recipients_group_id` int(10) unsigned NOT NULL,
  KEY `recipient_recipients_group_recipient_id_foreign` (`recipient_id`),
  KEY `recipient_recipients_group_recipients_group_id_foreign` (`recipients_group_id`),
  CONSTRAINT `recipient_recipients_group_recipient_id_foreign` FOREIGN KEY (`recipient_id`) REFERENCES `recipients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `recipient_recipients_group_recipients_group_id_foreign` FOREIGN KEY (`recipients_group_id`) REFERENCES `recipients_groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `recipients`
--

DROP TABLE IF EXISTS `recipients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recipients` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `recipients_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3861 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `recipients_groups`
--

DROP TABLE IF EXISTS `recipients_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recipients_groups` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=149 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sections`
--

DROP TABLE IF EXISTS `sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sections` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `track_id` int(10) unsigned NOT NULL,
  `area` varchar(30) CHARACTER SET latin1 NOT NULL,
  `name` varchar(30) CHARACTER SET latin1 NOT NULL,
  `way_points` varchar(500) CHARACTER SET latin1 NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `sections_track_id_foreign` (`track_id`),
  CONSTRAINT `sections_track_id_foreign` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1554 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(10) CHARACTER SET latin1 NOT NULL,
  `report_id` int(10) unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `sessions_report_id_foreign` (`report_id`),
  CONSTRAINT `sessions_report_id_foreign` FOREIGN KEY (`report_id`) REFERENCES `going_reports` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stick_readings`
--

DROP TABLE IF EXISTS `stick_readings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stick_readings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `going_report_id` int(10) unsigned NOT NULL,
  `way_point` int(11) NOT NULL,
  `shear` decimal(5,2) NOT NULL,
  `penetrate` decimal(5,2) NOT NULL,
  `index` decimal(5,2) NOT NULL,
  `going` decimal(5,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stick_readings_going_report_id_way_point_unique` (`going_report_id`,`way_point`),
  KEY `stick_readings_going_report_id_foreign` (`going_report_id`),
  CONSTRAINT `stick_readings_going_report_id_foreign` FOREIGN KEY (`going_report_id`) REFERENCES `going_reports` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3741557 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tracks`
--

DROP TABLE IF EXISTS `tracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tracks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `map_id` int(10) unsigned NOT NULL,
  `name` varchar(50) CHARACTER SET latin1 NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `tracks_course_id_foreign` (`map_id`),
  CONSTRAINT `tracks_map_id_foreign` FOREIGN KEY (`map_id`) REFERENCES `maps` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=649 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `role_id` int(10) unsigned NOT NULL,
  `user` varchar(50) CHARACTER SET latin1 NOT NULL,
  `first_name` varchar(100) CHARACTER SET latin1 NOT NULL,
  `last_name` varchar(100) CHARACTER SET latin1 NOT NULL,
  `mobile` varchar(50) CHARACTER SET latin1 NOT NULL,
  `password` varchar(200) CHARACTER SET latin1 NOT NULL,
  `email` varchar(255) CHARACTER SET latin1 NOT NULL,
  `api_token` varchar(500) CHARACTER SET latin1 NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `remember_token` varchar(100) CHARACTER SET latin1 DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `tz` varchar(40) CHARACTER SET latin1 DEFAULT NULL,
  `weather_summary` tinyint(1) DEFAULT NULL,
  `weather_graph` tinyint(1) DEFAULT NULL,
  `weather_downloadcsv` tinyint(1) DEFAULT NULL,
  `weather_forecast` tinyint(1) DEFAULT NULL,
  `weather_requestupdate` tinyint(1) DEFAULT NULL,
  `weather_et` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_api_key_unique` (`api_token`),
  KEY `users_role_id_foreign` (`role_id`),
  CONSTRAINT `users_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=635 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `v_course_clerk_alerts`
--

DROP TABLE IF EXISTS `v_course_clerk_alerts`;
/*!50001 DROP VIEW IF EXISTS `v_course_clerk_alerts`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_course_clerk_alerts` AS SELECT 
 1 AS `course_id`,
 1 AS `course_name`,
 1 AS `email`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_course_country`
--

DROP TABLE IF EXISTS `v_course_country`;
/*!50001 DROP VIEW IF EXISTS `v_course_country`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_course_country` AS SELECT 
 1 AS `id`,
 1 AS `name`,
 1 AS `country`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_course_emm`
--

DROP TABLE IF EXISTS `v_course_emm`;
/*!50001 DROP VIEW IF EXISTS `v_course_emm`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_course_emm` AS SELECT 
 1 AS `course_id`,
 1 AS `course_name`,
 1 AS `dlt_station_id`,
 1 AS `wxt_station_id`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_course_maps`
--

DROP TABLE IF EXISTS `v_course_maps`;
/*!50001 DROP VIEW IF EXISTS `v_course_maps`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_course_maps` AS SELECT 
 1 AS `hub_map_id`,
 1 AS `hub_course_id`,
 1 AS `hub_course_name`,
 1 AS `hub_courses_country`,
 1 AS `hub_map_label`,
 1 AS `hub_map_path`,
 1 AS `hub_created_at`,
 1 AS `hub_updated_at`,
 1 AS `hub_deleted_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_course_maps_all`
--

DROP TABLE IF EXISTS `v_course_maps_all`;
/*!50001 DROP VIEW IF EXISTS `v_course_maps_all`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_course_maps_all` AS SELECT 
 1 AS `hub_map_id`,
 1 AS `hub_course_id`,
 1 AS `hub_course_name`,
 1 AS `hub_courses_country`,
 1 AS `hub_map_label`,
 1 AS `hub_map_path`,
 1 AS `hub_created_at`,
 1 AS `hub_updated_at`,
 1 AS `hub_deleted_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_distribution_list_full`
--

DROP TABLE IF EXISTS `v_distribution_list_full`;
/*!50001 DROP VIEW IF EXISTS `v_distribution_list_full`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_distribution_list_full` AS SELECT 
 1 AS `group_id`,
 1 AS `group_name`,
 1 AS `member_id`,
 1 AS `member_name`,
 1 AS `member_email`,
 1 AS `member_added`,
 1 AS `member_ammended`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_published_race_day`
--

DROP TABLE IF EXISTS `v_published_race_day`;
/*!50001 DROP VIEW IF EXISTS `v_published_race_day`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_published_race_day` AS SELECT 
 1 AS `map_id`,
 1 AS `course_id`,
 1 AS `race_date`,
 1 AS `abandoned`,
 1 AS `stick_version`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_racing_calendar`
--

DROP TABLE IF EXISTS `v_racing_calendar`;
/*!50001 DROP VIEW IF EXISTS `v_racing_calendar`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_racing_calendar` AS SELECT 
 1 AS `race_date`,
 1 AS `course_id`,
 1 AS `course_name`,
 1 AS `host_country`,
 1 AS `race_type`,
 1 AS `calendar_note`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_user_course_association`
--

DROP TABLE IF EXISTS `v_user_course_association`;
/*!50001 DROP VIEW IF EXISTS `v_user_course_association`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_user_course_association` AS SELECT 
 1 AS `user_id`,
 1 AS `hub_role`,
 1 AS `user_name`,
 1 AS `first_name`,
 1 AS `last_name`,
 1 AS `user_email`,
 1 AS `course_id`,
 1 AS `course_name`,
 1 AS `soft_deleted`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `venue_authority_lookup`
--

DROP TABLE IF EXISTS `venue_authority_lookup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `venue_authority_lookup` (
  `authority` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`authority`),
  UNIQUE KEY `authority_UNIQUE` (`authority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Lists available authorities for a given Venuecategories of "courses". I.e. A more formal type of sub-category that would have real world relevance in the context of the HUB e.g. bha, rvl or rq etc.  Authorities can be added as and when needed.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `venue_category_lookup`
--

DROP TABLE IF EXISTS `venue_category_lookup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `venue_category_lookup` (
  `category` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`category`),
  UNIQUE KEY `category_UNIQUE` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Lists available categories of "venues". I.e. A category that best describes the existence of an entry in (typically) the Hub Courses Table e.g. horseracing, weather station or testing etc. There are two issues: 1) anything added to the HUB NEEDS a Course ID 2) Going Stick readings can ONLY be uploaded to the HUB if there is a corresponding Course ID. Categories can be added as needed and are considered to be "significantly" differentiated. Sub-categories may be added at a later date.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `venue_meta`
--

DROP TABLE IF EXISTS `venue_meta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `venue_meta` (
  `venue_meta_id` int(10) unsigned NOT NULL COMMENT 'This should be 1:1 with tthub.course.id',
  `venue_meta_inactive` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Set if the Venue becomes inactive i.e. no longer managed via the HUB but is required for referencing etc',
  `venue_meta_category` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'other' COMMENT 'See Table venue_category_look_up',
  `venue_meta_authority` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'other' COMMENT 'E.g., BHA - essentially the Overseer / Rule Setter. See Table venue_authority_look_up',
  `venue_meta_group` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'other' COMMENT 'E.g., Jockey Club, ARC etc - Where a number of Venues are part of the same Organisation',
  `venue_meta_local` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'E.g., Brisbane Racing Club has two Venues: Eagle Farm and Doomben. They are also part of Racing Queensland',
  `venue_meta_region` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'other' COMMENT 'England, Scotland, New South Wales etc',
  `venue_meta_country` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'other' COMMENT 'This could be UK, Europe or Australia etc.',
  `venue_meta_name` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Local name for Venue',
  `venue_meta_hub_name` varchar(50) CHARACTER SET latin1 DEFAULT 'null' COMMENT 'Current TTHub Course Name',
  `venue_meta_alias` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Comma Separated List of previous or other local names',
  PRIMARY KEY (`venue_meta_id`),
  KEY `idx_venue_meta_category` (`venue_meta_category`),
  KEY `idx_venue_meta_authority` (`venue_meta_authority`),
  KEY `idx_venue_meta_hub_name` (`venue_meta_hub_name`),
  CONSTRAINT `fk_venue_authority_lookup` FOREIGN KEY (`venue_meta_authority`) REFERENCES `venue_authority_lookup` (`authority`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_venue_category_look_up` FOREIGN KEY (`venue_meta_category`) REFERENCES `venue_category_lookup` (`category`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Additional information comcerning entries in the Hub Courses Table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `waypoints`
--

DROP TABLE IF EXISTS `waypoints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `waypoints` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `map_id` int(10) unsigned NOT NULL,
  `svg_id` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  `value` smallint(5) unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `waypoints_map_id_foreign` (`map_id`),
  CONSTRAINT `waypoints_map_id_foreign` FOREIGN KEY (`map_id`) REFERENCES `maps` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=37596 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `weather_readings`
--

DROP TABLE IF EXISTS `weather_readings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `weather_readings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `course_id` int(10) unsigned NOT NULL,
  `weather_station_id` int(10) unsigned DEFAULT NULL,
  `make_date` datetime NOT NULL,
  `rg1_counter` decimal(15,6) DEFAULT NULL,
  `rg1_all` decimal(15,6) DEFAULT NULL,
  `rg2_counter` decimal(15,6) DEFAULT NULL,
  `rg2_all` decimal(15,6) DEFAULT NULL,
  `battery_volts` decimal(15,6) DEFAULT NULL,
  `battery_load` decimal(15,6) DEFAULT NULL,
  `solar_volts` decimal(15,6) DEFAULT NULL,
  `solar_load` decimal(15,6) DEFAULT NULL,
  `solar_w_m2` decimal(15,6) DEFAULT NULL,
  `wind_speed` decimal(15,6) DEFAULT NULL,
  `wind_gust` decimal(15,6) DEFAULT NULL,
  `wind_gust_max` decimal(15,6) DEFAULT NULL,
  `wind_direction` decimal(15,6) DEFAULT NULL,
  `air_temp` decimal(15,6) DEFAULT NULL,
  `humidity` decimal(15,6) DEFAULT NULL,
  `soil_moisture` decimal(15,6) DEFAULT NULL,
  `ground_temp` decimal(15,6) DEFAULT NULL,
  `soil_temp` decimal(15,6) DEFAULT NULL,
  `poly_temp` decimal(15,6) DEFAULT NULL,
  `other_temp` decimal(15,6) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `weather_readings_course_id_foreign` (`course_id`),
  KEY `weather_readings_weather_station_id_foreign` (`weather_station_id`),
  KEY `weather_readings_make_date_index` (`make_date`),
  CONSTRAINT `weather_readings_course_id_foreign` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `weather_readings_weather_station_id_foreign` FOREIGN KEY (`weather_station_id`) REFERENCES `weather_stations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16050754 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `weather_stations`
--

DROP TABLE IF EXISTS `weather_stations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `weather_stations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `terra_name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `course_id` int(10) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `weather_stations_course_id_foreign` (`course_id`),
  CONSTRAINT `weather_stations_course_id_foreign` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=170 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `zones`
--

DROP TABLE IF EXISTS `zones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `zones` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `map_id` int(10) unsigned NOT NULL,
  `way_points` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `zones_map_id_foreign` (`map_id`),
  CONSTRAINT `zones_map_id_foreign` FOREIGN KEY (`map_id`) REFERENCES `maps` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4003 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Final view structure for view `emdbv_station_schedule`
--

/*!50001 DROP VIEW IF EXISTS `emdbv_station_schedule`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`turftrax`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `emdbv_station_schedule` AS select `main`.`information_id` AS `information_id`,`main`.`station_name` AS `station_name`,`main`.`time_zone` AS `time_zone`,`main`.`local_time_zone` AS `local_time_zone`,`main`.`time_zone_offset` AS `time_zone_offset`,`main`.`live_interval` AS `live_interval`,`main`.`summary_interval` AS `summary_interval`,`main`.`update_delay` AS `update_delay`,`main`.`active_time` AS `active_time`,`main`.`send_alert` AS `send_alert`,`station`.`station_id` AS `station_id`,`station`.`station_type` AS `station_type`,`station`.`active` AS `active`,`station`.`decommissioned` AS `decommissioned` from (`emdb`.`station_information` `main` left join `tthub`.`emdbv_stations` `station` on((`main`.`information_id` = `station`.`information_id`))) order by `main`.`station_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `emdbv_station_type`
--

/*!50001 DROP VIEW IF EXISTS `emdbv_station_type`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`turftrax`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `emdbv_station_type` AS select `emdb`.`station_type`.`station_type` AS `station_type`,`emdb`.`station_type`.`reference_name` AS `reference_name`,`emdb`.`station_type`.`description` AS `description`,`emdb`.`station_type`.`live_interval` AS `live_interval`,`emdb`.`station_type`.`summary_interval` AS `summary_interval`,`emdb`.`station_type`.`update_delay` AS `update_delay` from `emdb`.`station_type` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `emdbv_stations`
--

/*!50001 DROP VIEW IF EXISTS `emdbv_stations`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`turftrax`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `emdbv_stations` AS select `emdb`.`stations`.`station_id` AS `station_id`,`emdb`.`stations`.`station_name` AS `station_name`,`emdb`.`stations`.`location_id` AS `location_id`,`emdb`.`stations`.`station_type` AS `station_type`,`emdb`.`stations`.`alias_list` AS `alias_list`,`emdb`.`stations`.`configuration_id` AS `configuration_id`,`emdb`.`stations`.`calculated_id` AS `calculated_id`,`emdb`.`stations`.`contact_id` AS `contact_id`,`emdb`.`stations`.`information_id` AS `information_id`,`emdb`.`stations`.`monitor_id` AS `monitor_id`,`emdb`.`stations`.`simulation` AS `simulation`,`emdb`.`stations`.`diagnostic` AS `diagnostic`,`emdb`.`stations`.`active` AS `active`,`emdb`.`stations`.`decommissioned` AS `decommissioned`,`emdb`.`stations`.`terramet` AS `terramet`,`emdb`.`stations`.`mobile` AS `mobile` from `emdb`.`stations` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `emmav_service_ttote`
--

/*!50001 DROP VIEW IF EXISTS `emmav_service_ttote`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`turftrax`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `emmav_service_ttote` AS select `emma`.`service_ttote`.`ttote_id` AS `ttote_id`,`emma`.`service_ttote`.`ttote_token` AS `ttote_token`,`emma`.`service_ttote`.`ttote_code_base` AS `ttote_code_base`,`emma`.`service_ttote`.`ttote_request` AS `ttote_request`,`emma`.`service_ttote`.`ttote_response` AS `ttote_response`,`emma`.`service_ttote`.`ttote_parameters` AS `ttote_parameters`,`emma`.`service_ttote`.`ttote_created` AS `ttote_created`,`emma`.`service_ttote`.`ttote_ttl` AS `ttote_ttl`,`emma`.`service_ttote`.`ttote_expires` AS `ttote_expires`,`emma`.`service_ttote`.`ttote_refreshes` AS `ttote_refreshes` from `emma`.`service_ttote` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_course_clerk_alerts`
--

/*!50001 DROP VIEW IF EXISTS `v_course_clerk_alerts`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`turftrax`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_course_clerk_alerts` AS select `clerks`.`course_id` AS `course_id`,`courses`.`name` AS `course_name`,`clerks`.`email` AS `email` from (`clerks` left join `courses` on((`clerks`.`course_id` = `courses`.`id`))) order by `courses`.`name`,`clerks`.`email` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_course_country`
--

/*!50001 DROP VIEW IF EXISTS `v_course_country`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`turftrax`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_course_country` AS select `courses`.`id` AS `id`,`courses`.`name` AS `name`,`courses`.`country` AS `country` from `courses` order by `courses`.`country` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_course_emm`
--

/*!50001 DROP VIEW IF EXISTS `v_course_emm`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`turftrax`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_course_emm` AS select `tthub`.`courses`.`id` AS `course_id`,`tthub`.`courses`.`name` AS `course_name`,(case when (`emdb`.`stations`.`station_type` < 4) then `emdb`.`stations`.`station_id` else '' end) AS `dlt_station_id`,(case when (`emdb`.`stations`.`station_type` >= 4) then `emdb`.`stations`.`station_id` else '' end) AS `wxt_station_id` from (`tthub`.`courses` left join `emdb`.`stations` on((`tthub`.`courses`.`id` = `emdb`.`stations`.`location_id`))) order by `tthub`.`courses`.`name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_course_maps`
--

/*!50001 DROP VIEW IF EXISTS `v_course_maps`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`turftrax`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_course_maps` AS select `maps`.`id` AS `hub_map_id`,`courses`.`id` AS `hub_course_id`,`courses`.`name` AS `hub_course_name`,`courses`.`country` AS `hub_courses_country`,`maps`.`label` AS `hub_map_label`,`maps`.`path` AS `hub_map_path`,`maps`.`created_at` AS `hub_created_at`,`maps`.`updated_at` AS `hub_updated_at`,`maps`.`deleted_at` AS `hub_deleted_at` from (`courses` left join `maps` on((`courses`.`id` = `maps`.`course_id`))) where ((`maps`.`id` = `courses`.`default_map_id`) or (`maps`.`path` <> '')) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_course_maps_all`
--

/*!50001 DROP VIEW IF EXISTS `v_course_maps_all`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`turftrax`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_course_maps_all` AS select `maps`.`id` AS `hub_map_id`,`courses`.`id` AS `hub_course_id`,`courses`.`name` AS `hub_course_name`,`courses`.`country` AS `hub_courses_country`,`maps`.`label` AS `hub_map_label`,`maps`.`path` AS `hub_map_path`,`maps`.`created_at` AS `hub_created_at`,`maps`.`updated_at` AS `hub_updated_at`,`maps`.`deleted_at` AS `hub_deleted_at` from (`courses` left join `maps` on((`courses`.`id` = `maps`.`course_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_distribution_list_full`
--

/*!50001 DROP VIEW IF EXISTS `v_distribution_list_full`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`turftrax`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_distribution_list_full` AS select `email_groups`.`recipients_group_id` AS `group_id`,`group_names`.`name` AS `group_name`,`email_list`.`id` AS `member_id`,`email_list`.`name` AS `member_name`,`email_list`.`email` AS `member_email`,`email_list`.`created_at` AS `member_added`,`email_list`.`updated_at` AS `member_ammended` from ((`recipients` `email_list` join `recipient_recipients_group` `email_groups`) join `recipients_groups` `group_names`) where ((`email_list`.`id` = `email_groups`.`recipient_id`) and (`group_names`.`id` = `email_groups`.`recipients_group_id`)) order by `group_names`.`name`,`email_list`.`name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_published_race_day`
--

/*!50001 DROP VIEW IF EXISTS `v_published_race_day`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`turftrax`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_published_race_day` AS select `going_reports`.`map_id` AS `map_id`,`v_course_maps_all`.`hub_course_id` AS `course_id`,`going_reports`.`race_date` AS `race_date`,`going_reports`.`abandoned` AS `abandoned`,`going_reports`.`version` AS `stick_version` from (`going_reports` left join `v_course_maps_all` on((`going_reports`.`map_id` = `v_course_maps_all`.`hub_map_id`))) where (`going_reports`.`status` = 1) group by `going_reports`.`race_date` order by `v_course_maps_all`.`hub_course_id`,`going_reports`.`map_id`,`going_reports`.`race_date` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_racing_calendar`
--

/*!50001 DROP VIEW IF EXISTS `v_racing_calendar`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`turftrax`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_racing_calendar` AS select `t_race_date`.`MeetingDate` AS `race_date`,`t_race_date`.`CourseId` AS `course_id`,`t_race_course`.`name` AS `course_name`,`t_race_course`.`country` AS `host_country`,`t_race_date`.`Code` AS `race_type`,`t_race_date`.`note` AS `calendar_note` from (`ttmaps`.`calendar` `t_race_date` join `tthub`.`courses` `t_race_course`) where (`t_race_date`.`CourseId` = `t_race_course`.`id`) order by `t_race_date`.`MeetingDate` desc,`t_race_date`.`CourseId` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_user_course_association`
--

/*!50001 DROP VIEW IF EXISTS `v_user_course_association`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`turftrax`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_user_course_association` AS select `course_user`.`user_id` AS `user_id`,`roles`.`name` AS `hub_role`,`users`.`user` AS `user_name`,`users`.`first_name` AS `first_name`,`users`.`last_name` AS `last_name`,`users`.`email` AS `user_email`,`course_user`.`course_id` AS `course_id`,`courses`.`name` AS `course_name`,`users`.`deleted_at` AS `soft_deleted` from (((`course_user` left join `users` on((`course_user`.`user_id` = `users`.`id`))) left join `courses` on((`course_user`.`course_id` = `courses`.`id`))) left join `roles` on((`users`.`role_id` = `roles`.`id`))) order by `users`.`last_name`,`users`.`first_name`,`courses`.`name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-01 19:14:44
-- MySQL dump 10.13  Distrib 8.0.34, for Win64 (x86_64)
--
-- Host: tthubdb-cluster-1.cluster-che9ka0taxng.eu-west-1.rds.amazonaws.com    Database: mezurit_new
-- ------------------------------------------------------
-- Server version	5.7.12

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '';

--
-- Table structure for table `cars`
--

DROP TABLE IF EXISTS `cars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cars` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cars_len` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx` (`cars_len`,`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contact_queries`
--

DROP TABLE IF EXISTS `contact_queries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contact_queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `company` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `message` varchar(1000) DEFAULT NULL,
  `marketing` int(1) DEFAULT '0',
  `source` varchar(255) DEFAULT NULL,
  `email_sent` timestamp(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_resets` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  KEY `password_resets_email_index` (`email`(191)) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `permission`
--

DROP TABLE IF EXISTS `permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `permission_id` int(11) DEFAULT NULL,
  `collection_id` int(11) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `pretty_name` varchar(255) DEFAULT NULL,
  `pretty_desc` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `permission_association`
--

DROP TABLE IF EXISTS `permission_association`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permission_association` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `collection_id` int(11) DEFAULT NULL,
  `product_id` varchar(255) DEFAULT NULL,
  `associated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `permission_collection`
--

DROP TABLE IF EXISTS `permission_collection`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permission_collection` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pretty_name` varchar(255) DEFAULT NULL,
  `pretty_desc` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `permission_default`
--

DROP TABLE IF EXISTS `permission_default`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permission_default` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pretty_name` varchar(255) DEFAULT NULL,
  `pretty_desc` varchar(255) DEFAULT NULL,
  `default_val` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `preference`
--

DROP TABLE IF EXISTS `preference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `preference` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sensor_default_pretty_name`
--

DROP TABLE IF EXISTS `sensor_default_pretty_name`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sensor_default_pretty_name` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sensor_name` varchar(50) NOT NULL,
  `pretty_name` varchar(100) NOT NULL,
  `label` varchar(255) DEFAULT NULL,
  `suffix` varchar(50) DEFAULT NULL,
  `prefix` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_pretty_name`
--

DROP TABLE IF EXISTS `station_pretty_name`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_pretty_name` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sensor_name` varchar(50) NOT NULL,
  `pretty_name` varchar(100) NOT NULL,
  `label` varchar(255) DEFAULT NULL,
  `suffix` varchar(50) DEFAULT NULL,
  `prefix` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_readings`
--

DROP TABLE IF EXISTS `station_readings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_readings` (
  `reading_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `old_reading_id` int(10) DEFAULT NULL,
  `station_id` int(10) unsigned NOT NULL,
  `reading_date` date NOT NULL,
  `reading_datetime` datetime NOT NULL,
  `reading_delta_time` mediumint(8) unsigned NOT NULL,
  `reading_count` smallint(5) unsigned NOT NULL,
  `not_live_data` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_00` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_01` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_02` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_03` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_04` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_05` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_06` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_07` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_08` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_09` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_10` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_11` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_12` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_13` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_14` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_15` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_16` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_17` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_18` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_19` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_20` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_21` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_22` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_23` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_24` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_25` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_26` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_27` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_28` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_29` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_30` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_31` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`reading_id`) USING BTREE,
  KEY `_id` (`station_id`) USING BTREE,
  KEY `_date` (`reading_date`) USING BTREE,
  KEY `_datetime` (`reading_datetime`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1357604 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci ROW_FORMAT=COMPACT;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_readings_delta`
--

DROP TABLE IF EXISTS `station_readings_delta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_readings_delta` (
  `delta_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `reading_id` int(10) unsigned NOT NULL,
  `station_id` int(10) unsigned NOT NULL,
  `reading_date` date NOT NULL,
  `reading_delta_time` mediumint(8) unsigned NOT NULL,
  `reading_count` smallint(5) unsigned NOT NULL,
  `not_live_data` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_00` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_01` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_02` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_03` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_04` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_05` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_06` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_07` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_08` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_09` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_10` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_11` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_12` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_13` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_14` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_15` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_16` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_17` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_18` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_19` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_20` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_21` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_22` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_23` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_24` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_25` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_26` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_27` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_28` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_29` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_30` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_31` varchar(26) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`delta_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci ROW_FORMAT=COMPACT;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `station_sensor_association`
--

DROP TABLE IF EXISTS `station_sensor_association`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `station_sensor_association` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `station_id` int(11) DEFAULT NULL,
  `sensor_id` varchar(10) DEFAULT NULL,
  `sensor_name` varchar(30) DEFAULT NULL,
  `its_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1571 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stations`
--

DROP TABLE IF EXISTS `stations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stations` (
  `station_id` int(10) unsigned NOT NULL,
  `station_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `location_id` int(10) unsigned NOT NULL DEFAULT '0',
  `configuration_id` int(10) unsigned NOT NULL DEFAULT '0',
  `contact_id` int(10) unsigned NOT NULL DEFAULT '0',
  `information_id` int(10) unsigned NOT NULL DEFAULT '0',
  `simulation` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `diagnostic` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `active` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `terramet` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `mobile` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`station_id`) USING BTREE,
  UNIQUE KEY `station_id_UNIQUE` (`station_id`) USING BTREE,
  UNIQUE KEY `station_name_UNIQUE` (`station_name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci ROW_FORMAT=COMPACT COMMENT='"Master" table for Environmental Monitoring Stations.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `test`
--

DROP TABLE IF EXISTS `test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `test` (
  `id` int(11) NOT NULL,
  `category_id` varchar(45) DEFAULT NULL,
  `post_title` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trigger_management`
--

DROP TABLE IF EXISTS `trigger_management`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trigger_management` (
  `triggerId` int(11) NOT NULL AUTO_INCREMENT,
  `triggerName` varchar(50) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`triggerId`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_notifiers`
--

DROP TABLE IF EXISTS `user_notifiers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_notifiers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(13) NOT NULL,
  `email` varchar(255) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=155 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_preference`
--

DROP TABLE IF EXISTS `user_preference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_preference` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `preference_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_sensor_group`
--

DROP TABLE IF EXISTS `user_sensor_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_sensor_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `group_name` varchar(100) NOT NULL,
  `group_order` int(11) NOT NULL DEFAULT '0',
  `default` int(1) NOT NULL DEFAULT '0',
  `deleted` int(1) NOT NULL DEFAULT '0',
  `icon` varchar(100) NOT NULL DEFAULT 'fa fa-object-group',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=142 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_sensor_group_association`
--

DROP TABLE IF EXISTS `user_sensor_group_association`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_sensor_group_association` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `sensor_name` varchar(50) NOT NULL,
  `order` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=478 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_sensor_pretty_name`
--

DROP TABLE IF EXISTS `user_sensor_pretty_name`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_sensor_pretty_name` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `sensor_name` varchar(50) NOT NULL,
  `pretty_name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_station_association`
--

DROP TABLE IF EXISTS `user_station_association`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_station_association` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `station_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=492 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_subscription_history`
--

DROP TABLE IF EXISTS `user_subscription_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_subscription_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sub_id` varchar(255) DEFAULT NULL,
  `cancelled_by` varchar(255) DEFAULT NULL,
  `cancelled_at` varchar(255) DEFAULT NULL,
  `sub_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_widgets`
--

DROP TABLE IF EXISTS `user_widgets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_widgets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `form` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `location_name` varchar(255) DEFAULT NULL,
  `colour` varchar(255) DEFAULT NULL,
  `sensors` varchar(999) DEFAULT NULL,
  `position` varchar(255) DEFAULT NULL,
  `group` varchar(255) DEFAULT NULL,
  `deleted` int(1) DEFAULT NULL,
  `graphs_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2112 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT 'user',
  `stripe_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stripe_card` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stripe_subscription` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `users_email_unique` (`email`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-01 19:15:15
-- MySQL dump 10.13  Distrib 8.0.34, for Win64 (x86_64)
--
-- Host: tthubdb-cluster-1.cluster-che9ka0taxng.eu-west-1.rds.amazonaws.com    Database: ttmeta
-- ------------------------------------------------------
-- Server version	5.7.12

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '';

--
-- Table structure for table `autonomous_api`
--

DROP TABLE IF EXISTS `autonomous_api`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `autonomous_api` (
  `autonomous_api_id` bigint(20) unsigned NOT NULL COMMENT 'Primary Unique Key',
  `php_session` varchar(40) COLLATE latin1_general_ci NOT NULL COMMENT 'PHP Session ID of the Requestor. Used by requested script to validate request',
  `active` tinyint(4) DEFAULT NULL COMMENT 'True whilst API Session is active, False when completed',
  `request_url` varchar(2000) COLLATE latin1_general_ci NOT NULL COMMENT 'API Session Request URL',
  `transaction_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Number of requests / transactions made by the Requestor',
  `first_transaction_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Time of the initial transaction - Start Time',
  `last-transaction-time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Time of the last (most recent) transaction - End Time',
  `success` binary(1) DEFAULT NULL COMMENT 'True on Success, False otherwise',
  `message` text COLLATE latin1_general_ci COMMENT 'A contex sensitive (list of) message(s) relating to the API Access / Transaction. Would normally expect this to be (mostly) error messages.',
  `transaction_blob` blob COMMENT 'Transaction Data? - for future use. Possibly.',
  PRIMARY KEY (`autonomous_api_id`),
  UNIQUE KEY `id_UNIQUE` (`autonomous_api_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci COMMENT='Autonomous API access monitoring and control records';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `coffee_requested`
--

DROP TABLE IF EXISTS `coffee_requested`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coffee_requested` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Auto-incrementing Primary Key.',
  `production` tinyint(4) DEFAULT NULL COMMENT 'Production or UAT Server.',
  `request_time` varchar(25) COLLATE latin1_general_ci NOT NULL COMMENT 'The time the request was made.',
  `client_ip` varchar(45) COLLATE latin1_general_ci NOT NULL DEFAULT 'IP Address Withheld' COMMENT 'String representation of Client''s IP Address - IPV4 or IPV6.',
  `request_url` varchar(255) COLLATE latin1_general_ci NOT NULL DEFAULT 'URL Withheld' COMMENT 'The URL as requested by the Client.',
  `query_string` varchar(255) COLLATE latin1_general_ci NOT NULL DEFAULT 'No Query String' COMMENT 'Any accompanying Query String.',
  `serialised_request` varchar(2048) COLLATE latin1_general_ci DEFAULT NULL COMMENT 'PHP Serialised $_REQUEST Array',
  `serialised_server` varchar(2048) COLLATE latin1_general_ci DEFAULT NULL COMMENT 'PHP Serialised $_SERVER Array',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8056 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci COMMENT='Records the occurrences of requests for the Turftrax API "home Page"';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reports`
--

DROP TABLE IF EXISTS `reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reports` (
  `report_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `report_name` varchar(128) COLLATE latin1_general_ci NOT NULL,
  `report_location` varchar(128) COLLATE latin1_general_ci NOT NULL,
  `report_read` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Maximun Read Access Authorisation Level - only those Users with this authorisation level or LOWER can read this Report',
  `report_generator` varchar(128) COLLATE latin1_general_ci NOT NULL,
  `report_author` varchar(45) COLLATE latin1_general_ci NOT NULL,
  `report_created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `report_editable` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `report_write` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Maximum Write / Modify Access Authorisation Level - only those Users with this authorisation level or LOWER can update or delete this Report',
  `report_updated` datetime DEFAULT NULL,
  `report_updated_by` varchar(45) COLLATE latin1_general_ci DEFAULT NULL,
  `report_deleted` datetime DEFAULT NULL,
  `report_deleted_by` varchar(45) COLLATE latin1_general_ci DEFAULT NULL,
  PRIMARY KEY (`report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci COMMENT='TTITS / TTAPPS Reports';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schedule_list`
--

DROP TABLE IF EXISTS `schedule_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schedule_list` (
  `list_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `schedule_enabled` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Controls whether or not the scheduled executable should be run. Default is NO (0), set to 1 (YES) to run',
  `run_on_demand` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Controls whether or not the scheduled executable can be run on demand. Default is NO (0), set to YES (1) to allow. Some Scheduled Executables REQUIRE others to have been run immediately before. See "trigger_required"',
  `trigger_after` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'A CSV list of schedule ID''s that should be run on the successful termination of this Scheduled Executable. The list order is unimportant as each Member will be treated as a "stand alone" instance. Subsequently they cannot be "chained"',
  `trigger_required` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'Controls whether or not the Schedule Controller will initiate the Schedule Executable. Default is YES (1) - The Controller WILL NOT initiate, the Schedule Executable will be triggered. See "trigger_after". Set to NO (0) for the Controller to initiate',
  `schedule_exec` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`list_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-01 19:15:23
