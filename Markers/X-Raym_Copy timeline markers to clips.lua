--[[
 * Resolve Script Name: Copy timeline markers to clips
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

-- NOTE: Inserting Media Item marker is Extra slow. + Not very handy for readability compared to timeline marker as it can be offscreen, especially if clips is locked.
resolve = Resolve()
pm = resolve:GetProjectManager()
proj = pm:GetCurrentProject()
tl = proj:GetCurrentTimeline()

markers = tl:GetMarkers()
items = tl:GetItemListInTrack("Audio", 1)

-- Sort marker by positions
positions = {}
for k, marker in pairs( markers ) do
	table.insert(positions, k)
end

table.sort( positions )

for i, item in ipairs( items ) do
	media_pool_item = item:GetMediaPoolItem()
	for i, pos in ipairs(positions) do
		local marker = markers[pos]
		retval = media_pool_item:AddMarker(pos, marker.color, marker.name, marker.note, marker.duration, marker.customData)
		print(retval)
	end
end

print("-------------------------")
print( "OUTPUT")


