-- Managing locations
-- ==================

local mod_storage = minetest.get_mod_storage()
local player = minetest.localplayer

-- Save all locations to mod_storage

local function store( locations, storage_name )
	local storage_name = storage_name or "locations"
	mod_storage:set_string( storage_name, minetest.serialize( locations ) )
end

-- Add locations at position, with markertext

local function add( locations, pos, markertext )
	local hud_id = player:hud_add({
				hud_elem_type = "image",
				position = { x = .5, y = .5 },
				text = markertext,
				scale = {x=3,y=3},
			})
	locations[ #locations + 1 ] = { pos = pos, hud_id = hud_id, markertext = markertext }
	store( locations )
end

--- Loading locations from mod_storage

local function load_from_modstorage( storage_name )
	local storage_name = storage_name or "locations"
	minetest.log( storage_name )
	local locations = {}
	local old_locations = minetest.deserialize( mod_storage:get_string( storage_name ) )
	if old_locations == nil then old_locations = {} end

	for i,loc in ipairs( old_locations ) do
		add( locations, loc.pos, loc.markertext )
	end
	minetest.log( minetest.serialize(locations) )
	return( locations )
end

return( { add=add, store=store, load_from_modstorage=load_from_modstorage } )
