CREATE DATABASE Team20;
SET session_replication_role = 'replica';

DROP TABLE IF EXISTS Company;
CREATE TABLE Company (Name varchar(240), PRIMARY KEY (Name));

DROP TABLE IF EXISTS Movie;
CREATE TABLE Movie (
  Name varchar(240) NOT NULL,
  ReleaseDate date NOT NULL,
  Duration int NOT NULL,
  PRIMARY KEY (Name, ReleaseDate)
);

DROP TABLE IF EXISTS "User";
CREATE TABLE "User" (
  Username varchar(240) NOT NULL,
  Status char(8) NOT NULL CHECK (
    Status IN ('Pending', 'Declined', 'Approved')
  ) DEFAULT 'Pending',
  -- 44-character base64 hashed password
  Password char(44) NOT NULL,
  Firstname varchar(240) NOT NULL,
  Lastname varchar(240) NOT NULL,
  PRIMARY KEY (Username)
);

DROP TABLE IF EXISTS Employee;
CREATE TABLE Employee (
  Username varchar(240) NOT NULL,
  PRIMARY KEY (Username),
  FOREIGN KEY (Username)
    REFERENCES "User" (Username)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Customer;
CREATE TABLE Customer (
  Username varchar(240) NOT NULL,
  PRIMARY KEY (Username),
  FOREIGN KEY (Username)
    REFERENCES "User" (Username)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Admin;
CREATE TABLE Admin (
  Username varchar(240) NOT NULL,
  PRIMARY KEY (Username),
  FOREIGN KEY (Username)
    REFERENCES Employee (Username)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Manager;
CREATE TABLE Manager (
  Username varchar(240) NOT NULL,
  State char(2) NOT NULL,
  City varchar(240) NOT NULL,
  Zipcode char(5) NOT NULL,
  Street varchar(240) NOT NULl,
  CompanyName varchar(240),
  PRIMARY KEY (Username),
  UNIQUE (State, City, Zipcode, Street),
  FOREIGN KEY (Username)
    REFERENCES Employee (Username)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (CompanyName)
    REFERENCES Company (Name)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS CreditCard;
CREATE TABLE CreditCard (
  CreditCardNum char(16) NOT NULL,
  Owner varchar(240) NOT NULL,
  PRIMARY KEY (CreditCardNum),
  FOREIGN KEY (Owner)
    REFERENCES Customer (Username)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Theater;
CREATE TABLE Theater (
  TheaterName varchar(240) NOT NULL,
  /* partial key */
  CompanyName varchar(240) NOT NULL,
  /* partial key */
  State char(2) NOT NULL,
  City varchar(240) NOT NULL,
  Zipcode char(5) NOT NULL,
  Capacity int NOT NULL,
  Manager varchar(240),
  Street varchar(240) NOT NULL,
  /* full participation */
  PRIMARY KEY (TheaterName, CompanyName),
  FOREIGN KEY (CompanyName)
    REFERENCES Company (Name)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (Manager)
    REFERENCES Manager (Username)
    ON DELETE SET NULL
    ON UPDATE CASCADE

);

DROP TABLE IF EXISTS MoviePlay;
CREATE TABLE MoviePlay (
  Date date NOT NULL,
  MovieName varchar(240) NOT NULL,
  ReleaseDate date NOT NULL,
  TheaterName varchar(240) NOT NULL,
  CompanyName varchar(240) NOT NULL,
  PRIMARY KEY (
    Date,
    MovieName,
    ReleaseDate,
    TheaterName,
    CompanyName
  ),
  FOREIGN KEY (MovieName, ReleaseDate)
    REFERENCES Movie (Name, ReleaseDate)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (TheaterName, CompanyName)
    REFERENCES Theater (TheaterName, CompanyName)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Visit;
CREATE TABLE Visit (
  ID SERIAL NOT NULL,
  Date date NOT NULL,
  Username varchar(240) NOT NULL,
  TheaterName varchar(240) NOT NULL,
  CompanyName varchar(240) NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (Username)
    REFERENCES "User"(Username)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (TheaterName, CompanyName)
    REFERENCES Theater(TheaterName, CompanyName)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Used;
CREATE TABLE Used (
  CreditCardNum char(16) NOT NULL,
  PlayDate date NOT NULL,
  MovieName varchar(240) NOT NULL,
  ReleaseDate date NOT NULL,
  TheaterName varchar(240) NOT NULL,
  CompanyName varchar(240) NOT NULL,
  PRIMARY KEY (
    CreditCardNum,
    PlayDate,
    MovieName,
    ReleaseDate,
    TheaterName,
    CompanyName
  ),
  FOREIGN KEY (CreditCardNum)
    REFERENCES CreditCard (CreditCardNum)
      ON DELETE CASCADE
      ON UPDATE CASCADE,
  FOREIGN KEY (
    PlayDate,
    MovieName,
    ReleaseDate,
    TheaterName,
    CompanyName
  )
    REFERENCES MoviePlay (
      Date,
      MovieName,
      ReleaseDate,
      TheaterName,
      CompanyName
    )
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
SET session_replication_role = 'origin';
