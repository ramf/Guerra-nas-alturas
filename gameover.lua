local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local gameOverText
local newGameButton
local botaomenu
local pontos

function scene:createScene( event )
        local group = self.view
         local background = display.newRect( 0, 0, display.contentWidth, display.contentHeight)
		background:setFillColor( 0,.70,.75)
		group:insert(background)
		gameOverText = display.newText( "GAME OVER!", display.contentWidth/2,300, "Sabo Filled", 80 )
        pontos = display.newText( "Seus Pontos:", display.contentWidth/4,400, "Sabo Filled", 40 )
        group:insert(pontos)
       -- gameOverText:setFillColor( 1, 2, 0 )
        gameOverText.anchorX = .5
        gameOverText.anchorY = .5
 		group:insert(gameOverText)
 		newGameButton = display.newImage("imagens/novoJogo.png",280,870)
 		group:insert(newGameButton)
 		newGameButton.isVisible = false
        newGameButton = display.newImage("imagens/novoJogo.png",280,870)
        group:insert(newGameButton)
        botaomenu = display.newImage("imagens/menu.png",280,770)
        group:insert(botaomenu)
        display.remove( scoreNumber )
        display.remove( scoreText )

        local pontuacaoFinal = display.newText(scoreFinal, display.contentWidth/4 + 350 , 380, 'Sabo Filled', 70)
        group:insert(pontuacaoFinal)
 end

function scene:enterScene( event )
        local group = self.view
        storyboard.removeScene("funcJogo" )
       -- transition.scaleTo( gameOverText, { xScale=4.0, yScale=4.0, time=2000,onComplete=showButton} )
        newGameButton:addEventListener("tap", startNewGame)
        botaomenu:addEventListener("tap", menu)
end

 function showButton()
 	gameOverText.isVisible = false
 	newGameButton.isVisible= true
 end
function scene:exitScene( event )
        local group = self.view
        newGameButton:removeEventListener("tap",startNewGame)
        botaomenu:removeEventListener("tap", menu )
        storyboard.removeScene("inicia")
        storyboard.removeScene("gameover")
        storyboard.removeScene("fimDejogo")
        --storyboard.removeScene("funcJogo")
        --storyboard.removeScene("nivel2)

end

function startNewGame()
        	storyboard.gotoScene("funcJogo")
 end

 function menu()
            storyboard.gotoScene("inicia")
 end

scene:addEventListener( "createScene", scene )

scene:addEventListener( "enterScene", scene )

scene:addEventListener( "exitScene", scene )
return scene