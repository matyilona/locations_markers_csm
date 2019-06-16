local mod_storage = minetest.get_mod_storage()
local player = minetest.localplayer
local old_locations = minetest.deserialize( mod_storage:get_string( "locations" ) )
if old_locations == nil then old_locations = {} end
local locations = {}
local DISPLAY_MARKERS = false
local keys = 0

function add_location( pos )
	local hud_id = player:hud_add({
				hud_elem_type = "image",
				position = { x = .5, y = .5 },
				text = "locations_markers_csm_textures_marker.png^[opacity:0",
				scale = {x=3,y=3},
			})
	locations[ #locations + 1 ] = { pos = pos, hud_id = hud_id }
	mod_storage:set_string( "locations", minetest.serialize( locations ) )
	minetest.log( dump( locations ) )
end

for i,loc in ipairs( old_locations ) do
	add_location( loc.pos )
end

minetest.register_globalstep( function( dtime )

	--registering keys
	local new_keys = player:get_key_pressed()
	local new = not (new_keys==keys)
	local pos = player:get_pos()
	if (keys == 12+128) and new then
		minetest.log( "Toggled markers" )
		DISPLAY_MARKERS = not DISPLAY_MARKERS
		for i,loc in ipairs( locations ) do
			player:hud_change( loc.hud_id, "text", "locations_markers_csm_textures_marker.png^[opacity:0" )
		end
	end
	if (keys == 3+128) and new then
		minetest.log( "New location set" )
		add_location( pos )
	end
	keys = new_keys

	if not DISPLAY_MARKERS then return end

	--getting positions, if not close
	for i,loc in ipairs( locations ) do
		local dist = vector.distance( pos, loc.pos )
		local dir = vector.direction( pos, loc.pos )
		local htarget = math.atan2( dir.z, dir.x )
		local vtarget = math.atan2( dir.y, math.sqrt( dir.x*dir.x+dir.z*dir.z) )
		local hlook = player:get_last_look_horizontal() % (math.pi*2) - math.pi
		local vlook = player:get_last_look_vertical()
		local hdists = ( hlook - htarget ) % (math.pi*2) - math.pi
		local hdist =  math.abs( hdists )
		local vdists = (vtarget-vlook) / 2
		local vdist = math.abs( vdists )
		local screen_dist = (hdist+vdist)/math.pi
		local normd_screen_dist = math.floor( screen_dist/1.25*255 )
		player:hud_change( loc.hud_id, "text", string.format( "locations_markers_csm_textures_marker.png^[colorize:#FF2000:64^[opacity:%3d", (255-normd_screen_dist)/2+64 ) )
		if screen_dist < .08 then
			player:hud_change( loc.hud_id, "text", string.format( "locations_markers_csm_textures_marker.png^[colorize:#FF2000:64^[opacity:%3d", (255-normd_screen_dist)/2 ) )
		end
		local scale = math.max( 0.5, 5*math.log(3)/math.log(dist) + math.max(0,30/dist-5) )
		player:hud_change( loc.hud_id, "position", { x=.5+hdists/math.pi/2, y=.5-vdists/math.pi }  )
		player:hud_change( loc.hud_id, "scale", { x=scale, y=scale }  )
		if dist < 3 then
			player:hud_change( loc.hud_id, "text", "locations_markers_csm_textures_marker.png^[opacity:0" )
		end
	end
end )

minetest.register_on_shutdown( function()
	mod_storage:set_string( "locations", minetest.serialize( locations ) )
end )


