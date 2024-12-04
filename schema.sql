CREATE TABLE CUSTOMER (
    CUSTOMERID INTEGER PRIMARY KEY,
    NAME TEXT NOT NULL,
    EMAIL TEXT NOT NULL,
    SIGNUPDATE DATE NOT NULL
);

CREATE TABLE TRANSACTIONS (
    TRANSACTIONID INTEGER PRIMARY KEY,
    CUSTOMERID INTEGER NOT NULL,
    TRANSACTIONDATE DATE NOT NULL,
    AMOUNT DECIMAL(10,2) NOT NULL,
    TRANSACTIONTYPE TEXT NOT NULL,
    FOREIGN KEY (CUSTOMERID) REFERENCES CUSTOMER (CUSTOMERID)
);