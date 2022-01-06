--[[
 * ReaScript Name: Export edit points from first tracks in timeline
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

resolve = Resolve()
pm = resolve:GetProjectManager()
proj = pm:GetCurrentProject()
tl = proj:GetCurrentTimeline()
items = tl:GetItemListInTrack("video", 1)

framerate = proj:GetSetting("timelineFrameRate")

for i, item in ipairs( items ) do
	pos = item:GetStart()/framerate
	print(pos)
end