--[[
 * Resolve Script Name: Color items on named track from colors CSV
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > DaVinci-Resolve-Scripts
 * Repository URI: https://github.com/X-Raym/DaVinci-Resolve-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0 (2022-01-12)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------------------------
track_name = "Sous-titre 1"
csv_colors = "#FF0000,#00FF00,#FFFF00"
separator = ","

-------------------------------- END OF USER CONFIG AREA --

-- CSV ----------------------------------------------------
function ParseCSVLine( str )
    local t = {}
    local i = 0
    for line in str:gmatch("[^" .. separator .. "]*") do
        i = i + 1
        t[i] = line
    end
    return t
end

--------------------------------------------- END OF CSV --

-- COLORS -------------------------------------------------
------------------------------------------------------------------
-- COLOR FUNCTIONS
-- ---------------
--[[
 * Converts an RGB color value to HSL. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes r, g, and b are contained in the set [0, 255] and
 * returns h, s, and l in the set [0, 1].
 *
 * @param   Number  r       The red color value
 * @param   Number  g       The green color value
 * @param   Number  b       The blue color value
 * @return  Array           The HSL representation
]]
function rgbToHsl(r, g, b, a)
  r, g, b = r / 255, g / 255, b / 255

  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l

  l = (max + min) / 2

  if max == min then
    h, s = 0, 0 -- achromatic
  else
    local d = max - min
    if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
    if max == r then
      h = (g - b) / d
      if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h, s, l, a or 255
end

color_names = {}
color_names[28] = "Orange"
color_names[34] = "Apricot"
color_names[43] = "Yellow"
color_names[73] = "Lime"
color_names[89] = "Olive"
color_names[146] = "Green"
color_names[180] = "Teal"
color_names[198] = "Navy"
color_names[207] = "Blue"
color_names[291] = "Purple"
color_names[333] = "Violet"
color_names[334] = "Pink"
-- following colors removed because too close of existing hue
-- this would benefit for an algorithm witch check hue AND saturation/luma
--[[color_names[44] = Tan
color_names[31] = Beige
color_names[40] = Brown
color_names[21] = Chocolate
]]

function minTableKey( array, key )
  local min = math.huge
  local key = ""
  for k, v in pairs( array ) do
    if v < min then
      min = v
      key = k
    end
  end
  return key, min
end

function GetClosestColorNameByHue( hue )
  local name = ''
  local diffs = {}
  for k, v in pairs(color_names) do
    diffs[k] = math.abs( k - hue )
  end
  local k, min = minTableKey(diffs)
  return color_names[k]
end

function HexToRGB( hex )
  local hex = string.gsub(hex,"#","")
  local R = tonumber("0x"..hex:sub(1,2))
  local G = tonumber("0x"..hex:sub(3,4))
  local B = tonumber("0x"..hex:sub(5,6))
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
track_types =  { "audio", "video", "subtitle" }
local out_track_type, out_track_index
for i, track_type in ipairs( track_types ) do
    tracks_count = tl:GetTrackCount(track_type)
    for id = 1, tracks_count do
        temp_track_name = tl:GetTrackName(track_type, id)
        if track_name == temp_track_name then
            out_track_index = id
            out_track_type = track_type
            break
        end
    end
end

if not out_track_index then
    print( "No track with this name.")
    return false
end  

items = tl:GetItemListInTrack(out_track_type, out_track_index)

if #items == 0 then
    print( "No item on track or no track with this name.")
    return false
end

colors = ParseCSVLine( csv_colors )

if #colors == 0 then
    print( "No colors.")
    return false
end

color_named = {}
for i, color in ipairs( colors ) do
    print(color)
    local R, G, B = HexToRGB( color )
    if R and G and B then
        local h, s, l = rgbToHsl( R, G, B )
        local acolor_HSL = {h * 360, s * 255, l * 255} -- 241 ?
        local color_name = GetClosestColorNameByHue(acolor_HSL[1] )
        print(color_name)
        table.insert(color_named, color_name)
    end
end

for i, item in ipairs( items ) do
    -- print(item:GetName())
    -- print("color_names[] = \"" .. item:GetClipColor() .. "\"")
	  if color_named[i] then
        item:SetClipColor(color_named[i])
        print(item:GetName() .. "\t" .. color_named[i])
    end
end

print("-------------------------")

