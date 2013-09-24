USE `streets_SUFFIX`;

# Can't seem to get this to stick, let's try all three
SET GLOBAL group_concat_max_len=16777216;
SET group_concat_max_len=16777216;
SET SESSION group_concat_max_len=16777216;

# Create table
CREATE TABLE IF NOT EXISTS `streets_SUFFIX`.`STREET_DETAILS` (`ITEM_ID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY, `NAME` TEXT NOT NULL, `NAME_BASE` TEXT NOT NULL, `NAME_TYPE` TEXT NOT NULL, `STREET_TYPE` TEXT NOT NULL, `STREET_LEVEL` INT NOT NULL, `POLYLINE` LONGTEXT NOT NULL, `WAY_IDS` TEXT NOT NULL, `NUM_WAYS` INT NOT NULL, `PROCESSED` TINYINT(1) NOT NULL, `SKIP` TINYINT(1) NOT NULL);

# Combine ways into streets
INSERT INTO `streets_SUFFIX`.`STREET_DETAILS` (`NAME`,`NAME_BASE`,`NAME_TYPE`,`STREET_TYPE`,`POLYLINE`,`WAY_IDS`,`NUM_WAYS`) SELECT NAME,NAME_BASE,NAME_TYPE,GROUP_CONCAT(STREET_TYPE),GROUP_CONCAT(POLYLINE),GROUP_CONCAT(ID),COUNT(*) AS NUM_WAYS FROM WAYS GROUP BY NAME ORDER BY NAME ASC, ID ASC;
UPDATE `streets_SUFFIX`.`STREET_DETAILS` SET `POLYLINE` = CONCAT('[',`POLYLINE`,']') WHERE `NUM_WAYS` > 1;

# Create generic "Items" table and populate it with streets
CREATE TABLE IF NOT EXISTS `streets_SUFFIX`.`ITEMS` (`ID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY, `ITEM_TYPE` TEXT NOT NULL, `NAME` TEXT NOT NULL, `SKIP` TINYINT(1) NOT NULL);
INSERT INTO `streets_SUFFIX`.`ITEMS` (`ID`,`ITEM_TYPE`,`NAME`,`SKIP`) SELECT d.`ITEM_ID`,'STREET',d.`NAME`,0 FROM `STREET_DETAILS` d ORDER BY d.`ITEM_ID` ASC;

# Create tables for geometries, histories, themes
CREATE TABLE IF NOT EXISTS `streets_SUFFIX`.`GEOMETRIES` (`ITEM_ID` INT NOT NULL,`GEOMETRY` LONGTEXT NOT NULL, `IS_POLYGON` TINYINT(1) NOT NULL, `DIMENSIONS` INT NOT NULL);
INSERT INTO `streets_SUFFIX`.`GEOMETRIES` (`ITEM_ID`,`GEOMETRY`,`IS_POLYGON`,`DIMENSIONS`) SELECT d.`ITEM_ID`, d.`POLYLINE`,0,IF(`NUM_WAYS` > 1,3,2) FROM `streets_SUFFIX`.`STREET_DETAILS` d ORDER BY d.`ITEM_ID` ASC;
CREATE TABLE IF NOT EXISTS `streets_SUFFIX`.`HISTORY_MAP` (`ITEM_ID` INT NOT NULL, `HISTORY_ID` INT NOT NULL, `VERSION` INT NOT NULL, `LAST_UPDATED` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS `streets_SUFFIX`.`HISTORIES` (`ID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY, `IS_PERSON` TINYINT(1) NOT NULL, `PERSON_NAME` TEXT NOT NULL, `BIO` MEDIUMTEXT NOT NULL, `DESCRIPTION` MEDIUMTEXT NOT NULL, `LINK` TEXT NOT NULL, `IMAGE` TEXT NOT NULL, `NOTES` MEDIUMTEXT NOT NULL, `AUTHOR_TWITTER_ID` BIGINT NOT NULL DEFAULT 0, `LAST_UPDATED` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS `streets_SUFFIX`.`THEME_MAP` (`ITEM_ID` INT NOT NULL, `THEME` TEXT NOT NULL);

# Grant privileges
GRANT UPDATE ON `streets_SUFFIX`.`STREET_DETAILS` TO 'streets'@'localhost';
GRANT INSERT ON `streets_SUFFIX`.`HISTORIES` TO 'streets'@'localhost';
GRANT INSERT ON `streets_SUFFIX`.`HISTORY_MAP` TO 'streets'@'localhost';
GRANT INSERT ON `streets_SUFFIX`.`ITEMS` TO 'streets'@'localhost';
GRANT UPDATE ON `streets_SUFFIX`.`ITEMS` TO 'streets'@'localhost';
GRANT DELETE ON `streets_SUFFIX`.`THEME_MAP` TO 'streets'@'localhost';