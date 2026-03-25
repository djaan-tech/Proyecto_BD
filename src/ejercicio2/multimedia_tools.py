# =============================================================================
# EXERCISE 2: Multimedia Upload Script
# Authors: Rafa Oliver, Dani Pérez, Dani Jan
# =============================================================================

"""
Python script for uploading multimedia files to Oracle BLOB columns.
Tests:
1. Image upload (JPG to ImatgesProducte)
2. Audio upload (MP3 to AudiosComanda)
3. XML document upload (to DocumentsXML)
4. Verification of stored file sizes
"""

# =============================================================================
# IMPORTS
# =============================================================================

import oracledb
import os

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
# HELPER FUNCTIONS
# =============================================================================

def upload_image(producte_id, filepath, description):
    """Upload image file to BLOB column."""
    with open(filepath, 'rb') as f:
        blob_data = f.read()
        file_format = os.path.splitext(filepath)[-1][1:]
        cursor.execute("""
            INSERT INTO ImatgesProducte (producte_id, descripcio, imatge, format) 
            VALUES (:1, :2, :3, :4)
        """, (producte_id, description, blob_data, file_format))
    print(f"Image uploaded successfully: {filepath}")


def upload_audio(comanda_id, filepath, duration):
    """Upload audio file to BLOB column."""
    with open(filepath, 'rb') as f:
        blob_data = f.read()
        cursor.execute("""
            INSERT INTO AudiosComanda (comanda_id, audio, durada_segons) 
            VALUES (:1, :2, :3)
        """, (comanda_id, blob_data, duration))
    print(f"Audio uploaded successfully: {filepath}")


def upload_xml(doc_id, filepath):
    """Upload XML document to XMLType column."""
    with open(filepath, 'r', encoding='utf-8') as f:
        xml_content = f.read()
        cursor.execute("""
            INSERT INTO DocumentsXML (id, xml_data) 
            VALUES (:1, XMLType(:2))
        """, (doc_id, xml_content))
    print(f"XML document uploaded successfully: {filepath}")


def display_stored_sizes():
    """Display the sizes of stored files using DBMS_LOB."""
    # Image sizes
    cursor.execute("SELECT DBMS_LOB.getlength(imatge) FROM ImatgesProducte")
    results = cursor.fetchall()
    print("\n--- Stored Image Sizes ---")
    for size in results:
        print(f"  - {size[0]:,} bytes")

    # Audio sizes
    cursor.execute("SELECT DBMS_LOB.getlength(audio) FROM AudiosComanda")
    results = cursor.fetchall()
    print("\n--- Stored Audio Sizes ---")
    for size in results:
        print(f"  - {size[0]:,} bytes")

# =============================================================================
# UPLOAD MULTIMEDIA FILES
# =============================================================================

print("\n--- Uploading multimedia files ---")
upload_image(99, "assets/archivos/macarrones.jpg", "Product image")
upload_audio(108, "assets/archivos/silbido.mp3", 35)
upload_xml(85, "assets/archivos/pruebaxml.xml")

conn.commit()

# =============================================================================
# VERIFY STORAGE
# =============================================================================

display_stored_sizes()

# =============================================================================
# CLEANUP
# =============================================================================

cursor.close()
conn.close()
print("\nConnection closed.")
print("Multimedia upload complete.")
