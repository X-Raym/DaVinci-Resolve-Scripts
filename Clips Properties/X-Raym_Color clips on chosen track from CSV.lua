--[[
 * Resolve Script Name: Color clips on chosen track from CSV
 * Screenshot: https://i.imgur.com/TX3Lvmq.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > DaVinci-Resolve-Scripts
 * Repository URI: hhttps://github.com/X-Raym/DaVinci-Resolve-Scripts/
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.1.1
--]]

--[[
 * Changelog:
 * v1.1.1 (2022-01-23)
  # Frames fix count in cursor position
 * v1.1 (2022-01-23)
  + Process after cursor combo
  + Loop color combo
  + Named color in CSV (case insensitive)
  # trim spaces in CSV
 * v1.0 (2022-01-13)
  # Initial Release
--]]

-- USER CONFIG AREA ---------------------------------------
separator = ","

dev = false
-------------------------------- END OF USER CONFIG AREA --

-- GLOBALS ------------------------------------------------

-- List of colors form DaVinci Resolve Clips
color_names = {}
color_names[1]  =  { name = "Orange",    r = 235, g = 110, b =   0, hex = "#EB6E00" }
color_names[2]  =  { name = "Apricot",   r = 255, g = 168, b =  51, hex = "#FFA833" }
color_names[3]  =  { name = "Yellow",    r = 226, g = 169, b =  28, hex = "#E2A91C" }
color_names[4]  =  { name = "Lime",      r = 159, g = 198, b =  21, hex = "#9FC615" }
color_names[5]  =  { name = "Olive",     r =  94, g = 153, b =  32, hex = "#5E9920" }
color_names[6]  =  { name = "Green",     r =  68, g = 143, b = 100, hex = "#448F64" }
color_names[7]  =  { name = "Teal",      r =   0, g = 152, b = 153, hex = "#009899" }
color_names[8]  =  { name = "Navy",      r =  21, g =  98, b = 132, hex = "#156284" }
color_names[9]  =  { name = "Blue",      r =  67, g = 118, b = 161, hex = "#4376A1" }
color_names[10] =  { name = "Purple",    r = 153, g = 115, b = 160, hex = "#9973A0" }
color_names[11] =  { name = "Violet",    r = 208, g =  87, b = 141, hex = "#D0578D" }
color_names[12] =  { name = "Pink",      r = 233, g = 140, b = 181, hex = "#E98CB5" }
color_names[13] =  { name = "Tan",       r = 185, g = 176, b = 151, hex = "#B9B097" }
color_names[14] =  { name = "Beige",     r = 198, g = 160, b = 119, hex = "#C6A077" }
color_names[15] =  { name = "Brown",     r = 153, g = 102, b =   0, hex = "#996600" }
color_names[16] =  { name = "Chocolate", r = 140, g =  90, b =  63, hex = "#8C5A3F" }

colors_names_list = {}
for i, color in ipairs( color_names ) do
  colors_names_list[color.name:lower()] = color
end

-- test string:
-- #EB6E00,#FFA833,#E2A91C,#9FC615,#5E9920,#448F64,#009899,#156284,#4376A1,#9973A0,#D0578D,#E98CB5,#B9B097,#C6A077,#996600,#8C5A3F

------------------------------------------- END OF COLORS --

-- CSV ----------------------------------------------------
function ParseCSVLine( str )
  local t = {}
  local i = 0
  for cell in str:gmatch("[^" .. separator .. "]*") do
      i = i + 1
      t[i] = trim(cell)
  end
  if t[#t] == "" then t[#t] = nil end
  return t
end

function trim(s)
  -- from PiL2 20.4
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--------------------------------------------- END OF CSV --

-- COLORS -------------------------------------------------
function GetClosestColorRGB(r,g,b)
  local closest_color
  local min_diff = math.huge
  for i, color in ipairs(color_names) do
    color_diff = math.sqrt((color.r-r)^2 + (color.g-g)^2 + (color.b-b)^2)
    -- print(color.name .. " " .. color_diff)
    if color_diff < min_diff then
      min_diff = color_diff
      closest_color = color
    end
  end
  return closest_color
end

function HexToRGB( hex )
  local hex = string.gsub(hex,"#","")
  local R = tonumber("0x" .. hex:sub(1,2))
  local G = tonumber("0x" .. hex:sub(3,4))
  local B = tonumber("0x" .. hex:sub(5,6))
  return R, G, B
end

------------------------------------------ END OF COLORS --

-- VARIOUS ------------------------------------------------

function GetTracks(tl)
  local t = {}
  local track_types =  { "subtitle", "video", "audio" }
  for i, track_type in ipairs( track_types ) do
    local tracks_count = tl:GetTrackCount(track_type)
    for id = 1, tracks_count do
      track_name = tl:GetTrackName(track_type, id)
      table.insert(t, { name = track_name, type = track_type, id = id } )
    end
  end
  return t
end

function GetFrameFromTimeCode( timecode, fps )
  if not fps then fps = framerate end
  local hours, minutes, seconds, frames = timecode:match("(%d+):(%d+):(%d+):(%d+)")
  return (hours * 3600 + minutes * 60 + seconds) * fps + frames
end

-------------------------------------- END OF VARIOUS --

-- UI --------------------------------------------------

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)

win = disp:AddWindow(
  {
    ID = "MyWin",
    WindowTitle = "XR - Color Clips from CSV",
    Geometry = { 100,100,400,300 },
    Composition = comp,

    ui:VGroup
    {
      ID = "root",
      ui:HGroup
      {
        Weight = 1,
        ui:TextEdit{ ID="Input", Text = dev and "#FFF000, Purple, Pink, Green, Blue, Yellow, Tan, Lime, Orange, Olive, Beige, Brown, Teal, Chocolate, Navy, Violet, Apricot" or "", PlaceholderText = "Input CSV: #FFF000, Purple, Pink, Green, Blue, Yellow, Tan, Lime, Orange, Olive, Beige, Brown, Teal, Chocolate, Navy, Violet, Apricot..." }
      },
      ui:HGroup
      {
        Weight = 0,
         ui:ComboBox{ ID = "ComboTime" }
      },
      ui:HGroup
      {
        Weight = 0,
         ui:ComboBox{ ID = "ComboLoopColors" }
      },
      ui:HGroup
      {
        Weight = 0,
        ui:ComboBox{ ID = "ComboTracks",
          Weight = 1.5,
          MinimumSize = {250, 24} },
        ui:HGap(0, 2),
        ui:Button{ ID = "OK", Text = "Ok" },
      },
      ui:HGroup
      {
        Weight = 0,
         ui:Label{ID = "Message", Text = ""},
      },
    },
  })

itm = win:GetItems()

function win.On.OK.Clicked(ev)
  run()
end

function win.On.MyWin.Close(ev)
  disp:ExitLoop()
end

function run()
  -- Parse Input
  csv_colors = itm.Input.PlainText
  if csv_colors == "" then
    itm.Message.Text = "Please enter some text."
    return false
  end
  colors = ParseCSVLine( csv_colors )
  colors_named = {}
  for i, color in ipairs( colors ) do
    print(color)
    local R, G, B = HexToRGB( color )
    if R and G and B then
      local color_name = GetClosestColorRGB( R, G, B )
      print(color_name.name)
      table.insert(colors_named, color_name.name)
    else
      if colors_names_list[color:lower()] then table.insert(colors_named, colors_names_list[color:lower()].name) end
    end
  end
  if #colors == 0 then
    itm.Message.Text = "ERROR: Invalid colors."
    return false
  end

  -- Get Track Items
  track = tracks[itm.ComboTracks.CurrentIndex + 1]
  items = tl:GetItemListInTrack(track.type, track.id )
  if #items == 0 then
    itm.Message.Text = "ERROR: No items on tracks or track doesn't exist."
    return false
  end

  -- Time
  local min_pos = 0
  if itm.ComboTime.CurrentIndex == 1 then
    min_pos = GetFrameFromTimeCode( tl:GetCurrentTimecode(), fps )
    print("Min Pos = " .. min_pos)
  end

  -- Set Colors
  print("--\nLOOP ITEMS")
  local count = 0
  for i, item in ipairs( items ) do
    if count == #colors_named then
      if itm.ComboLoopColors.CurrentIndex == 1 then
        count = 0
      else
        break
      end
    end
    print("--")
    if item:GetStart() >= min_pos then
      print(item:GetName())
      if colors_named[count+1] then
        count = count + 1
        item:SetClipColor(colors_named[count])
        print(i .. ". " .. item:GetName() .. " → " .. colors_named[count])
      end
    end
  end

  itm.Message.Text = "Success!"

end

---------------------------------------------- END OF UI --

-- RUN ----------------------------------------------------

resolve = Resolve()
pm = resolve:GetProjectManager()
proj = pm:GetCurrentProject()
tl = proj:GetCurrentTimeline()
fps = tl:GetSetting("timelineFrameRate")

-- Add track names to combo
tracks = GetTracks(tl)
for i, track in ipairs( tracks ) do
  itm.ComboTracks:AddItem( track.name )
end

-- Add time to combo
itm.ComboTime:AddItem('Process from start')
itm.ComboTime:AddItem('Process from playhead')

-- Add Loop Colors to combo
itm.ComboLoopColors:AddItem('Stop at end of color list')
itm.ComboLoopColors:AddItem('Loop color list')

win:Show()

disp:RunLoop()

win:Hide()
