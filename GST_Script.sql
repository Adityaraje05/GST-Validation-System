-- =====================================================================
-- GST Number Validation Project using SQL (PostgreSQL)
-- Dataset: gst_number_dataset_single_column.csv
-- =====================================================================

-- 1️⃣ Create stage table for original dataset
DROP TABLE IF EXISTS stg_gst_numbers_dataset;
CREATE TABLE stg_gst_numbers_dataset
(
    gst_number TEXT
);

-- Import your dataset (adjust file path as needed)
-- \COPY stg_gst_numbers_dataset(gst_number)
-- FROM '/path/to/gst_number_dataset_single_column.csv'
-- DELIMITER ',' CSV HEADER;

-- =====================================================================
-- 2️⃣ Data Cleaning and Preprocessing
-- =====================================================================

-- Identify missing data
SELECT * FROM stg_gst_numbers_dataset WHERE gst_number IS NULL OR TRIM(gst_number) = '';

-- Check for duplicates
SELECT gst_number, COUNT(*)
FROM stg_gst_numbers_dataset
WHERE gst_number IS NOT NULL
GROUP BY gst_number
HAVING COUNT(*) > 1;

-- Detect leading/trailing spaces
SELECT *
FROM stg_gst_numbers_dataset
WHERE gst_number <> TRIM(gst_number);

-- Detect lowercase or mixed case entries
SELECT *
FROM stg_gst_numbers_dataset
WHERE gst_number <> UPPER(gst_number);

-- =====================================================================
-- 3️⃣ Create Cleaned Dataset
-- =====================================================================
CREATE TABLE gst_numbers_dataset_cleaned AS
SELECT DISTINCT UPPER(TRIM(gst_number)) AS gst_number
FROM stg_gst_numbers_dataset
WHERE gst_number IS NOT NULL
  AND TRIM(gst_number) <> '';

-- =====================================================================
-- 4️⃣ Helper Functions for Validation
-- =====================================================================

-- Function to check adjacent repetition
CREATE OR REPLACE FUNCTION fn_check_adjacent_repetition(p_str TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    FOR i IN 1 .. (LENGTH(p_str) - 1)
    LOOP
        IF SUBSTRING(p_str, i, 1) = SUBSTRING(p_str, i + 1, 1)
        THEN RETURN TRUE;
        END IF;
    END LOOP;
    RETURN FALSE;
END;
$$;

-- Function to check if characters are sequential (ABCDE, 1234)
CREATE OR REPLACE FUNCTION fn_check_sequence(p_str TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    FOR i IN 1 .. (LENGTH(p_str) - 1)
    LOOP
        IF ASCII(SUBSTRING(p_str, i + 1, 1)) - ASCII(SUBSTRING(p_str, i, 1)) <> 1
        THEN RETURN FALSE;
        END IF;
    END LOOP;
    RETURN TRUE;
END;
$$;

-- =====================================================================
-- 5️⃣ State Code Reference Table (for validation)
-- =====================================================================
DROP TABLE IF EXISTS gst_state_codes;
CREATE TABLE gst_state_codes (
    state_code CHAR(2) PRIMARY KEY,
    state_name TEXT
);

INSERT INTO gst_state_codes(state_code, state_name) VALUES
('01', 'Jammu & Kashmir'),
('02', 'Himachal Pradesh'),
('03', 'Punjab'),
('04', 'Chandigarh'),
('05', 'Uttarakhand'),
('06', 'Haryana'),
('07', 'Delhi'),
('08', 'Rajasthan'),
('09', 'Uttar Pradesh'),
('10', 'Bihar'),
('11', 'Sikkim'),
('12', 'Arunachal Pradesh'),
('13', 'Nagaland'),
('14', 'Manipur'),
('15', 'Mizoram'),
('16', 'Tripura'),
('17', 'Meghalaya'),
('18', 'Assam'),
('19', 'West Bengal'),
('20', 'Jharkhand'),
('21', 'Odisha'),
('22', 'Chhattisgarh'),
('23', 'Madhya Pradesh'),
('24', 'Gujarat'),
('25', 'Daman & Diu'),
('26', 'Dadra & Nagar Haveli'),
('27', 'Maharashtra'),
('28', 'Andhra Pradesh'),
('29', 'Karnataka'),
('30', 'Goa'),
('31', 'Lakshadweep'),
('32', 'Kerala'),
('33', 'Tamil Nadu'),
('34', 'Puducherry'),
('35', 'Andaman & Nicobar Islands'),
('36', 'Telangana'),
('37', 'Andhra Pradesh (New)');

-- =====================================================================
-- 6️⃣ GSTIN Validation View
-- =====================================================================

CREATE OR REPLACE VIEW vw_valid_invalid_gst AS
WITH cte_cleaned_gst AS (
    SELECT DISTINCT UPPER(TRIM(gst_number)) AS gst_number
    FROM stg_gst_numbers_dataset
    WHERE gst_number IS NOT NULL AND TRIM(gst_number) <> ''
),
cte_valid_gst AS (
    SELECT gst_number
    FROM cte_cleaned_gst
    WHERE 
        LENGTH(gst_number) = 15
        AND gst_number ~ '^(0[1-9]|[1-2][0-9]|3[0-7])[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$'
        AND SUBSTRING(gst_number, 3, 10) ~ '^[A-Z]{5}[0-9]{4}[A-Z]$'
        AND fn_check_adjacent_repetition(SUBSTRING(gst_number, 3, 5)) = FALSE
        AND fn_check_sequence(SUBSTRING(gst_number, 3, 5)) = FALSE
        AND fn_check_sequence(SUBSTRING(gst_number, 8, 4)) = FALSE
        AND SUBSTRING(gst_number, 14, 1) = 'Z'
)
SELECT 
    c.gst_number,
    s.state_name,
    CASE 
        WHEN v.gst_number IS NULL THEN 'Invalid GST'
        WHEN s.state_name IS NULL THEN 'Invalid State Code'
        ELSE 'Valid GST'
    END AS status
FROM cte_cleaned_gst c
LEFT JOIN cte_valid_gst v ON v.gst_number = c.gst_number
LEFT JOIN gst_state_codes s ON s.state_code = SUBSTRING(c.gst_number, 1, 2);

-- =====================================================================
-- 7️⃣ Summary Report
-- =====================================================================

WITH cte AS (
    SELECT 
        (SELECT COUNT(*) FROM stg_gst_numbers_dataset) AS total_records,
        COUNT(*) FILTER (WHERE vw.status = 'Valid GST') AS total_valid_gst,
        COUNT(*) FILTER (WHERE vw.status = 'Invalid GST') AS total_invalid_gst,
        COUNT(*) FILTER (WHERE vw.status = 'Invalid State Code') AS invalid_state
    FROM vw_valid_invalid_gst vw
)
SELECT 
    total_records,
    total_valid_gst,
    total_invalid_gst,
    invalid_state,
    total_records - (total_valid_gst + total_invalid_gst + invalid_state) AS missing_incomplete_gst
FROM cte;

-- =====================================================================
-- ✅ End of GST Number Validation Project (Single Column Version)
-- =====================================================================
