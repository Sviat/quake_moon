/// ReProjectMoon-specific source file
/// Here go all entity fields introduced by Moon

/// Player
// Stats
.float gold;
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

// Items
.float wear_armor;
.float magic_typeone;
.float magic_typeone_value;
.string magic_prefixone;
.float magic_typetwo;
.float magic_typetwo_value;
.string magic_prefixtwo;
.float wear_ring;
.float ring_typeone;
.float ring_typeone_value;
.string ring_prefixone;
.float ring_typetwo;
.float ring_typetwo_value;
.string ring_prefixtwo;

.float mentat_offense_time;
.float mentat_defense_time;
.float mentat_attackspeed_time;

// Monster
.float prefix;
.float prefix_value;
.string prefix_one;
.string prefix_two;
.string prefix_three;
.string prefix_four;

// Status
.float lightning_chained_time; // target hit by chain lightning, should not prevent consequent chainings, only during same frame

// sort these
.float skl_expl; // no idea
.float natural_regen_cooldown;
.float natural_regen_value;
.float natural_regen_time;
.float magical_regen_time; // Magical cooldown is constant 1, and value is variable
.float mana_restore_time; // TODO: implement
