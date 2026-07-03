# Dynamic Flexible Pricing Tiers

The current implementation hardcodes the 'Sheet' tier for Tablets/Capsules and strictly enforces a 'Pack' tier across all products. As you pointed out, this creates problems if a user wants to delete a tier, or if they add a Custom Product Type that requires a mid-level tier (like a 'Box' of Syrups).

## Proposed Changes

### 1. Make Pricing Tiers Optional (`add_edit_product_screen.dart`)
- **Unhide the Middle Tier**: Show the three inputs (Unit, Middle-Tier (Sheet/Strip/Box), Pack) for **all** product types, not just Tablets.
- **Dynamic Labels**: Instead of hardcoding "Sheet", we can label it "Secondary Unit (e.g. Sheet/Box)" so it makes sense for custom product types.
- **Optional Fields**: If a user leaves a price field empty, it will not be saved into the JSON block. 
- **Auto-calculate Fix**: The auto-calculate listener will only fill in the values once when the Unit price is first entered. If the user subsequently clears the Pack price, it will stay cleared.

### 2. Dynamic Cart Selection (`new_sale_screen.dart` & `checkout_screen.dart`)
- Update the pricing dropdown in the POS Cart to **only** display the tiers that actually exist in the product's `pricingJson`.
- If a product only has a 'Unit' price, the dropdown will just lock to 'Unit' and hide the other options.

### 3. Receipt Composer (`receipt_composer.dart`)
- Ensure the receipt generator gracefully handles products that don't have Pack or Sheet prices.

Does this flexible approach sound good to you?
