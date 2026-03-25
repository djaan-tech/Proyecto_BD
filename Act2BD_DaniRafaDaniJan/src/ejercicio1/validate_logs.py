# =============================================================================
# EXERCISE 1: Price Change Validation Script
# Authors: Rafa Oliver, Dani Pérez, Dani Jan
# =============================================================================

"""
Python script to validate PL/SQL trigger functionality.
Tests:
1. Valid inserts (order lines with <= 100 units)
2. Price change audit logging
3. Invalid inserts blocked by trigger (>100 units)
"""

# =============================================================================
# IMPORTS
# =============================================================================

import oracledb

# =============================================================================
# DATABASE CONNECTION
# =============================================================================

conn = oracledb.connect(
    user="SYSTEM",
    password="oracle",
    dsn="192.168.56.101:1521/FREEPDB1"
)

print("Connected to Oracle Database.")
cursor = conn.cursor()

# =============================================================================
# VALID INSERT: Order lines with valid quantity (<= 100 units)
# =============================================================================

print("\n--- Test 1: Valid inserts ---")
cursor.execute("INSERT INTO LiniesComanda VALUES (56, 102, 1, 50)")
cursor.execute("INSERT INTO LiniesComanda VALUES (40, 102, 1, 33)")
conn.commit()
print("Valid inserts completed successfully (50 and 33 units).")

# =============================================================================
# VIEW AUDIT LOG: Price change history
# =============================================================================

print("\n--- Test 2: Price change audit log ---")
cursor.execute("""
    SELECT 
        producte_id, 
        preu_antic, 
        preu_nou, 
        TO_CHAR(data_modificacio, 'DD-MM-YYYY HH24:MI:SS')
    FROM LogsPreus
""")

for producte_id, preu_antic, preu_nou, data_modificacio in cursor:
    print(f"[{data_modificacio}] Product {producte_id}: "
          f"price changed from {preu_antic}€ to {preu_nou}€")

conn.commit()

# =============================================================================
# INVALID INSERT: Should be blocked by trigger (>100 units)
# =============================================================================

print("\n--- Test 3: Invalid insert (should trigger error) ---")
try:
    # This insert should fail because 303 > 100 units
    cursor.execute("INSERT INTO LiniesComanda VALUES (81, 101, 1, 303)")
    conn.commit()
    print("ERROR: Insert should have been blocked!")
except oracledb.DatabaseError as e:
    error, = e.args
    print(f"Trigger correctly blocked the insert.")
    print(f"Error code: {error.code}")
    print(f"Error message: {error.message}")

# =============================================================================
# CLEANUP
# =============================================================================

cursor.close()
conn.close()
print("\nConnection closed.")
print("Validation complete.")
