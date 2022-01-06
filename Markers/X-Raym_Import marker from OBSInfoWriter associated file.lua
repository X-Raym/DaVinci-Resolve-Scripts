--[[
 * ReaScript Name: Import marker from OBSInfoWriter associated file
 * About:
   Use this with clip and OBS Studio OBSInfoWriter plugin set to CSV.
   CSV should have same name as video and in same directory.
   Don't use comma in marker name.
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

-- USER CONFIG AREA -------------------------------------
color = "Green"

----------------------------------END OF USER CONFIG AREA

function GetFrameFromTimeCode( timecode, fps )
  if not fps then fps = framerate end
  local hours, minutes, seconds = timecode:match("(%d+):(%d+):(%d+)")
  return (hours * 3600 + minutes * 60 + seconds) * fps
end

-- Split file name
function SplitFileName( strfilename )
	-- Returns the Path, Filename, and Extension as 3 values
	local path, file_name, extension = string.match( strfilename, "(.-)([^\\|/]-([^\\|/%.]+))$" )
	file_name = string.match( file_name, ('(.+)%.(.+)') )
	return path, file_name, extension
end

function ParseCSVfile( path )
	local file = io.open(path, "r")
	if not file then return end
	local retval = file:read("a")
	io.close(file)

	if retval then
	  local t = {}
	  local i = 0
	  for line in retval:gmatch("[^\n]*") do -- (NOTE: one iteration on two is empty line with this method)
	      local timecode, name = line:match("(.+),(.+)")
	      if timecode then
	      	i = i + 1
	        t[i] = {
	          timecode = timecode,
	          name = name,
	          color = color -- This could be extended with a table of expected name value and associated colors
	        }
	      end
	  end
	  return t
	else
		print("Invalid Path.")
		return
	end
end

resolve = Resolve()
pm = resolve:GetProjectManager()
proj = pm:GetCurrentProject()
mp = proj:GetMediaPool()
folder = mp:GetCurrentFolder()
clips = folder:GetClipList()
for i, clip in ipairs( clips ) do
	local name = clip:GetName()
	print(name)
	local property = "File Path"
	local clip_path = clips[i]:GetClipProperty(property)[property]
	if clip_path ~= "" then
		local path, file_name, extension = SplitFileName( clip_path )
		local csv_path = path .. file_name .. ".csv"
		print(csv_path)
		local csv_markers = ParseCSVfile( csv_path )
		if csv_markers and #csv_markers > 0 then
			local property = "FPS"
			local clip_FPS = clips[1]:GetClipProperty(property)[property]
			for i, marker in ipairs( csv_markers ) do
				print( "\t" .. i .. "\t" .. marker.timecode .. "\t" .. marker.name)
				local frame_id = GetFrameFromTimeCode( marker.timecode, clip_FPS)
				clip:AddMarker(frame_id, marker.color, marker.name, "", 1)
			end
		else
			print("No Associated CSV.\n")
		end
	end
end