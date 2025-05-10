/// ReProjectMoon-specific source file
/// Here go all entity fields introduced by Moon

/// Player
// Stats
.float gold;        // Held currency
.float exp;         // Experience points
.float lvl;         // Level
.float point;       // Free skill points
.float stre;        // Strength
.float vit;         // Vitality
.float wiz;         // Sanity; recovered in KEK port;
.float intu;        // Intuition; new stat in KEK port; naming kept in line with original

.float up_axe;      // Re-use same param for both Upgrade and Extra damage
.float up_bullet;   // Re-use same param for both Upgrade and Extra capacity
.float up_nail;     // Re-use same param for both Upgrade and Extra capacity
.float up_rocket;   // Re-use same param for both Upgrade and Extra capacity
.float up_cell;     // Re-use same param for both Upgrade and Extra capacity

/// Items
// Magical wearables
.float wear_armor;          // Flag, true - if magical armour equipped
.float magic_rarity_level;  // Total rarity of both effects
.float magic_typeone;       // (Prefix) Effect code
.float magic_typeone_value; // Effect power
.string magic_prefixone;    // Effect display name
.float magic_typetwo;       // (Postfix) Effect code
.float magic_typetwo_value; // Effect power
.string magic_prefixtwo;    // Effect display name

.float wear_ring;           // Flag, true - if magical ring equipped
.float ring_rarity_level;   // Total rarity of both effects
.float ring_typeone;        // (Prefix) Effect code
.float ring_typeone_value;  // Effect power
.string ring_prefixone;     // Effect display name
.float ring_typetwo;        // (Postfix) Effect code
.float ring_typetwo_value;  // Effect power
.string ring_prefixtwo;     // Effect display name

// Mentats (see Fallout)
.float mentat_offense_time;     // End time of Offensive drug
.float mentat_defense_time;     // End time of Defensive drug
.float mentat_attackspeed_time; // End time of Accelartive drug

/// Monster
.float prefix;              // Special monster type code (actually can be seen as postfix in name)
.float prefix_value;        // Special effect power
.string prefix_one;         // Prefix (.ability or level)
.string prefix_two;         // Prefix (.ability or level)
.string prefix_three;       // Postfix (.prefix)
.string prefix_four;        // Postfix (??)

// Status
.float lightning_chained_time;  // target hit by chain lightning, should not prevent consequent chainings, only during same frame
.float magical_repair_time;     // next time magical repair of physical Armor happens
.float armor_damaged_time;      // last time physical Armor was damaged
.float magical_recharge_time;   // next time magical Cells recharge happens
.float cells_used_time;         // last time Cells were used

// sort these
.float skl_expl; // no idea
.float natural_regen_cooldown;
.float natural_regen_value;
.float natural_regen_time;
.float magical_regen_time; // Magical cooldown is constant 1, and value is variable
.float mana_restore_time; // TODO: implement
