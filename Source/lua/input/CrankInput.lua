class("CrankInput").extends(Input)

function CrankInput:init()
    CrankInput.super.init(self)
end

function CrankInput:isInputPressed(action)
    if action == Input.actionLeft then

    end
    return false
end
