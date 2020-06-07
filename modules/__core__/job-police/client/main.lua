self.Init()

Citizen.CreateThread(function()

	while ESX.PlayerData == nil do
		Citizen.Wait(0)
  	end

end)
