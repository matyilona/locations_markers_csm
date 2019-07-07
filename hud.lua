-- Mange HUD markers
-- =================
local player = minetest.localplayer
local display_markers = true

--- Toggle markers

local function toggle( locations )
	display_markers = not display_markers
	if not display_markers then
		for i,loc in ipairs( locations ) do
			player:hud_change( loc.hud_id, "text", string.format( "%s^[opacity:0", loc.markertext ) )
		end
	end
	local state = "OFF"
	if display_markers then state = "ON" end
	log( "Toggled marker display, now: "..state )
end

--- Update one hud element

local function update_one( loc )
	local pos = player:get_pos()
	local dist = vector.distance( pos, loc.pos )
	if dist < 3 or dist > 200 then
		player:hud_change( loc.hud_id, "text", string.format( "%s^[opacity:0", loc.markertext ) )
		return
	end
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
	player:hud_change( loc.hud_id, "text", string.format( "%s^[opacity:%3d", loc.markertext, (255-normd_screen_dist)/2+64 ) )
	if screen_dist < .08 then
		player:hud_change( loc.hud_id, "text", string.format( "%s^[opacity:%3d", loc.markertext, (255-normd_screen_dist)/2 ) )
	end
	local scale = math.max( 0.5, 5*math.log(3)/math.log(dist) + math.max(0,30/dist-5) )
	player:hud_change( loc.hud_id, "position", { x=.5+hdists/math.pi/2, y=.5-vdists/math.pi }  )
	player:hud_change( loc.hud_id, "scale", { x=scale, y=scale }  )
end

-- Update all hud elements

local function update_all( locations )
	if not display_markers then return end

	--display all markers
	for i,loc in ipairs( locations ) do
		update_one( loc )
	end
end

-- Delete all hud elements

local function del_all( locations )
	for i, loc in ipairs( locations ) do
		player:hud_remove( loc.hud_id )
	end
end

return( { toggle=toggle, update=update_all, del_all=del_all } )
