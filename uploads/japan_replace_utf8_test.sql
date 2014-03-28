--source include/have_utf8.inc
--source include/have_innodb.inc
--disable_warnings
drop table if exists `Ｔ１`;
drop table if exists `Ｔ２`;
drop table if exists `Ｔ３`;
drop table if exists `Ｔ４`;
drop table if exists `Ｔ５`;
drop table if exists `Ｔ６`;
drop table if exists `Ｔ７`;
drop table if exists `Ｔ８`;
drop table if exists `Ｔ９`;
--enable_warnings

#
# Test REPLACE() function with Japanese characters in utf8 encoding
#

SET NAMES utf8;
SET character_set_database = utf8;

CREATE TABLE `Ｔ１` (`Ｃ１` char(5)) DEFAULT CHARSET = utf8 engine = innodb;
CREATE TABLE `Ｔ２` (`Ｃ１` char(5)) DEFAULT CHARSET = utf8 engine = innodb;
CREATE TABLE `Ｔ３` (`Ｃ１` char(5)) DEFAULT CHARSET = utf8 engine = innodb;
CREATE TABLE `Ｔ４` (`Ｃ１` char(5)) DEFAULT CHARSET = utf8 engine = myisam;
CREATE TABLE `Ｔ５` (`Ｃ１` char(5)) DEFAULT CHARSET = utf8 engine = myisam;
CREATE TABLE `Ｔ６` (`Ｃ１` char(5)) DEFAULT CHARSET = utf8 engine = myisam;
CREATE TABLE `Ｔ７` (`Ｃ１` char(5)) DEFAULT CHARSET = utf8 engine = MEMORY;
CREATE TABLE `Ｔ８` (`Ｃ１` char(5)) DEFAULT CHARSET = utf8 engine = MEMORY;
CREATE TABLE `Ｔ９` (`Ｃ１` char(5)) DEFAULT CHARSET = utf8 engine = MEMORY;

INSERT INTO `Ｔ１` VALUES ('ｱｲｳｴｵ');
INSERT INTO `Ｔ２` VALUES ('あいうえお');
INSERT INTO `Ｔ３` VALUES ('龔龖龗龞龡');
INSERT INTO `Ｔ４` VALUES ('ｱｲｳｴｵ');
INSERT INTO `Ｔ５` VALUES ('あいうえお');
INSERT INTO `Ｔ６` VALUES ('龔龖龗龞龡');
INSERT INTO `Ｔ７` VALUES ('ｱｲｳｴｵ');
INSERT INTO `Ｔ８` VALUES ('あいうえお');
INSERT INTO `Ｔ９` VALUES ('龔龖龗龞龡');

#InnoDB
SELECT REPLACE(`Ｃ１`,'ｱ','ｱｱ') FROM `Ｔ１`;
SELECT REPLACE(`Ｃ１`,'ｲ','ｲｲ') FROM `Ｔ１`;
SELECT REPLACE(`Ｃ１`,'ｳ','ｳｳ') FROM `Ｔ１`;
SELECT REPLACE(`Ｃ１`,'ｴ','ｴｴ') FROM `Ｔ１`;
SELECT REPLACE(`Ｃ１`,'ｵ','ｵｵ') FROM `Ｔ１`;
SELECT REPLACE(`Ｃ１`,'あ','ああ') FROM `Ｔ２`;
SELECT REPLACE(`Ｃ１`,'い','いい') FROM `Ｔ２`;
SELECT REPLACE(`Ｃ１`,'う','うう') FROM `Ｔ２`;
SELECT REPLACE(`Ｃ１`,'え','ええ') FROM `Ｔ２`;
SELECT REPLACE(`Ｃ１`,'お','おお') FROM `Ｔ２`;
SELECT REPLACE(`Ｃ１`,'龔','龔龔') FROM `Ｔ３`;
SELECT REPLACE(`Ｃ１`,'龖','龖龖') FROM `Ｔ３`;
SELECT REPLACE(`Ｃ１`,'龗','龗龗') FROM `Ｔ３`;
SELECT REPLACE(`Ｃ１`,'龞','龞龞') FROM `Ｔ３`;
SELECT REPLACE(`Ｃ１`,'龡','龡龡') FROM `Ｔ３`;

#MyISAM
SELECT REPLACE(`Ｃ１`,'ｱ','ｱｱ') FROM `Ｔ４`;
SELECT REPLACE(`Ｃ１`,'ｲ','ｲｲ') FROM `Ｔ４`;
SELECT REPLACE(`Ｃ１`,'ｳ','ｳｳ') FROM `Ｔ４`;
SELECT REPLACE(`Ｃ１`,'ｴ','ｴｴ') FROM `Ｔ４`;
SELECT REPLACE(`Ｃ１`,'ｵ','ｵｵ') FROM `Ｔ４`;
SELECT REPLACE(`Ｃ１`,'あ','ああ') FROM `Ｔ５`;
SELECT REPLACE(`Ｃ１`,'い','いい') FROM `Ｔ５`;
SELECT REPLACE(`Ｃ１`,'う','うう') FROM `Ｔ５`;
SELECT REPLACE(`Ｃ１`,'え','ええ') FROM `Ｔ５`;
SELECT REPLACE(`Ｃ１`,'お','おお') FROM `Ｔ５`;
SELECT REPLACE(`Ｃ１`,'龔','龔龔') FROM `Ｔ６`;
SELECT REPLACE(`Ｃ１`,'龖','龖龖') FROM `Ｔ６`;
SELECT REPLACE(`Ｃ１`,'龗','龗龗') FROM `Ｔ６`;
SELECT REPLACE(`Ｃ１`,'龞','龞龞') FROM `Ｔ６`;
SELECT REPLACE(`Ｃ１`,'龡','龡龡') FROM `Ｔ６`;

#MEMORY
SELECT REPLACE(`Ｃ１`,'ｱ','ｱｱ') FROM `Ｔ７`;
SELECT REPLACE(`Ｃ１`,'ｲ','ｲｲ') FROM `Ｔ７`;
SELECT REPLACE(`Ｃ１`,'ｳ','ｳｳ') FROM `Ｔ７`;
SELECT REPLACE(`Ｃ１`,'ｴ','ｴｴ') FROM `Ｔ７`;
SELECT REPLACE(`Ｃ１`,'ｵ','ｵｵ') FROM `Ｔ７`;
SELECT REPLACE(`Ｃ１`,'あ','ああ') FROM `Ｔ８`;
SELECT REPLACE(`Ｃ１`,'い','いい') FROM `Ｔ８`;
SELECT REPLACE(`Ｃ１`,'う','うう') FROM `Ｔ８`;
SELECT REPLACE(`Ｃ１`,'え','ええ') FROM `Ｔ８`;
SELECT REPLACE(`Ｃ１`,'お','おお') FROM `Ｔ８`;
SELECT REPLACE(`Ｃ１`,'龔','龔龔') FROM `Ｔ９`;
SELECT REPLACE(`Ｃ１`,'龖','龖龖') FROM `Ｔ９`;
SELECT REPLACE(`Ｃ１`,'龗','龗龗') FROM `Ｔ９`;
SELECT REPLACE(`Ｃ１`,'龞','龞龞') FROM `Ｔ９`;
SELECT REPLACE(`Ｃ１`,'龡','龡龡') FROM `Ｔ９`;

DROP TABLE `Ｔ１`;
DROP TABLE `Ｔ２`;
DROP TABLE `Ｔ３`;
DROP TABLE `Ｔ４`;
DROP TABLE `Ｔ５`;
DROP TABLE `Ｔ６`;
DROP TABLE `Ｔ７`;
DROP TABLE `Ｔ８`;
DROP TABLE `Ｔ９`;