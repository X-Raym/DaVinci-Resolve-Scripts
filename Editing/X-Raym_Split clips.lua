-- WORK IN PROGRESS: DAVINCI SCRIPT DOESNT RETURN COLOR OF SUBTITLES!!!!
color = "Olive"
akh_script_path = '"G:\\AHK\\DaVinci Split.ahk"'

function GetTimeCodeFromFrame( pos, fps )
  local m, s, f = "00", "00", "00"
  local seconds = pos/fps
  h = AddLeadingZeros(math.floor(seconds/3600))
  m = AddLeadingZeros(math.floor(seconds/60))
  s = AddLeadingZeros(math.floor(seconds % 60))
  f = AddLeadingZeros(pos%fps)
  return h .. ":" .. m .. ":" .. s .. ":" .. f
end

function AddLeadingZeros( int )
  return string.format("%02d", tostring(int) )
end

resolve = Resolve()
pm = resolve:GetProjectManager()
proj = pm:GetCurrentProject()
tl = proj:GetCurrentTimeline()
fps = tl:GetSetting("timelineFrameRate")

items = tl:GetItemListInTrack("subtitle", 1)
for i, item in ipairs(items) do
  color = item:GetClipColor()
  print(color)
  pos = item:GetStart()
  timecode = GetTimeCodeFromFrame( pos, fps )
  tl:SetCurrentTimecode( timecode )
  --os.execute(akh_script_path)
end