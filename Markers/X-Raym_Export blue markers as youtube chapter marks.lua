--[[
 * ReaScript Name: Export blue markers as youtube chapter marks
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

print("-------------------------")

function AddLeadingZeros( int )
	return string.format("%02d", tostring(int) )
end

function GetTimeCodeFromFrame( pos, fps )
	local m, s, f = "00", "00", "00"
	local seconds = pos/framerate
	m = AddLeadingZeros(math.floor(seconds/60))
	s = AddLeadingZeros(math.floor(seconds % 60))
	return m .. ":" .. s
end

resolve = Resolve()
pm = resolve:GetProjectManager()
proj = pm:GetCurrentProject()
tl = proj:GetCurrentTimeline()
markers = tl:GetMarkers()

framerate = proj:GetSetting("timelineFrameRate")

positions = {}
for k, marker in pairs( markers ) do
	table.insert(positions, k)
end

table.sort( positions )

for i, pos in ipairs(positions) do
	local marker = markers[pos]
	if marker.color == "Blue" then
		print( GetTimeCodeFromFrame( pos, framerate ) .. " " .. marker.name)
	end
end