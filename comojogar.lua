local storyboard = require "storyboard"
local scene = storyboard.newScene()
local credittext
local voltar

function scene:createScene( event )
    local group = self.view
    local background = display.newRect( 0, 0, display.contentWidth, display.contentHeight)
		background:setFillColor( 0,.70,.75)
		group:insert(background)
    	credittext = display.newText( "Instruções", display.contentWidth/2,100, "Sabo Filled", 80 )
    	group:insert(credittext)
        credittext.anchorX = .5
        credittext.anchorY = .5
 		group:insert(credittext)

 		voltar = display.newImage("imagens/voltar.png",280,870)
 		group:insert(voltar)
end

scene:addEventListener( "createScene", scene )

function scene:enterScene( event )
	voltar:addEventListener("tap", voltarmenu)

end

scene:addEventListener( "enterScene", scene )

function scene:exitScene( event )
	local group = self.view
        storyboard.removeScene("inicia" )
       -- transition.scaleTo( gameOverText, { xScale=4.0, yScale=4.0, time=2000,onComplete=showButton} )
        voltar:removeEventListener("tap", voltarmenu )
        
end

function voltarmenu( event )
	storyboard.gotoScene("inicia")
end

scene:addEventListener( "exitScene", scene )

return scene