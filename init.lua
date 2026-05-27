local disc_projectile = ModTextFileGetContent( "data/entities/projectiles/deck/disc_bullet.xml" )

if disc_projectile ~= nil then
	disc_projectile = disc_projectile:gsub(
		'(speed_min=")([%d%.]+)(")',
		function( prefix, value, suffix )
			return prefix .. tostring( tonumber( value ) * 0.5 ) .. suffix
		end
	)
	disc_projectile = disc_projectile:gsub(
		'(speed_max=")([%d%.]+)(")',
		function( prefix, value, suffix )
			return prefix .. tostring( tonumber( value ) * 0.5 ) .. suffix
		end
	)

	ModTextFileSetContent(
		"mods/disk_materialized_loadout/files/entities/projectiles/disc_bullet_materialized.xml",
		disc_projectile
	)
end

ModLuaFileAppend(
	"data/scripts/gun/gun_actions.lua",
	"mods/disk_materialized_loadout/files/scripts/perks/bombs_materialized_append.lua"
)

dofile_once( "data/scripts/perks/perk.lua" )

local function get_setting( setting_id, default_value )
	local value = ModSettingGet( "disk_materialized_loadout." .. setting_id )

	if value == nil then
		return default_value
	end

	return value
end

local function is_bags_of_many_enabled()
	if ModIsEnabled ~= nil then
		return ModIsEnabled( "bags_of_many" )
	end

	if ModDoesFileExist ~= nil then
		return ModDoesFileExist( "mods/bags_of_many/files/entities/bags/bag_universal_big.xml" )
	end

	return false
end

local function find_child_by_name( entity_id, child_name )
	local children = EntityGetAllChildren( entity_id )

	if children ~= nil then
		for _, child in ipairs( children ) do
			if EntityGetName( child ) == child_name then
				return child
			end
		end
	end

	return nil
end

local function add_action_to_inventory( inventory, action_id, x, y )
	local item = CreateItemActionEntity( action_id, x, y )

	if item ~= nil then
		EntityAddChild( inventory, item )
	end
end

local function add_entity_to_inventory( inventory, entity_file, x, y )
	local item = EntityLoad( entity_file, x, y )

	if item ~= nil and item ~= 0 then
		EntityAddChild( inventory, item )
	end
end

function OnPlayerSpawned( player_entity )
	local init_check_flag = "disk_materialized_loadout_done"

	if GameHasFlagRun( init_check_flag ) then
		return
	end

	if not get_setting( "start_with_loadout", true ) then
		return
	end

	GameAddFlagRun( init_check_flag )

	local x, y = EntityGetTransform( player_entity )
	local inventory = find_child_by_name( player_entity, "inventory_quick" )

	if inventory ~= nil then
		local inventory_items = EntityGetAllChildren( inventory )

		if inventory_items ~= nil then
			for _, item in ipairs( inventory_items ) do
				GameKillInventoryItem( player_entity, item )
			end
		end
	end

	local perk_entity = perk_spawn( x, y, "ABILITY_ACTIONS_MATERIALIZED" )

	if perk_entity ~= nil then
		perk_pickup( perk_entity, player_entity, EntityGetName( perk_entity ), false, false )
	end

	if inventory ~= nil then
		SetRandomSeed( x + 177, y - 319 )

		if get_setting( "include_disc_projectile", true ) then
			add_action_to_inventory( inventory, "DISC_BULLET", x, y )
		end

		if get_setting( "include_bomb_or_dynamite", true ) then
			if Random( 1, 2 ) == 1 then
				add_action_to_inventory( inventory, "BOMB", x, y )
			else
				add_action_to_inventory( inventory, "DYNAMITE", x, y )
			end
		end

		if get_setting( "include_water_potion", false ) then
			add_entity_to_inventory( inventory, "data/entities/items/pickup/potion_starting.xml", x, y )
		end

		if is_bags_of_many_enabled() and get_setting( "bags_of_many_big_universal_bag", false ) then
			add_entity_to_inventory( inventory, "mods/bags_of_many/files/entities/bags/bag_universal_big.xml", x, y )
		end
	end
end
