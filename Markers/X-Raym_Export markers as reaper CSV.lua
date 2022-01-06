--[[
 * ReaScript Name: Export markers as reaper CSV
 * About: Use with X-Raym REAPER import markers script from CSV
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
 * v1.0 (2021-01-06)
  + Initial Release
--]]


-- USER CONFIG AREA ---------------------------------------
time_offset = 0 -- 0, 3600 if timeline starts at 01:00:00
----------------------------------- END OF USER CONFIG AREA


function GetSecondsFromFrame( pos, fps )
	local seconds = pos/fps
	return seconds
end


print("-------------------------")

resolve = Resolve()
pm = resolve:GetProjectManager()
proj = pm:GetCurrentProject()
tl = proj:GetCurrentTimeline()
markers = tl:GetMarkers()

positions = {}
for k, marker in pairs( markers ) do
	table.insert(positions, k)
end

table.sort( positions )

fps = proj:GetSetting("timelineFrameRate")

print("Type\tName\tPos_Start\tPos_End")

for i, pos in ipairs(positions) do
	local marker = markers[pos]
	position = GetSecondsFromFrame( pos, fps ) + time_offset
	local t = {
		"M" .. i,
		marker.name,
		position,
		position
	}
	print( table.concat( t, "\t" ) )
end