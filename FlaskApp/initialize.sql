-- MySQL Script generated by MySQL Workbench
-- Tue Apr  2 02:50:33 2024
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema BookFinder
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema BookFinder
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `BookFinder` DEFAULT CHARACTER SET utf8 ;
USE `BookFinder` ;

-- -----------------------------------------------------
-- Table `BookFinder`.`Authors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BookFinder`.`Authors` ;

CREATE TABLE IF NOT EXISTS `BookFinder`.`Authors` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `FirstName` VARCHAR(255) NOT NULL,
  `LastName` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `BookFinder`.`Genres`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BookFinder`.`Genres` ;

CREATE TABLE IF NOT EXISTS `BookFinder`.`Genres` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `BookFinder`.`Books`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BookFinder`.`Books` ;

CREATE TABLE IF NOT EXISTS `BookFinder`.`Books` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `ISBN` VARCHAR(255) NOT NULL,
  `Title` VARCHAR(255) NOT NULL,
  `AuthorId` INT NOT NULL,
  `YearPublished` INT NOT NULL,
  `GenreId` INT NOT NULL,
  PRIMARY KEY (`id`, `ISBN`),
  INDEX `AuthorId_idx` (`AuthorId` ASC) VISIBLE,
  INDEX `GenreId_idx` (`GenreId` ASC) VISIBLE,
  CONSTRAINT `AuthorId`
    FOREIGN KEY (`AuthorId`)
    REFERENCES `BookFinder`.`Authors` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `GenreId`
    FOREIGN KEY (`GenreId`)
    REFERENCES `BookFinder`.`Genres` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `BookFinder`.`Addresses`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BookFinder`.`Addresses` ;

CREATE TABLE IF NOT EXISTS `BookFinder`.`Addresses` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `StreetAddr` VARCHAR(255) NOT NULL,
  `City` VARCHAR(255) NOT NULL,
  `State` VARCHAR(255) NOT NULL,
  `ZipCode` INT NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `BookFinder`.`Bookstores`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BookFinder`.`Bookstores` ;

CREATE TABLE IF NOT EXISTS `BookFinder`.`Bookstores` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(255) NOT NULL,
  `AddressId` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `AddressId_idx` (`AddressId` ASC) VISIBLE,
  CONSTRAINT `StoreAddress`
    FOREIGN KEY (`AddressId`)
    REFERENCES `BookFinder`.`Addresses` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `BookFinder`.`Libraries`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BookFinder`.`Libraries` ;

CREATE TABLE IF NOT EXISTS `BookFinder`.`Libraries` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `BranchName` VARCHAR(255) NOT NULL,
  `AddressId` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `AddressId_idx` (`AddressId` ASC) VISIBLE,
  CONSTRAINT `LibAddress`
    FOREIGN KEY (`AddressId`)
    REFERENCES `BookFinder`.`Addresses` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `BookFinder`.`StoreCopies`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BookFinder`.`StoreCopies` ;

CREATE TABLE IF NOT EXISTS `BookFinder`.`StoreCopies` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `BookId` INT NOT NULL,
  `BookstoreId` INT NOT NULL,
  `Price` DECIMAL(2) NOT NULL,
  PRIMARY KEY (`id`, `BookId`),
  INDEX `BookId_idx` (`BookId` ASC) VISIBLE,
  INDEX `BookstoreId_idx` (`BookstoreId` ASC) VISIBLE,
  CONSTRAINT `StoreBookId`
    FOREIGN KEY (`BookId`)
    REFERENCES `BookFinder`.`Books` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `BookstoreId`
    FOREIGN KEY (`BookstoreId`)
    REFERENCES `BookFinder`.`Bookstores` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `BookFinder`.`Reviews`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BookFinder`.`Reviews` ;

CREATE TABLE IF NOT EXISTS `BookFinder`.`Reviews` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `BookId` INT NOT NULL,
  `ReviewerName` VARCHAR(255) NOT NULL,
  `Stars` INT NOT NULL,
  `Review` VARCHAR(1000) NULL,
  `Date` DATETIME NOT NULL,
  PRIMARY KEY (`id`, `BookId`),
  INDEX `BookId_idx` (`BookId` ASC) VISIBLE,
  CONSTRAINT `BookAbout`
    FOREIGN KEY (`BookId`)
    REFERENCES `BookFinder`.`Books` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `BookFinder`.`LibraryCopies`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `BookFinder`.`LibraryCopies` ;

CREATE TABLE IF NOT EXISTS `BookFinder`.`LibraryCopies` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `BookId` INT NOT NULL,
  `LibraryId` INT NOT NULL,
  `Available` TINYINT NOT NULL COMMENT 'Boolean -- Is this copy available?',
  PRIMARY KEY (`id`, `BookId`),
  INDEX `BookId_idx` (`BookId` ASC) VISIBLE,
  INDEX `LibraryId_idx` (`LibraryId` ASC) VISIBLE,
  CONSTRAINT `LibBookId`
    FOREIGN KEY (`BookId`)
    REFERENCES `BookFinder`.`Books` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `LibraryId`
    FOREIGN KEY (`LibraryId`)
    REFERENCES `BookFinder`.`Libraries` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

INSERT INTO Genres (id, Name) VALUES
(1, 'Science Fiction'),
(2, 'Fantasy'),
(3, 'Romance'), 
(4, 'Nonfiction');
