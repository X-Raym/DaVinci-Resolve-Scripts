--[[
 * Resolve Script Name: Color subtitles items from colors CSV in first clip name
 * Screenshot: https://i.imgur.com/hAZq8Gm.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > DaVinci-Resolve-Scripts
 * Repository URI: https://github.com/X-Raym/DaVinci-Resolve-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2022-01-13)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------------------------
separator = ","

-------------------------------- END OF USER CONFIG AREA --

-- GLOBALS ------------------------------------------------

-- List of colors form DaVinci Resolve Clips
color_names = {}
color_names[1]  =  { name = "Orange",    r = 235, g = 110, b =   0, hex = "#EB6E00" }
color_names[2]  =  { name = "Apricot",   r = 255, g = 168, b =  51, hex = "#FFA833" }
color_names[3]  =  { name = "Yellow",    r = 226, g = 169, b =  28, hex = "#E2A91C" }
color_names[4]  =  { name = "Lime",      r = 159, g = 198, b =  21, hex = "#9FC615" }
color_names[5]  =  { name = "Olive",     r =  94, g = 153, b =  32, hex = "#5E9920" }
color_names[6]  =  { name = "Green",     r =  68, g = 143, b = 100, hex = "#448F64" }
color_names[7]  =  { name = "Teal",      r =   0, g = 152, b = 153, hex = "#009899" }
color_names[8]  =  { name = "Navy",      r =  21, g =  98, b = 132, hex = "#156284" }
color_names[9]  =  { name = "Blue",      r =  67, g = 118, b = 161, hex = "#4376A1" }
color_names[10] =  { name = "Purple",    r = 153, g = 115, b = 160, hex = "#9973A0" }
color_names[11] =  { name = "Violet",    r = 208, g =  87, b = 141, hex = "#D0578D" }
color_names[12] =  { name = "Pink",      r = 233, g = 140, b = 181, hex = "#E98CB5" }
color_names[13] =  { name = "Tan",       r = 185, g = 176, b = 151, hex = "#B9B097" }
color_names[14] =  { name = "Beige",     r = 198, g = 160, b = 119, hex = "#C6A077" }
color_names[15] =  { name = "Brown",     r = 153, g = 102, b =   0, hex = "#996600" }
color_names[16] =  { name = "Chocolate", r = 140, g =  90, b =  63, hex = "#8C5A3F" }

-- test string:
-- #EB6E00,#FFA833,#E2A91C,#9FC615,#5E9920,#448F64,#009899,#156284,#4376A1,#9973A0,#D0578D,#E98CB5,#B9B097,#C6A077,#996600,#8C5A3F

------------------------------------------- END OF COLORS --

-- CSV ----------------------------------------------------
function ParseCSVLine( str )
    local t = {}
    local i = 0
    for line in str:gmatch("[^" .. separator .. "]*") do
        i = i + 1
        t[i] = line
    end
    if t[#t] == "" then t[#t] = nil end
    return t
end

--------------------------------------------- END OF CSV --

-- COLORS -------------------------------------------------
function GetClosestColorRGB(r,g,b)
    local closest_color
    local min_diff = math.huge
    for i, color in ipairs(color_names) do
        color_diff = math.sqrt((color.r-r)^2 + (color.g-g)^2 + (color.b-b)^2)
        -- print(color.name .. " " .. color_diff)
        if color_diff < min_diff then
            min_diff = color_diff
            closest_color = color
        end
    end
    return closest_color
end

function HexToRGB( hex )
  local hex = string.gsub(hex,"#","")
  local R = tonumber("0x" .. hex:sub(1,2))
  local G = tonumber("0x" .. hex:sub(3,4))
  local B = tonumber("0x" .. hex:sub(5,6))
  return R, G, B
end

------------------------------------------ END OF COLORS --

print("-------------------------")

-- NOTE: Inserting Media Item marker is Extra slow. + Not very handy for readability compared to timeline marker as it can be offscreen, especially if clips is locked.
resolve = Resolve()
pm = resolve:GetProjectManager()
proj = pm:GetCurrentProject()
tl = proj:GetCurrentTimeline()

-- Get Track by Name, no matter the type
-- track_types =  { "audio", "video", "subtitle" }
track_types = { "subtitle" }
local out_track_type, out_track_index
for i, track_type in ipairs( track_types ) do
    tracks_count = tl:GetTrackCount(track_type)
    for id = 1, tracks_count do
        --temp_track_name = tl:GetTrackName(track_type, id)
        temp_items = tl:GetItemListInTrack(track_type, id)
        if #temp_items > 0 then
            name = temp_items[1]:GetName() -- first item
            csv_colors = string.match( name, "(#.+)" )
            if csv_colors then
                items = temp_items
                break
            end
        end
    end
end

if not csv_colors then
    print( "No colors CSV found. Put them on first subtitle item.")
    return false
end

colors = ParseCSVLine( csv_colors )

if #colors == 0 then
    print( "No colors.")
    return false
end

colors_named = {}
for i, color in ipairs( colors ) do
    print(color)
    local R, G, B = HexToRGB( color )
    if R and G and B then
        local color_name = GetClosestColorRGB( R, G, B )
        print(color_name.name)
        table.insert(colors_named, color_name.name)
    end
end

for i, item in ipairs( items ) do
    if i > #colors_named then break end
    print("--")
    -- print(item:GetName())
    -- print("color_names[] = \"" .. item:GetClipColor() .. "\"")
    if colors_named[i] then
        item:SetClipColor(colors_named[i])
        print(i .. ". " .. item:GetName() .. " → " .. colors_named[i])
    end
end

print("-------------------------")

