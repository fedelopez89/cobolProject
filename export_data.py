import sqlite3

# Database configuration and output file paths
DATABASE_PATH = "database.db"
CUSTOMER_QUERY = """
    SELECT CUSTOMERID, NAME, EMAIL, SIGNUPDATE
    FROM CUSTOMER
    ORDER BY CUSTOMERID;
"""
TRANSACTION_QUERY = """
    SELECT TRANSACTIONID, CUSTOMERID, TRANSACTIONDATE, AMOUNT, TRANSACTIONTYPE
    FROM TRANSACTIONS
    ORDER BY CUSTOMERID;
"""
OUTPUT_FILE_CUSTOMER = "customer_data.txt"
OUTPUT_FILE_TRANSACTION = "transaction_data.txt"

# Define the fixed-width format for each field
def format_fixed_width(data, field_lengths, fillers, monetary_indices=[]):
    """
    Converts a tuple of data into a fixed-width text line.
    :param data: Tuple of values.
    :param field_lengths: Lengths of each field.
    :param fillers: Fill characters (space or zero).
    :param monetary_indices: List of indices to format as monetary values.
    :return: String with fixed width.
    """
    formatted = []
    for index, (value, length, filler) in enumerate(zip(data, field_lengths, fillers)):
        if index in monetary_indices:
            # Special formatting for monetary fields
            numeric_value = float(value)  # Convert to float
            integer_part = int(numeric_value * 100)
            formatted.append(str(integer_part).zfill(length))
        else:
            # Default behavior for other fields
            if isinstance(value, int) or (isinstance(value, str) and value.isdigit()):
                formatted.append(str(value).zfill(length))  # Zero-fill for numeric fields
            else:
                formatted.append(str(value).ljust(length))  # Space-fill for text fields
    return "".join(formatted)

# Export data to fixed-width files
def export_table_to_fixed_width(database_path, query, output_file, field_lengths, fillers, monetary_indices=[]):
    with sqlite3.connect(database_path) as conn, open(output_file, "w") as file:
        cursor = conn.cursor()
        cursor.execute(query)
        rows = cursor.fetchall()
        for row in rows:
            formatted_row = format_fixed_width(row, field_lengths, fillers, monetary_indices)
            file.write(formatted_row + "\n")
    print(f"Data exported to {output_file}")

# Export CUSTOMER data
export_table_to_fixed_width(
    DATABASE_PATH,
    CUSTOMER_QUERY,
    OUTPUT_FILE_CUSTOMER,
    field_lengths=[6, 50, 100, 10],  # CUSTOMERID: 6, NAME: 50, EMAIL: 100, SIGNUPDATE: 10
    fillers=["0", " ", " ", " "],   # Zero-padding for numeric, space-padding for text fields
    monetary_indices=[]             # No monetary fields in CUSTOMER
)

# Export TRANSACTIONS data
export_table_to_fixed_width(
    DATABASE_PATH,
    TRANSACTION_QUERY,
    OUTPUT_FILE_TRANSACTION,
    field_lengths=[8, 6, 10, 12, 20],  # TRANSACTIONID: 8, CUSTOMERID: 6, DATE: 10, AMOUNT: 12, TYPE: 20
    fillers=["0", "0", " ", "0", " "], # Zero-padding for numeric, space-padding for text fields
    monetary_indices=[3]               # AMOUNT is the monetary field
)