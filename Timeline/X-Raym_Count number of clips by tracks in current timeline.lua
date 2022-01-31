--[[
 * Resolve Script Name: Count number of clips by tracks in current timeline
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
 * v1.0 (2022-01-31)
  + Initial Release
--]]

resolve = Resolve()
pm = resolve:GetProjectManager()
proj = pm:GetCurrentProject()
tl = proj:GetCurrentTimeline()

print( "Number of Clips per Track" )

-- Get Track by Name, no matter the type
track_types =  { "audio", "video", "subtitle" }
local out_track_type, out_track_index
for i, track_type in ipairs( track_types ) do
    print( "--------\n" .. track_type:upper() )
    tracks_count = tl:GetTrackCount(track_type)
    for id = 1, tracks_count do
        track_name = tl:GetTrackName(track_type, id)
        items = tl:GetItemListInTrack(track_type, id)
        print( id .. "." .. track_name .. " = " .. #items )
    end
end