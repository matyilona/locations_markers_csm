local player = minetest.localplayer
local locations = {}
local DISPLAY_MARKERS = false
local hud_id = player:hud_add({
			hud_elem_type = "image",
			position = { x = .5, y = .5 },
			text = "locations_markers_csm_textures_marker.png^[opacity:0",
			scale = {x=3,y=3},
		})
local keys = 0
local target = vector.new(player:get_pos())

minetest.register_globalstep( function( dtime )

	--registering keys
	local new_keys = player:get_key_pressed()
	local new = not (new_keys==keys)
	local pos = player:get_pos()
	if (keys == 12+128) and new then
		minetest.log( "Toggled" )
		GOING = not GOING
		player:hud_change( hud_id, "text", "locations_markers_csm_textures_marker.png^[opacity:0" )
	end
	if (keys == 3+128) and new then
		minetest.log( "New target set" )
		target = pos
	end
	keys = new_keys

	--getting positions, if not close
	local dist = vector.distance( pos, target )
	if dist < 3 then
		player:hud_change( hud_id, "text", "locations_markers_csm_textures_marker.png^[opacity:0" )
		return
	end
	local dir = vector.direction( player:get_pos(), target )
	local htarget = math.atan2( dir.z, dir.x )
	local vtarget = math.atan2( dir.y, math.sqrt( dir.x*dir.x+dir.z*dir.z) )
	if not GOING then return end
	local hlook = player:get_last_look_horizontal() % (math.pi*2) - math.pi
	local vlook = player:get_last_look_vertical()
	local hdists = ( hlook - htarget ) % (math.pi*2) - math.pi
	local hdist =  math.abs( hdists )
	local vdists = (vtarget-vlook) / 2
	local vdist = math.abs( vdists )
	local screen_dist = (hdist+vdist)/math.pi
	local normd_screen_dist = math.floor( screen_dist/1.25*255 )
	if screen_dist < .08 then
		--minetest.log( "Inside" )
	end
	local scale = math.max( 0.5, 5*math.log(3)/math.log(dist) + math.max(0,30/dist-5) )
	minetest.log( dump( {scale, math.max(30/dist-5,0), math.max(30/dist-5,0)/scale*100} ) )
	player:hud_change( hud_id, "position", { x=.5+hdists/math.pi/2, y=.5-vdists/math.pi }  )
	player:hud_change( hud_id, "scale", { x=scale, y=scale }  )
	player:hud_change( hud_id, "text", string.format( "locations_markers_csm_textures_marker.png^[colorize:#FF2000:64^[opacity:%3d", (255-normd_screen_dist)/2+64 ) )
end )


minetest.log( "::>" ..dump( a ).."<--" )
