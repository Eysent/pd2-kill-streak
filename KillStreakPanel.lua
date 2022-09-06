KillStreakPanel = KillStreakPanel or class()

function KillStreakPanel:init(hud)
    self._full_hud = hud
	self.kills = 0
	self._headshot = false
	self._ogg_table = {
		--[0] = "Knifekill.ogg"
		[1] = "Headshot.ogg",
		[2] = "MultiKill_2.ogg",
		[3] = "MultiKill_3.ogg",
		[4] = "MultiKill_4.ogg",
		[5] = "MultiKill_5.ogg",
		[6] = "MultiKill_6.ogg",
		[7] = "MultiKill_7.ogg",
		[8] = "MultiKill_8.ogg",
		[9] = "GrenadeKill.ogg",
		[10] = "Round_Start.ogg",
		[11] = "Fireinthehole_Grenade.ogg",
	}
	-- index 2 is multikill sound source, that is to say 3-8 index values are invalid
	self._sound_sources = {}

    self._kill_panel = self._full_hud:panel({
        name = "kill_panel", 
        alpha = 0,
        layer = 100,
    })
    
	self._kill_icon = self._kill_panel:bitmap({
		vertical = "center",
        align = "center",
		name = "kill_icon",
		texture = "guis/textures/killstreak/killicons/streak",
		texture_rect = {0,0,450,450},
		blend_mode 		= "normal",
		alpha = KillStreak.Opt.alpha,
		w = 450 * KillStreak.Opt.scale,
		h = 450 * KillStreak.Opt.scale,
		layer = 4
	})
	self:set_kill_icon()
    self:MakeFine()
    
end

function KillStreakPanel:set_kill_icon()
	local index = self.kills
	if self.kills == 1 and self._headshot then 
		
		if math.random() > 0.7 then 
			index = 8
		else
			index = 9
		end
		
	elseif self.kills >7 then
		index = 7
	end
	
	local x = 0+450*(index-1) 

	self._kill_icon:set_texture_rect(x, 0, 450, 450)
end

function KillStreakPanel:Update()
	self._kill_icon:set_size(450 * KillStreak.Opt.scale,450 * KillStreak.Opt.scale)
    self:MakeFine()
end

function KillStreakPanel:MakeFine()
	
    self._kill_panel:set_size(self._kill_icon:w() + 2, self._kill_icon:h() + 2)
    

    self._kill_icon:set_center(self._kill_panel:w() / 2, self._kill_panel:h() / 2)
    self._kill_panel:set_center(self._full_hud:center_x(), self._full_hud:center_y() + KillStreak.Opt.pos )    
end

function KillStreakPanel:SetKills()
	self:set_kill_icon()
	if KillStreak.Opt.enable_sound then
		self:play_kill_sound()
	end
	self._headshot = false
    self:MakeFine()
    
    self._kill_panel:stop()
    self._kill_panel:animate(callback(self, self, "show_KillStreak"))
end

function KillStreakPanel:animate_combo(text)
    local t = 0
	local w = text:w()
    while t < 1 do
        t = t + coroutine.yield()
        local n = 1 - math.sin(t * 360)
		local t_size = math.lerp( w + 12, w+12, n)
        text:set_size(t_size,t_size)
        self:MakeFine()
    end
    text:set_size(w,w)
    self:MakeFine()
end

function KillStreakPanel:show_KillStreak(rect)
	-- KillStreak.Opt.fadetime is the time before fading 
    local anim_t = KillStreak.Opt.fadetime
    if KillStreak.Opt.fadetime > 4 then
        anim_t = 3
    end
    local t = KillStreak.Opt.fadetime - anim_t 
    if self._started then
        self._kill_panel:animate(callback(self, self, "animate_combo"))
    end
    self._started = true
	-- show up animation
	self._kill_panel:set_alpha(1)
    while anim_t > 0 do
        anim_t = anim_t - coroutine.yield()
    end
    if KillStreak.Opt.fadetime > 4 then
        while t > 0 do
        t = t - coroutine.yield()
        end
    end
	-- fade animation
    while t < 0.5 do
        t = t + coroutine.yield()
        local n = 1 - math.sin((t / 2) * 350)       
        self._kill_panel:set_alpha(math.lerp(0, 1, n))
    end
	
    self._started = false
    self.kills = 0
    self._kill_panel:set_alpha(0)
    self._kill_panel:set_x(self._full_hud:center_x())
end


function KillStreakPanel:play_kill_sound()
	blt.xaudio.setup()
	local table_index = self.kills
	if self.kills ==1 and not self._headshot then
		return 
	elseif self.kills > 8 then 
		table_index = 8
	end
	local filename = self:get_sound_filename(table_index)
	local buffer = XAudio.Buffer:new(filename)
	
	table.insert(self._sound_sources,XAudio.Source:new(buffer))
end

function KillStreakPanel:update_sound_sources()
	for i, src in ipairs(self._sound_sources) do
		if src then
			if not src:is_closed() then
				blt.xaudio.setup()
				src:set_volume(KillStreak.Opt.volume/100)
				if managers.player:player_unit() then
					src:set_position(managers.player:player_unit():position())
				end
			else
				src = nil
			end
		end
	end
end

function KillStreakPanel:play_voices(voice_type)
	if KillStreak.Opt.enable_sound then
		blt.xaudio.setup()
		
		local filename = self:get_sound_filename(voice_type)
		local buffer = XAudio.Buffer:new(filename)
		table.insert(self._sound_sources,XAudio.Source:new(buffer))
	end
end

function KillStreakPanel:get_sound_filename(voice_type)
	local filename = KillStreak.ModPath .. "assets/sounds/"
	--filename = filename .. "women1"
	filename = filename .. KillStreak.voices[KillStreak.Opt.voice_source].src
	filename = filename .. "/"
	filename = filename .. self._ogg_table[voice_type]
	return filename
end