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

local utils    = M('utils')
local identity = M('identity')
local camera   = M("camera")
M("table")

-- /config/default/config.character.lua, is it the right place ?
local characterConfig = Config.Modules.character

module.registrationMenu = nil
module.characterSelectionMenu = nil
module.isInMenu = false

module.AreMenuInUse = function()
  return not(module.characterSelectionMenu.isDestroyed and module.characterSelectionMenu.isDestroyed)
end

module.OpenMenu = function(cb)

  utils.ui.showNotification(_U('identity_register'))

  module.registrationMenu = Menu("character_creation", {
    float = "center|middle",
    title = "Create Character",
    items = {
      {name = "firstName", label = "First name",    type = "text", placeholder = "John"},
      {name = "lastName",  label = "Last name",     type = "text", placeholder = "Smith"},
      {name = "dob",       label = "Date of birth", type = "text", placeholder = "01/02/1234"},
      {name = "isMale",    label = "Male",          type = "check", value = true},
      {name = "submit",    label = "Submit",        type = "button"}
    }
  })

  module.registrationMenu:on("item.change", function(item, prop, val, index)

    if (item.name == "isMale") and (prop == "value") then
      if val then
        item.label = "Male"
      else
        item.label = "Female"
      end
    end

  end)

  module.registrationMenu:on("item.click", function(item, index)

    if item.name == "submit" then

      local props = module.registrationMenu:kvp()

      if (props.firstName ~= '') and (props.lastName ~= '') and (props.dob ~= '') then

        module.registrationMenu:destroy()

        request('esx:character:creation', cb, props)

        utils.ui.showNotification(_U('identity_welcome', props.firstName, props.lastName))
      else
        utils.ui.showNotification(_U('identity_fill_in'))
      end

    end

  end)

end

module.DoSpawn = function(data, cb)
  exports.spawnmanager:spawnPlayer(data, cb)
end

module.InitiateCharacterSelectionSpawn = function()
  local spawnCoords = characterConfig.spawnCoords

  module.DoSpawn({

    x        = spawnCoords.x,
    y        = spawnCoords.y,
    z        = spawnCoords.z,
    heading  = spawnCoords.heading,
    model    = 'mp_m_freemode_01',
    skipFade = false

  }, function()

    local playerPed = PlayerPedId()

  end)

  module.isInMenu = true

  Citizen.Wait(2000)

  ShutdownLoadingScreen()
  ShutdownLoadingScreenNui()
end

module.InitiateCameraPreview = function()
  camera.start()

  camera.setRadius(1.25)
end

module.CameraToSkin = function()
  camera.pointToBone(SKEL_Head, vector3(0.0,0.0,0.0))
end

module.RequestIdentitySelection = function(identities)

  -- TP the player to a spawn point defined in the config file
  module.InitiateCharacterSelectionSpawn()

  -- Start a camera on the player (skin preview)
  module.InitiateCameraPreview()

  -- Fetch the loaded player
  local player = ESX.Player

  local menuElements = {}

  if identities then
    -- for each identities, insert a button to select it
    menuElements = table.map(identities, function(identity)
      return {type = 'button', name = identity:getId(), label = identity:getFirstName() .. " " .. identity:getLastName(), identity = identity:serialize()}
    end)

    table.insert(menuElements, {name = "register", label = ">> Create a New Identity <<", type = "button", shouldDestroyMenu = true})
  else
    menuElements = {
      {name = "register", label = ">> Create a New Identity <<", type = "button", shouldDestroyMenu = true}
    }
  end

  module.characterSelectionMenu = Menu('character.select', {
      title = 'Choose An Identity',
      float = 'top|left',
      items = menuElements
  })

  module.characterSelectionMenu

  module.characterSelectionMenu:on('item.click', function(item)

    if item.name == 'register' then
      -- delegate to the identity module, responsible of the registration
      emit("esx:identity:openRegistration")

      module.characterSelectionMenu:destroy()

      camera.stop()
      module.isInMenu = false
    elseif item.name == "none" then

    else
      request("esx:character:loadSkin", function(skinContent)
        if skinContent then
          emit("esx:skin:loadSkin", skinContent)
          module.SelectCharacter(item.name, item.label, item.identity)
        else
          module.SelectCharacter(item.name, item.label, item.identity)
        end
      end, item.name)
    end
  end)

end

module.SelectCharacter = function(name, label, identity)

  module.CameraToSkin()

  local items = {
    {name = "submit", label = "Start", type = "button"},
    {name = "back", label = "Go Back", type = "button"}
  }
  
  if module.characterSelectionMenu.visible then
    module.characterSelectionMenu:hide()
  end

  module.confirmMenu = Menu('character.confirm', {
    title = 'Start with ' .. label .. '?',
    float = 'top|left',
    items = items
  })

  module.confirmMenu:on('destroy', function()
    module.characterSelectionMenu:show()
  end)

  module.confirmMenu:on('item.click', function(item, index)
    if item.name == "submit" then
      module.SelectIdentity(identity)
      module.confirmMenu:destroy()
      module.characterSelectionMenu:destroy()
      camera.stop()
      module.isInMenu = false
    elseif item.name == "back" then
      module.confirmMenu:destroy()
      module.characterSelectionMenu:focus()
    end
  end)
end

module.SelectIdentity = function(identity)
  emit("esx:identity:selectIdentity", Identity(identity))
end