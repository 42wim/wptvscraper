--SD_Description=WeePee TV
--[[
 Authors: 42wim

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
--]]

require "simplexml"

function descriptor()
    return { title="WeePee TV" }
end

function main()
local tree = simplexml.parse_url("http://yourserver.url/wptv.xml")
	for _, items in ipairs( tree.children ) do
		simplexml.add_name_maps(items)
		local url = vlc.strings.resolve_xml_special_chars( items.children_map['h264'][1].children[1] )
		local title = vlc.strings.resolve_xml_special_chars( items.children_map['title'][1].children[1] )
		local arturl = vlc.strings.resolve_xml_special_chars( items.children_map['thumb'][1].children[1] )
		vlc.sd.add_item( { path = url, title = title , arturl = arturl } ) 
	end
end

