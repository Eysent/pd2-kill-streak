_G.KillStreak = _G.KillStreak or {}
KillStreak.ModPath = ModPath
KillStreak.SavePath = SavePath .. "KillStreak.txt"
KillStreak.LocPath = ModPath .. "loc/"
KillStreak.Opt = {} 
KillStreak.OptMenuId = "KillStreakOptions"

function KillStreak:Init()
	dofile(self.ModPath .. "/KillStreakPanel.lua")
	
	self:Load()
	
	self.voices = {
		{src = "women1", menu_name = "voice_source_women1"},
		{src = "women2", menu_name = "voice_source_women2"},
		{src = "women3", menu_name = "voice_source_women3"},
		{src = "women4", menu_name = "voice_source_women4"},
		{src = "women5", menu_name = "voice_source_women5"},
		{src = "men1", menu_name = "voice_source_men1"},
		{src = "men2", menu_name = "voice_source_men2"},
	}
	
	self.Opt.fadetime = self.Opt.fadetime or 3
	self.Opt.pos = self.Opt.pos or 142
	self.Opt.scale = self.Opt.scale or 0.35
	self.Opt.alpha = self.Opt.alpha or 1.0
	self.Opt.volume = self.Opt.volume or 100
	self.Opt.enable_sound = self.Opt.enable_sound or true
	self.Opt.voice_source = self.Opt.voice_source or 1

	self.voices_loc = {}

	HopLib:load_localization(KillStreak.LocPath, managers.localization)
	self:get_localized_table()
	
	self.Panel = KillStreakPanel:new(managers.gui_data:create_fullscreen_workspace():panel())
	  
	self.InitDone = true
end

function KillStreak:get_localized_table()
	for key,value in pairs(self.voices) do
		table.insert(self.voices_loc, managers.localization:text("" .. value.menu_name))
	end
end
	
function KillStreak:Save()
	local file = io.open(self.SavePath, "w+")
	if file then
		file:write(json.encode(self.Opt))
		file:close()
	end
end

function KillStreak:Load()
	local file = io.open(self.SavePath, "r")
	if file then
		self.Opt = json.decode(file:read("*all"))
		file:close()
	end
end


function MenuCallbackHandler:KillStreak_value(item)
	KillStreak.Opt[item._parameters.name:gsub("KillStreak_", "")] = item:value()
	KillStreak:Save()
	KillStreak.Panel:Update()
end
function MenuCallbackHandler:KillStreak_toggle(item)
	KillStreak.Opt[item._parameters.name:gsub("KillStreak_", "")] = item:value() == "on"
	KillStreak:Save()
	KillStreak.Panel:Update()
end

Hooks:Add("MenuManagerPopulateCustomMenus", "KillStreakOptions", function(self, nodes)
	if not KillStreak.InitDone then
		KillStreak:Init()
	end

	MenuHelper:NewMenu(KillStreak.OptMenuId)
	MenuHelper:AddMultipleChoice({
		id = "KillStreak_voice_source",
		title = "KillStreak_voice_source_title",
		callback = "KillStreak_value",
		menu_id = KillStreak.OptMenuId,
		items = KillStreak.voices_loc,
		value = KillStreak.Opt.voice_source,
    })	
    MenuHelper:AddSlider({
		id = "KillStreak_fadetime",
		title = "KillStreak_fadetime_title",
		callback = "KillStreak_value",
		menu_id = KillStreak.OptMenuId,
		max = 60,
		min = 0.5,
		step = 0.1,
		show_value = true,
		value = KillStreak.Opt.fadetime,
    })	    
	MenuHelper:AddSlider({
		id = "KillStreak_pos",
		title = "KillStreak_pos_title",
		callback = "KillStreak_value",
		menu_id = KillStreak.OptMenuId,
		max = 300,
		min = 16,
		step = 1,
		show_value = true,
		value = KillStreak.Opt.pos,
	})
	MenuHelper:AddSlider({
		id = "KillStreak_scale",
		title = "KillStreak_scale_title",
		callback = "KillStreak_value",
		menu_id = KillStreak.OptMenuId,
		max = 2.0,
		min = 0.1,
		step = 0.1,
		show_value = true,
		value = KillStreak.Opt.scale,
	})	
	MenuHelper:AddSlider({
		id = "KillStreak_alpha",
		title = "KillStreak_alpha_title",
		callback = "KillStreak_value",
		menu_id = KillStreak.OptMenuId,
		max = 1.0,
		min = 0.0,
		step = 0.1,
		show_value = true,
		value = KillStreak.Opt.alpha,
	})
	MenuHelper:AddSlider({
		id = "KillStreak_volume",
		title = "KillStreak_volume_title",
		callback = "KillStreak_value",
		menu_id = KillStreak.OptMenuId,
		max = 100,
		min = 0.0,
		step = 0.1,
		show_value = true,
		value = KillStreak.Opt.volume,
	})
	MenuHelper:AddToggle({
		id = "KillStreak_enable_sound",
		title = "KillStreak_enable_sound_title",
		callback = "KillStreak_toggle",
		menu_id = KillStreak.OptMenuId,
		value = KillStreak.Opt.enable_sound,
    })	
	nodes[KillStreak.OptMenuId] = MenuHelper:BuildMenu(KillStreak.OptMenuId)
	MenuHelper:AddMenuItem(nodes.lua_mod_options_menu or nodes.blt_options, KillStreak.OptMenuId, "KillStreak_options_title", "KillStreak_options_desc")
end)