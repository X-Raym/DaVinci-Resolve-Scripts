--[[
 * Resolve Script Name: Import markers to clips in media bay from associated CSV files
 * About:
   Eg: use this with clip and OBS Studio OBSInfoWriter plugin set to CSV.
   Just set column order variable in the script. Check User Config Area for settings.
   CSV should have same name as video and in same directory.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > DaVinci-Resolve-Scripts
 * Repository URI: https://github.com/X-Raym/DaVinci-Resolve-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 2.0
--]]

--[[
 * Changelog:
 * v2.0 (2022-04-11)
  + Works with more CSV
  + Add user variable
  + Preset file support
 * v1.0 (2021-01-06)
  + Initial Release
--]]

-- USER CONFIG AREA -------------------------------------
color = "Green" -- Default color
process_clips_without_markers_only = true

csv_with_header_line = false -- false = Look data right from line 1, true starts at line 2

line_sep = ","

-- Column indexes
col_timecode = 1
col_name = 3
col_color = 2
col_note = 4
col_duration = 5
col_customData = 6
----------------------------------END OF USER CONFIG AREA

-- colors_clip = { "Orange", "Apricot", "Yellow", "Lime", "Olive", "Green", "Teal", "Navy", "Blue", "Purple", "Violet", "Pink", "Tan", "Beige", "Brown", "Chocolate" }
colors_marker = { "Red", "Yellow", "Green", "Cyan", "Blue", "Purple", "Pink", "Red", "Fuchsia", "Rose", "Lavender", "Sky", "Mint", "Lemon", "Sand", "Cocoa", "Cream" }

-- Check strings of a table, case insenstivie, but return table value
function HasTableValueCase( t, str )
  local out = false
  local str_low = str:lower()
  for i, v in ipairs( t ) do
    if v:lower() == str_low then
      out = v
      break
    end
  end
  return out
end

function GetFrameFromTimeCode( timecode, fps )
  if not fps then fps = framerate end
  local hours, minutes, seconds = timecode:match("(%d+):(%d+):(%d+)")
  if not hours then return nil end
  return (hours * 3600 + minutes * 60 + seconds) * fps
end

-- Split file name
function SplitFileName( strfilename )
  -- Returns the Path, Filename, and Extension as 3 values
  local path, file_name, extension = string.match( strfilename, "(.-)([^\\|/]-([^\\|/%.]+))$" )
  file_name = string.match( file_name, ('(.+)%.(.+)') )
  return path, file_name, extension
end

-- CSV to Table
-- http://lua-users.org/wiki/LuaCsv
function ParseCSVLine (line,sep)
  local res = {}
  local pos = 1
  sep = sep or ','
  while true do
    local c = string.sub(line,pos,pos)
    if (c == "") then break end
    if (c == '"') then
      -- quoted value (ignore separator within)
      local txt = ""
      repeat
        local startp,endp = string.find(line,'^%b""',pos)
        txt = txt..string.sub(line,startp+1,endp-1)
        pos = endp + 1
        c = string.sub(line,pos,pos)
        if (c == '"') then txt = txt..'"' end
        -- check first char AFTER quoted string, if it is another
        -- quoted string without separator, then append it
        -- this is the way to "escape" the quote char in a quote. example:
        --   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
      until (c ~= '"')
      table.insert(res,txt)
      assert(c == sep or c == "")
      pos = pos + 1
    else
      -- no quotes used, just look for the first separator
      local startp,endp = string.find(line,sep,pos)
      if (startp) then
        table.insert(res,string.sub(line,pos,startp-1))
        pos = endp + 1
      else
        -- no separator found -> use rest of string and terminate
        table.insert(res,string.sub(line,pos))
        break
      end
    end
  end
  return res
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
      if not csv_with_header_line or i > 0 then
        local cells = {}
        local z = 0
        local cells = ParseCSVLine (line, line_sep)
        if #cells > 0 then
          i = i + 1
          t[i] = {}
          t[i].timecode = cells[col_timecode] or 1
          t[i].name = cells[col_name] or ""
          t[i].color = HasTableValueCase(colors_marker, cells[col_color]) or color-- This could be extended with a table of expected name value and associated colors
          t[i].note = cells[col_note] or ""
          t[i].duration = cells[col_duration] or 1
          t[i].customData = cells[col_customData] or nil
        end
       end
    end
    return t
  else
    print("Invalid Path.")
    return
  end
end

function Init()
  resolve = Resolve()
  pm = resolve:GetProjectManager()
  proj = pm:GetCurrentProject()
  mp = proj:GetMediaPool()
  folder = mp:GetCurrentFolder()
  clips = folder:GetClipList()
  for i, clip in ipairs( clips ) do
    local name = clip:GetName()
    local count_markers = clip:GetMarkers()
    print("\n" .. name)
    if process_clips_without_markers_only == false or #count_markers == 0 then
      local property = "File Path"
      local clip_path = clips[i]:GetClipProperty(property)
      print( "\t" .. clip_path )
      if clip_path and clip_path ~= "" then
        local path, file_name, extension = SplitFileName( clip_path )
        local csv_path = path .. file_name .. ".csv"
        print("\t" .. csv_path)
        local csv_markers = ParseCSVfile( csv_path )
        if csv_markers and #csv_markers > 0 then
          local property = "FPS"
          local clip_FPS = clips[1]:GetClipProperty(property)
          for j, marker in ipairs( csv_markers ) do
            print( "\t\t" .. j .. "\t" .. marker.timecode .. "\t" .. marker.name)
            local frame_id = GetFrameFromTimeCode( marker.timecode, clip_FPS)
            if frame_id then -- check if it is not header
              local frame_duration = GetFrameFromTimeCode( marker.duration, clip_FPS)
              -- print(type(frame_id))
              -- print( "\t\t\tclip:AddMarker(" .. frame_id ..", \"" .. marker.color .. "\", \"" .. marker.name .."\", \""..marker.note.."\", "..frame_duration..", \""..marker.customData.."\")" )
              local a = clip:AddMarker(frame_id, marker.color, marker.name, marker.note, frame_duration, marker.customData)
              -- print("\t\t\t" .. tostring(a))
            end
          end
        else
          print("\tNo Associated CSV or invalid CSV.\n")
        end
      end
    else
      print( "\tClip already has one or more markers." )
    end
  end
end

if not preset_file_init then
  Init()
end