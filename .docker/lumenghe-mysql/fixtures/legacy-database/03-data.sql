CREATE DATABASE IF NOT EXISTS `lumenghe`;

CREATE TABLE `lumenghe`.`user` (
    `user_id` BIGINT NOT NULL,
    `name` CHAR(64) NOT NULL,
    PRIMARY KEY (`user_id`)
);

CREATE TABLE `lumenghe`.`video` (
    `video_id` BIGINT NOT NULL,
    `user_id` BIGINT NOT NULL,
    `video_name` CHAR(64) NOT NULL,
    PRIMARY KEY (`video_id`)
);

CREATE TABLE `lumenghe`.`photo` (
    `photo_id` BIGINT NOT NULL,
    `photo_name` CHAR(64) NOT NULL,
    PRIMARY KEY (`photo_id`)
);

INSERT INTO `lumenghe`.`user` VALUES (1, 'Gabriel');
INSERT INTO `lumenghe`.`user` VALUES (2, 'Nathanael');

INSERT INTO `lumenghe`.`video` VALUES (1, 2, 'sport');
INSERT INTO `lumenghe`.`video` VALUES (2, 2, 'news');

INSERT INTO `lumenghe`.`photo` VALUES (1, 'Paris');
INSERT INTO `lumenghe`.`photo` VALUES (2, 'London');
INSERT INTO `lumenghe`.`photo` VALUES (3, 'Shanghai');
INSERT INTO `lumenghe`.`photo` VALUES (4, 'New York');
INSERT INTO `lumenghe`.`photo` VALUES (5, 'birds');
INSERT INTO `lumenghe`.`photo` VALUES (8, 'office');
