 GST Validation System (SQL Project)

📌 Project Overview
The GST Validation System is a SQL-based project designed to validate and manage Indian GST (Goods and Services Tax) numbers. The system stores GST records, verifies GSTIN format, checks state codes, validates PAN details embedded within GSTIN, and maintains business information in a structured database.

🚀 Features
- Store GSTIN and business details
- Validate GST Number format
- Verify State Codes
- Extract and validate PAN from GSTIN
- Search GST records efficiently
- Generate validation reports
- Manage business tax information

🛠️ Technologies Used
- SQL Server
- T-SQL
- Stored Procedures
- Functions (UDFs)
- Views
- Triggers

📂 Database Objects

 Tables
- Business
- GST_Details
- State_Master
- Validation_Log

Stored Procedures
- InsertGSTRecord
- ValidateGSTIN
- GetBusinessDetails
- UpdateGSTInformation

Functions
- CheckGSTFormat()
- ExtractPANFromGST()
- ValidateStateCode()

Views
- ValidGSTRecords
- InvalidGSTRecords

📊 Project Workflow
1. User enters GSTIN details.
2. System validates GST format.
3. PAN and State Code are verified.
4. Validation results are stored in the database.
5. Reports can be generated using SQL queries and views.

🎯 Learning Outcomes
- Database Design
- SQL Query Optimization
- Stored Procedures
- User Defined Functions
- Triggers
- Data Validation Techniques
- Report Generation

📸 Sample GSTIN
```
27AAPFU0939F1ZV
```

👨‍💻 Author
Aditya Nikrad

- B.Tech Computer Science & Engineering
- Java Full Stack Developer
- SQL Developer Enthusiast

- Web-based Dashboard
- Automated GST Verification
- Advanced Reporting and Analytics
