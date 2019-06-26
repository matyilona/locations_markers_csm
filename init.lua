local mod_name = minetest.get_current_modname()
function log( msg )
	minetest.log( "action", string.format( "[%s]: %s", mod_name, msg ) )
end

local mod_storage = minetest.get_mod_storage()
local player = minetest.localplayer
local old_locations = minetest.deserialize( mod_storage:get_string( "locations" ) )
if old_locations == nil then old_locations = {} end
local locations = {}
local DISPLAY_MARKERS = true
local keys = 0

function add_location( pos, markertext )
	local hud_id = player:hud_add({
				hud_elem_type = "image",
				position = { x = .5, y = .5 },
				text = markertext,
				scale = {x=3,y=3},
			})
	locations[ #locations + 1 ] = { pos = pos, hud_id = hud_id, markertext = markertext }
	mod_storage:set_string( "locations", minetest.serialize( locations ) )
end

for i,loc in ipairs( old_locations ) do
	add_location( loc.pos, loc.markertext )
end

local marker_selected = 4

function show_formspec()
	local formspec = string.format(
	[===[

	size[3,3]
	background[-0.5,-0.4;4,4;locations_markers_csm_textures_bg1.png ]

	image_button_exit[1,1;1,1;locations_markers_csm_textures_OK.png^(locations_markers_csm_textures_marker%d.png^\[opacity:200);add;;;false;locations_markers_csm_textures_OK.png ]

	image_button[1,2;1,1;locations_markers_csm_textures_DEL.png;del;;true;false;locations_markers_csm_textures_DEL.png^(locations_markers_csm_textures_DEL_PUSH.png^\[opacity:200) ]

	image_button[0,1;1,1;locations_markers_csm_textures_arrowl.png;left;;true;false;locations_markers_csm_textures_arrowl.png^\[opacity:200 ]
	image_button[2,1;1,1;locations_markers_csm_textures_arrow.png;right;;true;false;locations_markers_csm_textures_arrow.png^\[opacity:200 ]

	]===],
	marker_selected)
	minetest.log( formspec )
	minetest.show_formspec( "posname", formspec )
end

function toggle_markers()
	DISPLAY_MARKERS = not DISPLAY_MARKERS
	for i,loc in ipairs( locations ) do
		player:hud_change( loc.hud_id, "text", string.format( "%s^[opacity:0", loc.markertext ) )
	end
	local state = "off"
	if DISPLAY_MARKERS then state = "on" end
	log( "Toggled markers. display: "..state )
end

minetest.register_on_formspec_input( function( formname, fields )
	minetest.log( dump(fields) )
	if fields.del == "" then
		for i, loc in ipairs( locations ) do
			player:hud_remove( loc.hud_id )
		end
		locations = {}
		mod_storage:set_string( "locations", minetest.serialize( locations ) )
	end
	if fields.add == "" then
		pos = player:get_pos()
		log( "New location set at "..dump(pos) )
		local markertext = string.format( "locations_markers_csm_textures_marker%d.png^[colorize:#FF2000:64", marker_selected )
		add_location( pos, markertext )
	end
	if fields.left == "" then
		marker_selected = math.fmod(marker_selected+1,5)
		show_formspec()
	end
	if fields.right == "" then
		marker_selected = math.fmod(marker_selected+4,5)
		show_formspec()
	end
	minetest.log( marker_selected )
end )

function update_hud( loc )
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

minetest.register_globalstep( function( dtime )

	--registering key presses
	local new_keys = player:get_key_pressed()
	local new = not (new_keys==keys)
	--A+D+left_mouse
	if (keys == 12+128) and new then
		toggle_markers()
	end
	--W+S+left_mouse
	local pos = player:get_pos()
	if (keys == 3+128) and new then
		show_formspec()
	end
	keys = new_keys

	--if display is disabled, we are done
	if not DISPLAY_MARKERS then return end

	--display all markers
	for i,loc in ipairs( locations ) do
		update_hud( loc )
	end
end )
