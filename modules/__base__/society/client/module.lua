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

local Menu = M('ui.menu')
local HUD  = M('game.hud')

module.Config = run('data/config.lua', {vector3 = vector3})['Config']

module.Init = function()

  local translations = run('data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('society', Config.Locale, translations)

end

module.base64MoneyIcon = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAFoAAABaCAMAAAAPdrEwAAAAIGNIUk0AAHolAACAgwAA+f8AAIDpAAB1MAAA6mAAADqYAAAXb5JfxUYAAAMAUExURQAAACmvPCmwPCuwPiywPi2wPy6xQC6xQS+yQTCxQTCyQTCyQjGyQzKyRDOzRTSzRTSzRjW0RjW0Rza0SDe0STi0STm1Sjq1Szq2Szu2TDy2TDy2TT22Tj63Tz+3UEC4UEG4UUG4UkK4U0O5VES5VEW6VUa6Vke6V0i7WEm7WUu8Wku8W0y8W028XE29XU++XlC9X1C+X1G+YFK+YVO/YlW/ZFXAZFfAZVfAZljBZlnBZ1rBaVvCaVvCalzDal7CbF/DbV/EbWHEbmLEb2LEcGTFcWfGdGjHdWrHd2vId2vIeGzIeW3JenHKfXLKfnPLf3TLgHXLgXXMgHXMgXbMgnjNg3nMhHrNhnrOhnzOiH7PiYLQjYPRjoTRjoTRj4XRkIXSkIfSkojSk4rUlYzUlo7VmJDWmpHWm5LXnJTXnZTXnpXYnpbYn5nZopzapJ3bpZ7bpp7bp6DcqKLcqqPcq6Tcq6TdrKberqjfr6jfsKnfsavgs6zgs6zgtK7hta/htrDit7LiuLLiubPjurTjurXju7bkvLbkvbnlv7rlwLrmwLzmwr3nw77nxMDnxcLox8PpyMTpycXpysXqysbqy8fqzMnrzcrrz8vsz8vs0Mzs0c3t0tHu1dHu1tPv19Tv2NXv2dXw2dbw2tfw29jw3Nnx3drx3t7z4d/z4uD04+H05OP15eP15uT15uT15+X16OX26Of26en36+r37Ov37er47Ov47ez47e347u347+758PD58fD68fD68vL69PT79fX79vb79/b89vb89/f8+Pj9+fn9+vr9+/v++/v+/Pz+/P3+/f3+/v7//wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALfZHJgAAAEAdFJOU////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wBT9wclAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGHRFWHRTb2Z0d2FyZQBwYWludC5uZXQgNC4xLjb9TgnoAAAGdUlEQVRoQ7WZ93sURRiAFZO76O1eklt215OgBwqJgmgCRhAhRrAAiogBK4gBJEFEgWAEYiGIYEGp1kjXQECkiF0OWyjJ/k34zcy3db7Zu8fHe3/KTXnzPbPT56orRTEYAhMLUFgNKkeiGH8BNaV1KWSPVXveU9s3LW9pvhdoblm+afspTHZi5Wo1BnzpaOfcnFmWSBv29YBtpBNlZm5u59FLPDsmdJUaxQeXNugZw5IwMnrD0oO8iFKuUHNx/+bGZLWNMgm7Otm4uZ/LsVIEUs3F+Y5a3USNAlOv7cgr5ZSamQffyOnKgH1sPdfFi2PVILKaReEcmKwVIWbY2uQDvApW95HULIb+Ng0rFoXWxppcCjyqZuZjk4oNWWBrk44R7oiamXdkC3w9GTO7Q3aH1cy8OkWFnHtitstM4j/bqdWSO6Rm5nYdS4e5FbKQwxlMC6G3Q1bIHVQz8+IKLBphJLdydlRjWpiKxZAXdAfUPOak4gOO4FZOdxWmhbGTkbh9NTOvoVsDuGmAaxkdlZgWRV8Dub7bV0PyzhQWkqk5z7WMdjpqILUTslEXUEPQJ7Lq7pz9WXiBZ4iZUGBnTwTCdtVgvjgxpj+b3vTvTEteq5KbEy/6blcNVZapR3cmdc9Z4QV6Pnxzdr1GF9aWQQFUohqCPqQc3ZV17X3C6tP31kyL+Jy2dsgLW6jBPDgVc6OkR3XxCV/i9IqRRFedylxc6qk30L3DNF7ikz1Jft0oLOaT2hBSg/l8jmwOo24/amimYzkfOwfdlLtdNT1YjIaf0EFzgGhuNnB8teNcqCWDvs3vzSSLqC9Ze0F0EqaGoDeSQWt7UaHgXA0WDKFvFGEzNRS6mxot6VZhUNJNdm7zbsgSagj6UAKTQ5hnhEHJffRISIi+LdRLyNn9cTSoOExP3FZmiat2nIF66t9Xb0GFz8Df+AenVTEF2vUwAzM1BN1LfsTkcVS4bJs+fnRj84z3joqf+eFYUELvZWFzdSfZHjeeEwqXl6/myWaZ0bSVDf3uJP9NkOn01HPISXIMTJAB/hiB6WBPN+xxBpvxl4wxR6ihll8pSL1QupwLLhR22YL9ysVGrKRcfZJeAu4QSo+1yWA3rla2NGCeZGpoj13lmBJm1F/odDm+fv68phorU0l+miDlu6BFmLqbHDCWdhqVQQb/zPesW1inqxdoRqIb1SvSmBJG+wR1BF+/NkmLWUnTK1DdQq+i5gvoIbn85QPqtdRoQfU0TIgy4h/UKOi+gZ5DgGmonqIoob2CDhXHblE0ij2lgNo2YMcSy7fkhF2E2rIm/IoOFV/Q+78i1JkJheJ+jOzjnlr1GRk18swa4iC9t3U/o6LzCVLTP4dlVM14LBfC63yKIYOYeuMqcRoneZFqEW/IKAY6Q8xumla3YP2+PNnNt1Jqb6Arpifg5kXuHjNTaVi1s5/eJs0r+6gFUkxP6kkV2mKBs8UMZSYMdmAJcpxqTTGpqpcCEO1znCMTwlPFNbuF0uUs1UVwKYAWoRcwGDHsbNS/algwu+J1bvToI9TuAgZqetm1roPVk/FDazbhjaryr0SiSw/R1oFll94sWNnfsLrzS1eTkawyjKrE6HcwyeVtIix3s6Dc4ljzsTbnx74P1na83+uf8ZBn5cb0tjgsbHJjlvoMa8dxWT4XBDZmoCa3k7eH9yE0u4l9jr+dZN2P2ASnVorK8TwoVwxsglnYxNY9852oHMseogMEt+4QtnzgGDoTa8eRH4ulA4QOHCxs6ZhUBdNAIS7NIjp1+JgEaulwZzwsnXCjDDxPzB+Rwx1zS0fSoVZb/Mp4/lFqQxk5kjI1cZDWa179HTUEe8eRW9XoQZq5qeN/5fCFigWmd14VNRXLx3/et8lLC7N8XNtH0VP6mXfvV+z4iEsLFrbqqkXXho2Z8dynwgo8NdZK0SXpqxbmjrsgquhCsXrhgOYgL4h4k8Rca5VvFV7gTkySUVxrsbBjLuOGfMy1jCZFa6gv47hbeYU4ZA/XMmbRy13MFaJwqy4+Ez1cy3iSVsddfGLcdJvo33Ato5VcSeOva4WbvmQ2v+daxkrqfqXQJbNwk1fj9kOPuNwlZxdxNS7c5IW+MdRFMhd3oS/cpXmG4EOnRI8nAAt8sKsETz4AK1yahyqAy0vxvAaU7lEQcJ8yj9BPmUf+81MmR8iB//kBllOyZ2NOqR67XUAVABNjuXLlX2rCcoFjOcGoAAAAAElFTkSuQmCC'

module.RefreshBossHUD = function()

	module.DisableSocietyMoneyHUDElement()

	if ESX.PlayerData.job.grade_name == 'boss' then
		module.EnableSocietyMoneyHUDElement()

		request('society:getSocietyMoney', function(money)
			module.UpdateSocietyMoneyHUDElement(money)
		end, ESX.PlayerData.job.name)
  end

end

module.EnableSocietyMoneyHUDElement = function()
	local societyMoneyHUDElementTpl = '<div><img src="' .. module.base64MoneyIcon .. '" style="width:20px; height:20px; vertical-align:middle;">&nbsp;{{money}}</div>'

	if ESX.GetConfig().EnableHud then
		HUD.RegisterElement('society_money', 3, 0, societyMoneyHUDElementTpl, {
			money = 0
		})
	end

	emit('society:toggleSocietyHud', true)
end

module.DisableSocietyMoneyHUDElement = function()
	if ESX.GetConfig().EnableHud then
		HUD.RemoveElement('society_money')
	end

	emit('society:toggleSocietyHud', false)
end

module.UpdateSocietyMoneyHUDElement = function(money)
	if ESX.GetConfig().EnableHud then
		HUD.UpdateElement('society_money', {
			money = ESX.Math.GroupDigits(money)
		})
	end

	emit('society:setSocietyMoney', money)
end

module.openBossMenu = function(society, options)
	options = options or {}
	local elements = {}

	request('society:isPlayerBoss', function(isBoss)
		if isBoss then
			local defaultOptions = {
				withdraw = true,
				deposit = true,
				wash = true,
				employees = true,
				grades = true
			}

			for k,v in pairs(defaultOptions) do
				if options[k] == nil then
					options[k] = v
				end
			end

			if options.withdraw then
				table.insert(elements, {name = "withdraw", title = _U('society:withdraw_society_money'), type = "button"})
			end

			if options.deposit then
				table.insert(elements, {name = "deposit", title = _U('society:deposit_society_money'), type = "button"})
			end

			if options.wash then
				table.insert(elements, {name = "wash", title = _U('society:wash_money'), type = "button"})
			end

			if options.employees then
				table.insert(elements, {name = "employees", title = _U('society:employee_management'), type = "button"})
			end

			if options.grades then
				table.insert(elements, {name = "salary", title = _U('society:salary_management'), type = "button"})
			end

			table.insert(elements, {name = "exit", title = "Exit", type = "button"})

			module.boss_menu = Menu('boss_menu', {
				title = "Boss Menu",
				float = "top|left",
				elements = elements
			})

			module.boss_menu:on("ready", print("Boss Menu Ready"))

			module.boss_menu:on("item.clicked", module.bossItemClicked(society))
	end, society)
end

module.closeBossMenu = function()
	boss_menu:destroy()
end

module.bossItemClicked = function(item, index, society)

	if item.name == "withdraw" then
		module.closeBossMenu()
		module.openWithdrawMenu(society)
	end

	if item.name == "deposit" then
		module.closeBossMenu()
		module.openDepositMenu(society)
	end

	if item.name == "wash" then
		module.closeBossMenu()
		module.openWashMenu(society)
	end

	if item.name == "employees" then
		module.closeBossMenu()
		module.openEmployeeMenu(society)
	end

	if item.name == "salary" then
		module.closeBossMenu()
		module.openSalaryMenu(society)
	end

	if item.name == "exit" then
		module.closeBossMenu()
	end

end

module.openWithdrawMenu = function()

	module.withdraw_menu = Menu('withdraw_menu', {
		title = "Withdraw",
		float = "top|left",
		elements = {
			{name = "amount", label = "Amount to withdraw", type = "text"},
			{name = "submit", label = "Submit", type = "button"},
			{name = "back", label = "Back", type = "button"}
		}

		module.withdraw_menu:on("ready", print("Withdraw Menu Ready"))

		module.withdraw_menu:on("item.clicked", module.withdrawItemClicked(society))
	})
end

module.withdrawItemClicked = function(item, index, society)

	if item.name == "submit" then
		local amount = item.name["amount"].value

		if amount ~= "" then
			if tonumber(amount) then
				amount = tonumber(amount)

				request('society:getSocietyMoney', function(society_amount)
					if society_amount > amount then
						emit('society:withdrawMoney', tonumber(amount), society)
						ESX.ShowNotification("You've withdrawn $" .. amount .. "from your company's account.")
					else
						ESX.ShowNotification("Society Doesn't have enough money!", "SOCIETY NOTIFICATION", 10000)
					end
				end, society)
			else
				ESX.ShowNotification("Please input a numeric value!", "SOCIETY NOTIFICATION", 10000)
			end
		end
	end

	if item.name == "back" then
		module.closeWithDrawMenu()
		module.openBossMenu(society)
	end

end

module.openDespositMenu = function(society)

	module.deposit_menu = Menu('deposit_menu', {
		title = "Deposit",
		float = "top|left",
		elements = {
			{name = "amount", label = "Amount to deposit", type = "text"},
			{name = "submit", label = "Submit", type = "button"},
			{name = "back", label = "Back", type = "button"}
		}

		module.deposit_menu:on("ready", print("Deposit Menu Ready"))

		module.deposit_menu:on("item.clicked", module.depositItemClicked(society))
	})
end

module.depositItemClicked = function(item, index, society)

	if item.name == "submit" then
		local amount = item.name["amount"].value

		if amount ~= "" then
			if tonumber(amount) then
				emit('society:depositMoney', tonumber(amount), society)

				ESX.ShowNotification("You've deposited $" .. amount .. "to your company's account.")

			else
				ESX.ShowNotification("Please input a numeric value!", "SOCIETY NOTIFICATION", 10000)
			end
		end
	end

	if item.name == "back" then
		module.closeDepositMenu()
		module.openBossMenu(society)
	end

end

module.closeDepositMenu = function()
	deposit_menu:destroy()
end

module.openWashMenu = function(society)

	module.wash_menu = Menu('wash_menu', {
		title = "Wash Dirty Money",
		float = "top|left",
		elements = {
			{name = "amount", label = "Amount", type = "text"},
			{name = "submit", label = "Submit", type = "button"},
			{name = "back", label = "Back", type = "button"}
		}

		module.wash_menu:on('ready', print("Wash Menu Ready"))

		module.wash_menu:on('item.clicked', module.washItemClicked(society))
	})

end

module.washItemClicked = function(item, index, society)

	if item.name == "submit" then
		local amount = item.name["amount"].value

		if amount ~= "" then
			if tonumber(amount) then
				local amount = tonumber(amount)
				emit('society:washMoney', society, amount)
			else
				ESX.ShowNotification("Please use a number value!", "SOCIETY NOTIFICATION", 10000)
			end
		end
	end

end

module.closeWashMenu = function()
	wash_menu:destroy()
end

module.openEmployeeMenu = function(society)

	module.employee_menu = Menu('employee_menu', {
		title = "Employees Menu",
		float = "top|left",
		elements = {
			{name = "list", title = _U('society:employee_list'), type = "button"},
			{name = "recruit", title = _U('society:recruit'), type = "button"},
			{name = "back", title = "Back", type = "button"}
		}
	})

	module.employee_menu:on('ready', print("Employee Menu Ready!"))

	module.employee_menu:on('item.clicked', module.employeeMenuItemClicked(society))
end

module.employeeMenuItemClicked = function(item, index, society)

	if item.name == "list" then
		module.closeEmployeeMenu()
		module.openEmployeeList(society)
	end

	if item.name == "recruit" then
		module.closeEmployeeMenu()
		emit('society:recruitPlayer', society)
	end

	if item.name == "back" then
		module.closeEmployeeMenu()
		module.openBossMenu(society)
	end
end

module.closeEmployeeMenu = function()
	employee_menu:destroy()
end

module.openEmployeeList = function(society)

	request('society:employeeList', function(employees)

		local elements = {}

		for i = 1, #employees, 1 do
			table.insert( elements, {
				name = employees[i].identifier,
				label = employees[i].first_name .. " : " employees[i].last_name,
				type = "button"
			})
		end

		table.insert( elements, {
			name = "back",
			label = "Back",
			type = "button"
		})

		module.employee_list = Menu('employee_list', {
			title = "List of Employees",
			float = "top|left",
			elements = elements
		})

		module.employee_list:on('ready', print("Employee List Menu Ready"))

		module.employee_list:on('item.clicked', module.employeeListItemClicked(society, employees))
	)
end

module.employeeListItemClicked = function(item, index, society, employees)

	for i = 1, #employees, 1 do
		if item.name == employees[i].identifier then
			module.openEmployeeGradesMenu(employees[i].identifier)
		end
	end

	if item.name == "back" then
		module.closeEmployeeListMenu()
		module.openEmployeeMenu(society)
	end
end

module.closeEmployeeListMenu = function()
	employee_list:destroy()
end

module.openEmployeeGradesMenu = function(society, employee)

	module.employee_choice = Menu('employee_choice', {
		title = "Employee Actions",
		float = "top|left",
		elements = {
			{name = "promote", label = "Promote", type = "button"},
			{name = "fire", label = "Fire", type = "button"},
			{name = "back", label = "Back", type = "button"}
		}

		module.employee_choice:on('ready', print("Employee Actions Menu Ready"))

		module.employee_choice:on('item.clicked', module.employeeGradesItemClicked(society, employee))
	})

end

module.employeeGradesItemClicked = function(item, index, society, employee)

	if item.name == "promote" then
		module.closeEmployeeGradesMenu()
		module.openEmployeePromote(society, employee)
	end

	if item.name == "fire" then
		module.closeEmployeeGradesMenu()
		emit('society:fireEmployee', society, employee)
	end

	if item.name == "back" then
		module.closeEmployeeGradesMenu()
		module.openEmployeeList(society)
	end
end

module.closeEmployeeGradesMenu = function()
	employee_choice:destroy()
end

module.openEmployeePromote = function(item, index, society, employee)

	local grades = {}

	request("society:getSocietyGrades", function(society_grades)

		for k,v in pairs(society_grades) do
			table.insert( elements, {
				name = k,
				label = v,
				type = "button"
			})
		end

		module.promotion = Menu('promotion', {
			title = "Promotion",
			float = "top|left",
			elements = grades
		})

		module.promotion:on("ready", print("Promotion Menu Ready"))

		module.promotion:on("item.clicked", module.employeePromoteItemClicked(society, employee, grades))
	end, society)
end

module.employeePromoteItemClicked = function(item, index, society, employee, grades)

	for k,v in pairs(grades) do
		if item.name == k then
			emit("society:promoteEmployee", society, employee, k)
		end
	end

	if item.name == "back" then
		module.closeEmployeePromote()
		module.openEmployeeGradesMenu(society, employee)
	end
end

module.closeEmployeePromote = function()
	promotion:destroy()
end
