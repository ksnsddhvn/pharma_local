import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Find TextField( or TextFormField( and insert textCapitalization: TextCapitalization.none, if not already there
    # It might be spread across lines, but usually the opening parenthesis is on the same line as the class name.
    
    # We'll use regex to match TextField( or TextFormField(
    # and insert textCapitalization: TextCapitalization.none, right after the opening parenthesis.
    
    new_content = re.sub(r'(TextField|TextFormField)\(', r'\1(\ntextCapitalization: TextCapitalization.none,', content)
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

