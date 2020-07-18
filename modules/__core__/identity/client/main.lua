-- Copyright (c) Jérémie N'gadi
--
-- All rights reserved.
--
-- Even if 'All rights reserved' is very clear :
--
--   You shall not use any piece of this software in a commercial product / service
--   You shall not resell this software
--   You shall not provide any facility to install this particular software in a commercial product / service
--   If you redistribute this software, you must link to ORIGINAL repository at https://github.com/ESX-Org/es_extended
--   This copyright should appear in every part of the project code

local skin = M('skin')

local isPlayerDeadCheckInterval = nil
local isPlayerDead = false

function initPlayerDeadCheckInterval()
  intervalisDead = ESX.SetInterval(Config.Modules.identity.isPlayerDeadCheckInterval * 1000, function()
    local playerId = PlayerId()
  
    if NetworkIsPlayerActive(playerId) then
      local playerPed = PlayerPedId()
  
      if IsPedFatallyInjured(playerPed) and not isPlayerDead then
        isPlayerDead = true

        local killerEntity, deathCause = GetPedSourceOfDeath(playerPed), GetPedCauseOfDeath(playerPed)
        local killerClientId = NetworkGetPlayerIndexFromPed(killerEntity)

        local player = ESX.Player

        if killerEntity ~= playerPed and killerClientId and NetworkIsPlayerActive(killerClientId) then
					player:killedByPlayer(GetPlayerServerId(killerClientId), killerClientId, deathCause)
				else
					player:killed(deathCause)
				end
 
        request('esx:identity:getSavedPosition', function(savedPos)
          module.DoSpawn({
              x        = savedPos and savedPos.x,
              y        = savedPos and savedPos.y,
              z        = savedPos and savedPos.z,
              heading  = savedPos and savedPos.heading,
              model    = 'mp_m_freemode_01',
              skipFade = true
            }, function()
              local playerPed = PlayerPedId()
      
              if Config.EnablePvP then
                SetCanAttackFriendly(playerPed, true, false)
                NetworkSetFriendlyFireOption(true)
              end

              skin.loadPlayerSkin()

              isPlayerDead = false
            end)
    
        end, ESX.Player.identity:serialize())
      end
    end
  end)
end