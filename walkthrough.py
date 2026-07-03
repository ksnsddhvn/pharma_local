with open('walkthrough.md', 'r') as f:
    content = f.read()

new_block = """## 6. Flexible Dynamic Pricing Tiers
- **Optional Tiers:** In `add_edit_product_screen.dart`, all pricing tiers (Unit, Secondary, Pack) are now entirely optional. Leaving a tier blank excludes it from the product configuration without forcing a 0 value.
- **Universal Tiers:** The 'Secondary/Sheet' middle tier is no longer hardcoded to Tablets/Capsules. It is visible for all product types, supporting items like 'Boxes of Syrups'.
- **Dynamic Cart UI:** In `new_sale_screen.dart`, the cart pricing tier dropdown now dynamically constructs its options based *only* on the tiers you have populated for that specific product, creating a cleaner UI.

"""

content = content + "\n" + new_block

with open('walkthrough.md', 'w') as f:
    f.write(content)

