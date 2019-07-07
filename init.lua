local mod_name = minetest.get_current_modname()
function log( msg )
	minetest.log( "action", string.format( "[%s]: %s", mod_name, msg ) )
end

log( 'Started as "'..mod_name..'"' )


-- Setting up mod-global variables


local locs = dofile( "locations_markers_csm:locations.lua" )

local locations = locs.load_from_modstorage( "locations" )

local hud = dofile( "locations_markers_csm:hud.lua" )

local formspec = dofile( "locations_markers_csm:formspec.lua" )

-- Formspec input, monitoring keys
-- ===============================

local keys = 0
local player = minetest.localplayer
minetest.register_globalstep( function( dtime )

	--registering key presses
	local new_keys = player:get_key_pressed()
	local new = not (new_keys==keys)
	--A+D+left_mouse
	if (keys == 12+128) and new then
		hud.toggle( locations )
	end
	--W+S+left_mouse
	local pos = player:get_pos()
	if (keys == 3+128) and new then
		formspec.show()
	end
	if (keys == 14) and new then
		log(dump(locations))
	end

	hud.update( locations )
	keys = new_keys

end )

--- Handling formspec input

minetest.register_on_formspec_input( function( formname, fields )
	if formname ~= "location_marker_main" then return end
	if fields.del_all ~= nil then
		hud.del_all( locations )
		locations = {}
		locs.store( locations )
	end
	if fields.del ~= nil then
		local j = 1
		local pos = player:get_pos()
		for i=1,#locations do
			local loc = locations[i]
			if vector.distance( pos, loc.pos ) < 3 then
				player:hud_remove( loc.hud_id )
				locations[ i ] = nil
			else
				if i ~= j then
					locations[j] = locations[i]
					locations[i] = nil
				end
				j = j+1
			end
		end

		locs.store( locations )
	end
	if fields.add ~= nil then
		pos = player:get_pos()
		log( "New location set at "..dump(pos) )
		locs.add( locations, pos, formspec.get_markertext() )
	end
end )
