
Hooks:PostHook(PlayerManager, "on_killshot", "KillStreakHook1", function()
    KillStreak.Panel.kills = KillStreak.Panel.kills + 1
    KillStreak.Panel:SetKills()
end)
Hooks:PostHook(PlayerManager, "on_lethal_headshot_dealt", "KillStreakHook2", function()
    KillStreak.Panel._headshot = true
end)

Hooks:PostHook(PlayerManager, "on_throw_grenade", "killsteak_play_grenade_voice", function()
    KillStreak.Panel:play_voices(11)
end)

Hooks:PostHook(HUDManager, "update", "killstreak_update_sound", function (self, ...)
	KillStreak.Panel:update_sound_sources(...)
end)

-- use voice manager to make character speak one setence at same time. see https://superblt.znix.xyz/doc/xaudio/
Hooks:PostHook(IngameMaskOffState, "at_exit", "killsteak_play_start_voice", function (self, ...)
	KillStreak.Panel:play_voices(10)
end)

