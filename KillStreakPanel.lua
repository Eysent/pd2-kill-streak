KillStreakPanel = KillStreakPanel or class()

function KillStreakPanel:init(hud)
    self._full_hud = hud
	self.kills = 0
	self._headshot = false
	self._ogg_table = {
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
		alpha = KillStreak.Opt.alpha,   -- 自定义参数
		w = 450 * KillStreak.Opt.scale,
		h = 450 * KillStreak.Opt.scale,
		layer = 4
	})
	self:Set_kill_icon()
    self:MakeFine()
    
end

function KillStreakPanel:Set_kill_icon()
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

function KillStreakPanel:MakeFine()
	
    self._kill_panel:set_size(self._kill_icon:w() + 2, self._kill_icon:h() + 2)
    

    self._kill_icon:set_center(self._kill_panel:w() / 2, self._kill_panel:h() / 2)
    self._kill_panel:set_center(self._full_hud:center_x(), self._full_hud:center_y() + KillStreak.Opt.pos)    
end



function KillStreakPanel:SetKills()
	self:Set_kill_icon()
	if KillStreak.Opt.enable_sound then
		self:play_kill_sound()
	end
	
	self._headshot = false
    self:MakeFine()
    
    self._kill_panel:stop()
	
	self._kill_panel:animate(callback(self, self, "Show_brust"))
    self._kill_panel:animate(callback(self, self, "Show_fading"))
end

function KillStreakPanel:Show_fading(rect)
	-- fadetime 是开始渐变消失之前的持续时间
	local fadetime = KillStreak.Opt.fadetime -- 持续时间
    local wait_t = fadetime
	
    local t = 0.5 -- 从完全不透明到完全消失的时间

	-- 展示图层
	self._kill_panel:set_alpha(1)
	-- 等待anim_t秒
	
    while wait_t > 0 do
        wait_t = wait_t - coroutine.yield()
    end

	-- fade animation
    while t > 0 do
        t = t - coroutine.yield()
        local n = math.sin((t / 2) * 350)       
        self._kill_panel:set_alpha(math.lerp(0, 1, n))
    end
	
    self.kills = 0
    self._kill_panel:set_alpha(0)
    self._kill_panel:set_x(self._full_hud:center_x())
end

function KillStreakPanel:Show_brust(panel)
    local t = 0
	local w = self._kill_icon:w()

    while t < 0.1 do
        t = t + coroutine.yield()
		local n = math.sin((t / 2) * 350)  
		local t_size = math.lerp( w, 2*w, n)
		
		-- 放大icon并居中，不然会以左上角为原点放大
        self._kill_icon:set_size(t_size,t_size)
		self._kill_icon:set_center(self._kill_panel:w() / 2, self._kill_panel:h() / 2)
		
		self._kill_panel:set_alpha(math.lerp(0, 1, n))
    end
	
	self._kill_panel:set_alpha(1)-- 保证完全显示
    self:Reset_icon() -- 回复原来大小并居中
end

function KillStreakPanel:Reset_icon()
	self._kill_icon:set_size(450*KillStreak.Opt.scale ,450*KillStreak.Opt.scale)
    self:MakeFine()
end

function KillStreakPanel:play_kill_sound()
	local table_index = self.kills
	if self.kills ==1 and not self._headshot then
		return 
	elseif self.kills > 8 then 
		table_index = 8
	end
	self:play_voices(table_index)
end

function KillStreakPanel:update_sound_sources()
	-- 此函数的目的是让声音跟着玩家角色播放，不然声音会在你击杀的地点固定播放
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
		table.insert(self._sound_sources,XAudio.Source:new(buffer))-- 插入到播放队列中
	end
end

function KillStreakPanel:get_sound_filename(voice_type)
	local filename = KillStreak.ModPath .. "assets/sounds/"
	
	filename = filename .. KillStreak.voices[KillStreak.Opt.voice_source].src
	filename = filename .. "/"
	filename = filename .. self._ogg_table[voice_type]
	return filename
end
