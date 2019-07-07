-- Formspec management
-- ===================

local marker_selected = 4
local color_selected = "FF0000"

--- Show main-menu formspec

local function show_formspec()
	local function color_button( x, y, color, name, colorize, push_opacity )
		local button_string = [===[

		image_button[%d,%d;1,1
		;locations_markers_csm_textures_color_border.png^(locations_markers_csm_textures_color_inside.png^\[colorize:#%s:%d);%s;
		;true;false;locations_markers_csm_textures_color_border.png^(locations_markers_csm_textures_color_inside.png^\[colorize:#%s:%d)^\[opacity:%d ]

		]===]
		return( string.format( button_string, x, y, color, colorize, name, color, colorize, push_opacity ) )
	end
	local formspec = string.format(
	[===[

	size[3,3]
	background[-0.5,-0.4;4,4;locations_markers_csm_textures_bg1.png ]

	image_button_exit[1,1;1,1;locations_markers_csm_textures_OK.png^(locations_markers_csm_textures_marker%d.png^\[colorize:#%s:%d^\[opacity:200);add;;;false;locations_markers_csm_textures_OK.png ]

	image_button_exit[0,2;1,1;locations_markers_csm_textures_DEL_ALL.png;del_all;;true;false;locations_markers_csm_textures_DEL_ALL.png^\[opacity:200 ]
	image_button_exit[2,2;1,1;locations_markers_csm_textures_DEL.png;del;;true;false;locations_markers_csm_textures_DEL.png^\[opacity:200 ]

	image_button[0,1;1,1;locations_markers_csm_textures_arrowl.png;left;;true;false;locations_markers_csm_textures_arrowl.png^\[opacity:200 ]
	image_button[2,1;1,1;locations_markers_csm_textures_arrow.png;right;;true;false;locations_markers_csm_textures_arrow.png^\[opacity:200 ]

	]===]..color_button( 0,0,"FF0000","red",120,200)..color_button( 1,0,"00FF00","green",120,200)..color_button( 2,0,"0000FF","blue",120,200),
	marker_selected, color_selected, 120 )
	minetest.show_formspec( "location_marker_main", formspec )
end

local function markertext()
	return( string.format( "locations_markers_csm_textures_marker%d.png^[colorize:#%s:120", marker_selected, color_selected ) )
end

minetest.register_on_formspec_input( function( formname, fields )
	if formname ~= "location_marker_main" then return end
	if fields.left ~= nil then
		marker_selected = math.fmod(marker_selected+1,5)
		show_formspec()
	end
	if fields.right ~= nil then
		marker_selected = math.fmod(marker_selected+4,5)
		show_formspec()
	end
	if fields.red ~= nil then
		color_selected = "FF0000"
		show_formspec()
	end
	if fields.green ~= nil then
		color_selected = "00FF00"
		show_formspec()
	end
	if fields.blue ~= nil then
		color_selected = "0000FF"
		show_formspec()
	end
end )

return( { show=show_formspec, get_markertext = markertext } )
