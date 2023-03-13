local gfx <const> = playdate.graphics
local unFlipped <const> = gfx.kImageUnflipped

function cropImage(img, w, h, srcX, srcY, posX, posY)
    local newImg = gfx.image.new(w,h, gfx.kColorBlack)
    gfx.pushContext(newImg)
    img:draw(posX, posY, unFlipped, srcX, srcY, screenWidth, screenHeight)
    gfx.popContext()
    return newImg
end
