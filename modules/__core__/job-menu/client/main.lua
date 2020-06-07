M('events')

Citizen.CreateThread(function()

	while (ESX.PlayerData == nil) or (ESX.PlayerData.job == nil) do
		Citizen.Wait(0)
    end

	module.Init()

end)