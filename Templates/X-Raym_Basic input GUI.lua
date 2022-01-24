--[[
 * ReaScript Name: Basic Input GUI
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
 * v1.0 (2021-01-13)
  + Initial Release
--]]

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
				ui:TextEdit{ ID="Input", Text = "", PlaceholderText = "Input CSV: #FF0000,#00FF00..." }
			},
			ui:HGroup
			{
				Weight = 1,
				ui:TextEdit{ ID="Output", Text = "", PlaceholderText = "Output Log" }
			},
			ui:HGroup
			{
				Weight = 0,
				ui:LineEdit{ ID = "TrackName",
					PlaceholderText = "Track Name",
					Text = "Sous-titres 1",
					Weight = 1.5,
					MinimumSize = {250, 24} },
				ui:HGap(0, 2),
				ui:Button{ ID = "OK", Text = "Ok" },
			},
		},
	})

itm = win:GetItems()

function win.On.OK.Clicked(ev)
	run( tostring( itm.TrackName.Text ) )
end

function win.On.MyWin.Close(ev)
	disp:ExitLoop()
end

function run()
  itm.Input.PlainText = "Yes"
end

win:Show()

disp:RunLoop()

win:Hide()
