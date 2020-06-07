local Input = M('input')

local opened = false

Input.On('released', Input.Groups.MOVE, Input.Controls.SELECT_CHARACTER_FRANKLIN, function(lastPressed)

    opened = not opened
    module.MenuStatus(opened)
  
end)
