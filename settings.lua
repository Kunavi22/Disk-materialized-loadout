dofile( "data/scripts/lib/mod_settings.lua" )

local mod_id = "disk_materialized_loadout"

mod_settings_version = 1

mod_settings =
{
	{
		id = "start_with_loadout",
		ui_name = "Start with bomb materializer loadout",
		ui_description = "Replace the normal starting items with the Disc Materialized test loadout.",
		value_default = true,
		scope = MOD_SETTING_SCOPE_NEW_GAME,
	},
	{
		id = "include_disc_projectile",
		ui_name = "Include disk projectile to loadout",
		ui_description = "Start with Disc Projectile in the item inventory.",
		value_default = true,
		scope = MOD_SETTING_SCOPE_NEW_GAME,
	},
	{
		id = "include_bomb_or_dynamite",
		ui_name = "Include bomb/dynamite to loadout",
		ui_description = "Start with either Bomb or Dynamite, chosen randomly.",
		value_default = true,
		scope = MOD_SETTING_SCOPE_NEW_GAME,
	},
	{
		id = "include_water_potion",
		ui_name = "Include starting potion to loadout",
		ui_description = "Start with a water potion.",
		value_default = false,
		scope = MOD_SETTING_SCOPE_NEW_GAME,
	},
	{
		id = "bags_of_many_big_universal_bag",
		ui_name = "Include big universal bag to loadout (Requires Bags Of Many mod).",
		ui_description = "Start with a big universal bag.",
		value_default = false,
		scope = MOD_SETTING_SCOPE_NEW_GAME,
	},
}

local function update_loadout_setting_visibility()
	local start_with_loadout = ModSettingGetNextValue( mod_id .. ".start_with_loadout" )

	if start_with_loadout == nil then
		start_with_loadout = true
	end

	for i = 2, 4 do
		mod_settings[i].hidden = not start_with_loadout
	end

	mod_settings[5].hidden = not start_with_loadout
end

function ModSettingsUpdate( init_scope )
	mod_settings_update( mod_id, mod_settings, init_scope )
end

function ModSettingsGuiCount()
	update_loadout_setting_visibility()
	return mod_settings_gui_count( mod_id, mod_settings )
end

function ModSettingsGui( gui, in_main_menu )
	update_loadout_setting_visibility()
	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
end
