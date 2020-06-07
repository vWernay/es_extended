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

M('events')

onRequest("society:isPlayerBoss", function(source, cb, society)

    -- Handler for client's request

    cb(module.isBoss(source, society))

end)

onRequest('society:employeeList', function(source, cb, society)
    local employees = {}

    -- Get a list of all employees that have "society" title
    -- Get their first name, last name, identifier
    -- Table.insert those infromation
    -- Callback emploees table

    -- Table Formatting (client module already implemented)
    --[[

    {
        1 = {
            identifier = xxx,
            first_name = John,
            last_name = Smith
        },

        2 = {
            identifier = yyy,
            first_name = Bob,
            last_name = Builder
        }
    }

    ]]--

    cb(employees)
end)

onRequest("society:getSocietyMoney", function(source, cb, society)

    -- Get current amount in society bank
    -- Callback the amount

    cb(money)
end)

onRequest("society:getSocietyGrades", function(source, cb, society)
    local grades = {}

    -- Get all "society" possible grades
    -- table.insert into "grades"

    -- Table Format
    --[[

    {
        grade_1 = "grade_1_label",
        grade_2 = "grade_2_label",
        grade_3 = "grade_3_label",
    }

    ]]--

    cb(grades)
end)

onClient("society:withdrawMoney", function(amount, society)

    -- Withdraw money from society account
    -- Add to player's cash

end)

onClient("society:depositMoney", function(amount, society)

    -- Deposit amount to society account
    -- Remove from player's cash

end)

onClient("society:fireEmployee", function(society, employee)

    -- Remove "employee" from "society"

end)

onClient("society:promoteEmployee", function(society, employee, grade)

    -- Find "employee" in "society"
    -- Replace current grade with "grade"

end)

onClient("society:recruitTarget", function(society, player)

    -- Add "player" to "society"
    -- Set "grade" to lowest

end)

onClient("society:washMoney", function(society, amount)

    -- Add "amount" to wash money in "society"

end)