import os
import subprocess
import filecmp

# Paths
PROGRAM_BINARY = "./summary_report"
INPUT_CUSTOMER = "customer_data.txt"
INPUT_TRANSACTION = "transaction_data.txt"
OUTPUT_REPORT = "report.csv"
EXPECTED_OUTPUTS_DIR = "tests/expected_outputs"

# Test cases definition
TEST_CASES = {
    "test1": {
        "description": "Client without transactions",
        "customer_data": [
            "000001John Doe                                          john.doe@example.com                                                                                2023-01-01"
        ],
        "transaction_data": [],
        "expected_output": "test1_expected.csv"
    },
    "test2": {
        "description": "Client with multiply transactions (only purchase)",
        "customer_data": [
            "000001John Doe                                          john.doe@example.com                         2023-01-01"
        ],
        "transaction_data": [
            "000000010000012023-01-01000000000900Purchase            ",
            "000000020000012023-01-02000000001500Purchase            "
        ],
        "expected_output": "test2_expected.csv"
    },
    "test3": {
        "description": "Client with transactions of Purchase and Refund",
        "customer_data": [
            "000001John Doe                                          john.doe@example.com                         2023-01-01"
        ],
        "transaction_data": [
            "000000010000012023-01-01000000000900Purchase            ",
            "000000020000012023-01-02000000001500Purchase            ",
            "000000030000012023-01-03000000000300Refund              "
        ],
        "expected_output": "test3_expected.csv"
    },
    "test4": {
        "description": "Client not registered in the transactions",
        "customer_data": [
            "000001John Doe                                          john.doe@example.com                         2023-01-01"
        ],
        "transaction_data": [
            "000000010000022023-01-01000000000900Purchase            "
        ],
        "expected_output": "test4_expected.csv"
    },     
    "test5": {
        "description": "Different clients with transactions",
        "customer_data": [
            "000001John Doe                                          john.doe@example.com                         2023-01-01",
            "000002Jane Smith                                        jane.smith@example.com                       2023-02-01"
        ],
        "transaction_data": [
            "000000010000012023-01-01000000000900Purchase            ",
            "000000020000012023-01-02000000001500Refund              ",
            "000000030000022023-02-01000000002000Purchase            "
        ],
        "expected_output": "test5_expected.csv"
    }     
}

# Utility functions
def write_to_file(filename, lines):
    with open(filename, "w") as f:
        for line in lines:
            f.write(line + "\n")

def run_test(test_name, test_case):
    print(f"Running {test_name}: {test_case['description']}")

    # Write input files
    write_to_file(INPUT_CUSTOMER, test_case["customer_data"])
    write_to_file(INPUT_TRANSACTION, test_case["transaction_data"])

    # Run the program
    subprocess.run(PROGRAM_BINARY, shell=True, check=True)

    # Compare output
    expected_output = os.path.join(EXPECTED_OUTPUTS_DIR, test_case["expected_output"])
    if filecmp.cmp(OUTPUT_REPORT, expected_output, shallow=False):
        print(f"{test_name}: PASS")
    else:
        print(f"{test_name}: FAIL")
        print(f"  Expected: {expected_output}")
        print(f"  Actual: {OUTPUT_REPORT}")

# Main script execution
if __name__ == "__main__":
    for test_name, test_case in TEST_CASES.items():
        run_test(test_name, test_case)