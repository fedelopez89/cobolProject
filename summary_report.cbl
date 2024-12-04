       IDENTIFICATION DIVISION.
       PROGRAM-ID. summary_report.
       AUTHOR. LOPEZ FEDERICO.
       DATE-WRITTEN. DECEMBER 2024.
       DATE-COMPILED.
      *----------------------------------------------------------------*
      * OBJECTIVE: GENERATE SUMMARY REPORT                             *
      * WITH STATISTICS FOR CUSTOMERS AND TRANSACTIONS                 *
      *----------------------------------------------------------------*
      *
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES. DECIMAL-POINT IS COMMA.
      *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CUSTOMER-FILE    ASSIGN TO "customer_data.txt"
                                   ORGANIZATION IS LINE SEQUENTIAL
                                   FILE STATUS IS FS-CUSTOMER.
      * 
           SELECT TRANSACTION-FILE ASSIGN TO "transaction_data.txt"
                                   ORGANIZATION IS LINE SEQUENTIAL
                                   FILE STATUS IS FS-TRANSACTION.
      * 
           SELECT REPORT-FILE      ASSIGN TO "report.csv"
                                   FILE STATUS IS FS-REPORT.
      *             
      ******************************************************************
      *                  DATA DIVISION                                 *
      ******************************************************************
       DATA DIVISION.
       FILE SECTION.
      *----------------------------------------------------------------*
      * INPUT FILE: CUSTOMER                                           *
      *----------------------------------------------------------------*
       FD  CUSTOMER-FILE.
       01 CUSTOMER-REC.
           05 CUST-ID                      PIC 9(06).
           05 CUST-NAME                    PIC X(50).
           05 CUST-EMAIL                   PIC X(100).
           05 CUST-SIGNUP                  PIC X(10).
      *         
      *----------------------------------------------------------------*
      * INPUT FILE: TRANSACTION                                        *
      *----------------------------------------------------------------*
       FD  TRANSACTION-FILE.
       01 TRANSACTION-REC.
           05 TRANS-ID                     PIC 9(08).
           05 TRANS-CUST-ID                PIC 9(06).
           05 TRANS-DATE                   PIC X(10).
           05 TRANS-AMOUNT                 PIC 9(10)V99.
           05 TRANS-TYPE                   PIC X(20).
      *                      
      *----------------------------------------------------------------*
      * OUTPUT FILE: REPORT                                            *
      *----------------------------------------------------------------*
       FD  REPORT-FILE
           RECORDING MODE IS F.
       01 REPORT-REC.
           05 REPORT-ID                     PIC 9(06).
           05 REPORT-DEL1                   PIC X(01) VALUE ";".
           05 REPORT-NAME                   PIC X(50).
           05 REPORT-DEL2                   PIC X(01) VALUE ";".
           05 REPORT-TOTAL-TRANSACTIONS     PIC 9(06).
           05 REPORT-DEL3                   PIC X(01) VALUE ";".
           05 REPORT-TOTAL-REVENUE          PIC 9(10)V99.
           05 REPORT-DEL4                   PIC X(01) VALUE ";".
           05 REPORT-TOTAL-REFUNDS          PIC 9(06).
      *         
      ******************************************************************
      *                  WORKING STORAGE                               *
      ******************************************************************
       WORKING-STORAGE SECTION.
      *----------------------------------------------------------------*
      * STATUS VARIABLES                                               *
      *----------------------------------------------------------------*
       01  WS-FILE-STATUS.
           05  FS-CUSTOMER             PIC X(2) VALUE SPACES.
           05  FS-TRANSACTION          PIC X(2) VALUE SPACES.
           05  FS-REPORT               PIC X(2) VALUE SPACES.
      *----------------------------------------------------------------*
      * ACCUMULATORS FOR STATISTICS                                    *
      *----------------------------------------------------------------*
       01  WS-STATS.
           05  WS-CUSTOMER-RECORDS     PIC 9(6) VALUE 0.
           05  WS-TRANSACTIONS-RECORDS PIC 9(6) VALUE 0.
           05  WS-REPORT-RECORDS       PIC 9(6) VALUE 0.
           05  WS-TOTAL-TRX            PIC 9(6) VALUE 0.
           05  WS-MATCHES              PIC 9(6) VALUE 0.
           05  WS-NOT-IN-CUSTOMER      PIC 9(6) VALUE 0.
           05  WS-NOT-IN-TRANSACTION   PIC 9(6) VALUE 0.
           05  WS-TOTAL-REVENUE        PIC 9(10)V99 VALUE 0.
           05  WS-TOTAL-REFUNDS        PIC 9(10)V99 VALUE 0.
      *
      *----------------------------------------------------------------*
      * CONSTANTS                                                      *
      *----------------------------------------------------------------*
       01  CT-CONSTANTS.
           05  CT-DELIMITED-CHARACTER  PIC X VALUE ";".
           05  CT-REFUND               PIC X(06) VALUE "Refund".
      *   
      ******************************************************************
      *                     PROCEDURE DIVISION                         *
      ******************************************************************
       PROCEDURE DIVISION.
      *       
           PERFORM 1000-INITIALIZE 
              THRU 1000-INITIALIZE-EXIT.
      *              
           PERFORM 2000-PROCESSING 
              THRU 2000-PROCESSING-EXIT
             UNTIL FS-CUSTOMER = '10' AND FS-TRANSACTION = '10'.
      *           
           PERFORM 9000-FINALIZE 
              THRU 9000-FINALIZE-EXIT.
      *           
           STOP RUN.
      *
      *-----------------------------------------------------------------
       1000-INITIALIZE.
      *---------------*
           DISPLAY "PROGRAM INITIALIZATION STARTED".
      *
           OPEN INPUT CUSTOMER-FILE.
           IF FS-CUSTOMER NOT EQUAL ZEROS
               DISPLAY "ERROR OPENING CUSTOMER FILE: " FS-CUSTOMER
               STOP RUN
           END-IF.
      *  
           OPEN INPUT TRANSACTION-FILE.
           IF FS-TRANSACTION NOT EQUAL ZEROS
               DISPLAY 
                   "ERROR OPENING TRANSACTION FILE: " FS-TRANSACTION
               STOP RUN
           END-IF.
      *  
           OPEN OUTPUT REPORT-FILE.
           IF FS-REPORT NOT EQUAL ZEROS
               DISPLAY "ERROR OPENING REPORT FILE: " FS-REPORT
               STOP RUN
           END-IF.
      *    
           PERFORM 7100-READ-CUSTOMER
              THRU 7100-READ-CUSTOMER-EXIT.
      *
           PERFORM 7200-READ-TRANSACTION
              THRU 7200-READ-TRANSACTION-EXIT
           .
       1000-INITIALIZE-EXIT.
           EXIT.
      *
      *-----------------------------------------------------------------
       2000-PROCESSING.
      *---------------*
           DISPLAY "PROGRAM PROCESSING STARTED".
           DISPLAY "THIS IS THE 2000-PROCESSING PARAGRAPH".
      *
           PERFORM UNTIL CUST-ID = HIGH-VALUES AND 
                         TRANS-CUST-ID = HIGH-VALUES
      *
               IF CUST-ID < TRANS-CUST-ID
      *
                   ADD 1               TO WS-NOT-IN-CUSTOMER
                   PERFORM 8100-WRITE-REPORT
                      THRU 8100-WRITE-REPORT-EXIT
      *
                   PERFORM 7100-READ-CUSTOMER
                      THRU 7100-READ-CUSTOMER-EXIT      
      *
               ELSE 
      *        
                   IF CUST-ID > TRANS-CUST-ID
      *
                       ADD 1               TO WS-NOT-IN-TRANSACTION
                       PERFORM 7200-READ-TRANSACTION
                          THRU 7200-READ-TRANSACTION-EXIT
      *        
                   ELSE
      *
                       PERFORM 2100-PROCESS-MATCH
                          THRU 2100-PROCESS-MATCH-EXIT
      *        
                   END-IF
               END-IF                 
      *        
           END-PERFORM
           .
       2000-PROCESSING-EXIT.
           EXIT.
      *
      *-----------------------------------------------------------------
       2100-PROCESS-MATCH.
      *------------------*
           DISPLAY "THIS IS THE 2100-PROCESSING MATCH ARAGRAPH".
      *
           MOVE ZEROES                 TO WS-TOTAL-TRX 
                                          WS-TOTAL-REVENUE 
                                          WS-TOTAL-REFUNDS    
           ADD 1                       TO WS-MATCHES.
      *         
           PERFORM UNTIL TRANS-CUST-ID NOT EQUAL CUST-ID
      *
               ADD 1                   TO WS-TOTAL-TRX
               COMPUTE WS-TOTAL-REVENUE = WS-TOTAL-REVENUE +
                                          TRANS-AMOUNT
      *
               IF TRANS-TYPE EQUAL CT-REFUND
                   ADD 1               TO WS-TOTAL-REFUNDS
               END-IF
      *
               PERFORM 7200-READ-TRANSACTION
                  THRU 7200-READ-TRANSACTION-EXIT
      *
           END-PERFORM.

           PERFORM 8100-WRITE-REPORT
              THRU 8100-WRITE-REPORT-EXIT  
      *
           PERFORM 7100-READ-CUSTOMER
              THRU 7100-READ-CUSTOMER-EXIT
      *
           INITIALIZE WS-TOTAL-TRX WS-TOTAL-REVENUE WS-TOTAL-REFUNDS    
           .
       2100-PROCESS-MATCH-EXIT.
           EXIT.
      *
      *-----------------------------------------------------------------
       7100-READ-CUSTOMER.
      *------------------*
           DISPLAY "THIS IS THE 7100-PROCESSING READ PARAGRAPH".
      *      
           READ CUSTOMER-FILE.
           EVALUATE FS-CUSTOMER
               WHEN ZEROES
                   ADD 1           TO WS-CUSTOMER-RECORDS
               WHEN '10'
                   MOVE HIGH-VALUES
                                   TO CUST-ID
               WHEN OTHER
                   DISPLAY "ERROR READING CUSTOMER FILE: " FS-CUSTOMER
                   STOP RUN               
           END-EVALUATE
           .
       7100-READ-CUSTOMER-EXIT.
           EXIT.
      *
      *-----------------------------------------------------------------
       7200-READ-TRANSACTION.
      *---------------------*
           DISPLAY "THIS IS THE 7200-PROCESSING READ PARAGRAPH".
      *
           READ TRANSACTION-FILE.
           EVALUATE FS-TRANSACTION
               WHEN ZEROES
                   ADD 1           TO WS-TRANSACTIONS-RECORDS
               WHEN '10'
                   MOVE HIGH-VALUES
                                   TO TRANS-CUST-ID
               WHEN OTHER
                   DISPLAY "ERROR READING TRANSACTION FILE: " 
                                      FS-TRANSACTION
                   STOP RUN               
           END-EVALUATE         
           .
       7200-READ-TRANSACTION-EXIT.
           EXIT.
      *
      *-----------------------------------------------------------------
       8100-WRITE-REPORT.
      *-----------------*  
           INITIALIZE REPORT-REC.         
      *      
           MOVE CUST-ID                TO REPORT-ID
           MOVE CUST-NAME              TO REPORT-NAME
           MOVE WS-TOTAL-TRX           TO REPORT-TOTAL-TRANSACTIONS
           MOVE WS-TOTAL-REVENUE       TO REPORT-TOTAL-REVENUE
           MOVE WS-TOTAL-REFUNDS       TO REPORT-TOTAL-REFUNDS
           MOVE CT-DELIMITED-CHARACTER TO REPORT-DEL1
                                          REPORT-DEL2
                                          REPORT-DEL3
                                          REPORT-DEL4
      *
           WRITE REPORT-REC AFTER ADVANCING 1 LINE.
      *
           IF FS-REPORT EQUAL ZEROS
               ADD 1                   TO WS-REPORT-RECORDS
           ELSE
               DISPLAY 
                   "ERROR WRITING REPORT FILE: " FS-REPORT
               STOP RUN
           END-IF
           .
       8100-WRITE-REPORT-EXIT.
           EXIT.
      *          
      *-----------------------------------------------------------------
       9000-FINALIZE.
      *-------------*
           DISPLAY "PROGRAM FINALIZATION STARTED".
           DISPLAY "THIS IS THE 9000-FINALIZE PARAGRAPH".
      *
           DISPLAY ' '
           DISPLAY "********************************"
           DISPLAY " CONTROL PROGRAM summary_report "     
           DISPLAY "********************************"
           DISPLAY " CUSTOMERS    READ   :  " WS-CUSTOMER-RECORDS
           DISPLAY " TRANSACTIONS READ   :  " WS-TRANSACTIONS-RECORDS 
           DISPLAY " REPORT       WRITE  :  " WS-REPORT-RECORDS 
           DISPLAY "-------------------------------"     
           DISPLAY " CUSTOMERS MATCHES   :  " WS-MATCHES
           DISPLAY " TRX NOT IN CUSTOMER :  " WS-NOT-IN-CUSTOMER 
           DISPLAY " CUSTOMER NOT TRXS   :  " WS-NOT-IN-TRANSACTION 
           DISPLAY "-------------------------------"     
      *
           CLOSE CUSTOMER-FILE.
           IF FS-CUSTOMER NOT EQUAL ZEROS
               DISPLAY "ERROR OPENING CUSTOMER FILE: " FS-CUSTOMER
               STOP RUN
           END-IF.
      *  
           CLOSE TRANSACTION-FILE.
           IF FS-TRANSACTION NOT EQUAL ZEROS
               DISPLAY 
                   "ERROR OPENING TRANSACTION FILE: " FS-TRANSACTION
               STOP RUN
           END-IF.
      *  
           CLOSE REPORT-FILE.
           IF FS-REPORT NOT EQUAL ZEROS
               DISPLAY "ERROR OPENING REPORT FILE: " FS-REPORT
               STOP RUN
           END-IF.
      *
       9000-FINALIZE-EXIT.
           EXIT.
       