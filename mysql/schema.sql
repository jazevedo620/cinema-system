CREATE DATABASE IF NOT EXISTS `Team20`;
USE `Team20`;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `Company`;
CREATE TABLE `Company` (`Name` varchar(240), PRIMARY KEY (`Name`));

DROP TABLE IF EXISTS `Movie`;
CREATE TABLE `Movie` (
  `Name` varchar(240) NOT NULL,
  `ReleaseDate` date NOT NULL,
  `Duration` int unsigned NOT NULL,
  PRIMARY KEY (`Name`, `ReleaseDate`)
);

DROP TABLE IF EXISTS `User`;
CREATE TABLE `User` (
  `Username` varchar(240) NOT NULL,
  `Status` char(8) NOT NULL CHECK (
    `Status` IN ('Pending', 'Declined', 'Approved')
  ) DEFAULT 'Pending',
  -- 32-character hex string hash
  `Password` char(32) NOT NULL,
  `Firstname` varchar(240) NOT NULL,
  `Lastname` varchar(240) NOT NULL,
  PRIMARY KEY (`Username`)
);

DROP TABLE IF EXISTS `Employee`;
CREATE TABLE `Employee` (
  `Username` varchar(240) NOT NULL,
  PRIMARY KEY (`Username`),
  CONSTRAINT FOREIGN KEY (`Username`)
    REFERENCES `User` (`Username`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS `Customer`;
CREATE TABLE `Customer` (
  `Username` varchar(240) NOT NULL,
  PRIMARY KEY (`Username`),
  CONSTRAINT FOREIGN KEY (`Username`)
    REFERENCES `User` (`Username`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS `Admin`;
CREATE TABLE `Admin` (
  `Username` varchar(240) NOT NULL,
  PRIMARY KEY (`Username`),
  CONSTRAINT FOREIGN KEY (`Username`)
    REFERENCES `Employee` (`Username`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS `Manager`;
CREATE TABLE `Manager` (
  `Username` varchar(240) NOT NULL,
  `State` char(2) NOT NULL,
  `City` varchar(240) NOT NULL,
  `Zipcode` char(5) NOT NULL,
  `Street` varchar(240) NOT NULl,
  `CompanyName` varchar(240),
  PRIMARY KEY (`Username`),
  CONSTRAINT UNIQUE (`State`, `City`, `Zipcode`, `Street`),
  CONSTRAINT FOREIGN KEY (`Username`)
    REFERENCES `Employee` (`Username`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT FOREIGN KEY (`CompanyName`)
    REFERENCES `Company` (`Name`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS `CreditCard`;
CREATE TABLE `CreditCard` (
  `CreditCardNum` char(16) NOT NULL,
  `Owner` varchar(240) NOT NULL,
  PRIMARY KEY (`CreditCardNum`),
  CONSTRAINT FOREIGN KEY (`Owner`)
    REFERENCES `Customer` (`Username`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS `Theater`;
CREATE TABLE `Theater` (
  `TheaterName` varchar(240) NOT NULL,
  /* partial key */
  `CompanyName` varchar(240) NOT NULL,
  /* partial key */
  `State` char(2) NOT NULL,
  `City` varchar(240) NOT NULL,
  `Zipcode` char(5) NOT NULL,
  `Capacity` int unsigned NOT NULL,
  `Manager` varchar(240),
  `Street` varchar(240) NOT NULL,
  /* full participation */
  PRIMARY KEY (`TheaterName`, `CompanyName`),
  CONSTRAINT FOREIGN KEY (`CompanyName`)
    REFERENCES `Company` (`Name`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT FOREIGN KEY (`Manager`)
    REFERENCES `Manager` (`Username`)
    ON DELETE SET NULL
    ON UPDATE CASCADE

);

DROP TABLE IF EXISTS `MoviePlay`;
CREATE TABLE `MoviePlay` (
  `Date` date NOT NULL,
  `MovieName` varchar(240) NOT NULL,
  `ReleaseDate` date NOT NULL,
  `TheaterName` varchar(240) NOT NULL,
  `CompanyName` varchar(240) NOT NULL,
  PRIMARY KEY (
    `Date`,
    `MovieName`,
    `ReleaseDate`,
    `TheaterName`,
    `CompanyName`
  ),
  CONSTRAINT FOREIGN KEY (`MovieName`, `ReleaseDate`)
    REFERENCES `Movie` (`Name`, `ReleaseDate`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT FOREIGN KEY (`TheaterName`, `CompanyName`)
    REFERENCES `Theater` (`TheaterName`, `CompanyName`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS `Visit`;
CREATE TABLE `Visit` (
  `ID` int AUTO_INCREMENT NOT NULL,
  `Date` date NOT NULL,
  `Username` varchar(240) NOT NULL,
  `TheaterName` varchar(240) NOT NULL,
  `CompanyName` varchar(240) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT FOREIGN KEY (`Username`)
    REFERENCES `User`(`Username`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT FOREIGN KEY (`TheaterName`, `CompanyName`)
    REFERENCES `Theater`(`TheaterName`, `CompanyName`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS `Used`;
CREATE TABLE `Used` (
  `CreditCardNum` char(16) NOT NULL,
  `PlayDate` date NOT NULL,
  `MovieName` varchar(240) NOT NULL,
  `ReleaseDate` date NOT NULL,
  `TheaterName` varchar(240) NOT NULL,
  `CompanyName` varchar(240) NOT NULL,
  PRIMARY KEY (
    `CreditCardNum`,
    `PlayDate`,
    `MovieName`,
    `ReleaseDate`,
    `TheaterName`,
    `CompanyName`
  ),
  CONSTRAINT FOREIGN KEY (`CreditCardNum`)
    REFERENCES `CreditCard` (`CreditCardNum`)
      ON DELETE CASCADE
      ON UPDATE CASCADE,
  CONSTRAINT FOREIGN KEY (
    `PlayDate`,
    `MovieName`,
    `ReleaseDate`,
    `TheaterName`,
    `CompanyName`
  )
    REFERENCES `MoviePlay` (
      `Date`,
      `MovieName`,
      `ReleaseDate`,
      `TheaterName`,
      `CompanyName`
    )
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
SET FOREIGN_KEY_CHECKS = 1;
