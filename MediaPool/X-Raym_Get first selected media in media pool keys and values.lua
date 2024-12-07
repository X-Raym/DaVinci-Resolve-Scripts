--[[
 * Resolve Script Name: Get first selected media in media pool keys and values
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
 * v1.0 (2024-12-07)
  + Initial Release
--]]

resolve = Resolve()
pm = resolve:GetProjectManager()
proj = pm:GetCurrentProject()
mp = proj:GetMediaPool()
clips = mp:GetSelectedClips()
i = 1
keys = clips[i]:GetClipProperty()
for k, v in pairs( keys ) do
  print( tostring(k) .. "\t" .. tostring(v) )
end