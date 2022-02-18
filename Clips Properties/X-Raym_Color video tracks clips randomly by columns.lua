--[[
 * Resolve Script Name: Color video track clips randomly by columns
 * Screenshot: https://i.imgur.com/0CcxPzV.gif
 * About: Use this with the Select clips by color feature on a sets of deactivated clips and you will have instant multitracks editing
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
 * v1.0 (2022-01-27)
  + Initial Release
--]]

colors = { "Orange", "Apricot", "Yellow", "Lime", "Olive", "Green", "Teal", "Navy", "Blue", "Purple", "Violet", "Pink", "Tan", "Beige", "Brown", "Chocolate" }

-- Rotate Table
function RotateTable( array, shift ) -- Works for array with consecutive entries
  shift = shift or 1 -- make second arg optional, defaults to 1
  if shift > 0 then
    for i = 1, math.abs(shift) do
      table.insert( array, 1, table.remove( array, #array ) )
    end
  else
    for i = 1, math.abs(shift) do
      --table.insert( array, 1, table.remove( array, #array ) )
      table.insert( array, #array, table.remove( array, 1 ) )
    end
  end
end

-- SHUFFLE TABLE FUNCTION
-- from Tutorial: How to Shuffle Table Items by Rob Miracle
-- https://coronalabs.com/blog/2014/09/30/tutorial-how-to-shuffle-table-items/
math.randomseed( os.time() )
local function ShuffleTable( t )
  local rand = math.random

  local iterations = #t
  local w

  for z = iterations, 2, -1 do
    w = rand(z)
    t[z], t[w] = t[w], t[z]
  end
end

ShuffleTable( colors ) -- Colors are sorted by hue by default, not very contrasty

resolve = Resolve()
pm = resolve:GetProjectManager()
proj = pm:GetCurrentProject()
tl = proj:GetCurrentTimeline()
fps = tl:GetSetting("timelineFrameRate")

pos_items = {}

track_types = { "video" }
for i, track_type in ipairs( track_types ) do
  tracks_count = tl:GetTrackCount(track_type)
  for id = 1, tracks_count do
    items = tl:GetItemListInTrack(track_type, id)
    for i, item in ipairs(items) do
      pos = item:GetStart()
      if not pos_items[pos] then pos_items[pos] = {} end
      table.insert( pos_items[pos], item )
    end
  end
end

sorted_positions = {}
max_items_in_col = 0
for pos, items in pairs( pos_items ) do
  table.insert(sorted_positions, pos)
  max_items_in_col = math.max( max_items_in_col, #items )
end
if max_items_in_col == 0 then return end


table.sort( sorted_positions )

ids = {}
for i = 1, max_items_in_col do
  table.insert( ids, i )
end

print( "Max items on a column:" .. max_items_in_col )

for i, pos in ipairs( sorted_positions ) do
  print("--------\n", pos)
  RotateTable( ids, math.random(1, #ids-1) ) -- This prevent having consecutive colors on any tracks
  print( table.concat(ids, " - " ) )
  for j, item in ipairs( pos_items[pos] ) do
    if j >= #colors then break end -- Artificial limit
    print( item:GetName() .. " = " .. colors[ids[j]] )
    item:SetClipColor( colors[ids[j]] )
  end
end