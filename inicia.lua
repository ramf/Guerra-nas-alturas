local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local startbutton
local cretidsbutton
local comojogarbotao


function scene:createScene( event )
       local group = self.view
       local background = display.newRect( 0, 0, display.contentWidth, display.contentHeight)
		background:setFillColor( 0,.70,.80)
		group:insert(background)
		local logo = display.newImage("imagens/logo.png",0,30)
		group:insert(logo)
		
       --startbutton= display.newImage("iniciar.png",264,670)
		--group:insert(startbutton)

		startbutton= display.newImage("imagens/jogar.png",280,570)
		group:insert(startbutton)

		comojogarbotao= display.newImage("imagens/comojogar.png",280,670)
		group:insert(comojogarbotao)

		creditsbutton= display.newImage("imagens/creditos.png",280,770)
		group:insert(creditsbutton)


end
-- Called immediately after scene has moved onscreen:

function startGame()
	 storyboard.gotoScene("funcJogo")
end
function startCredits()
	 storyboard.gotoScene("creditos")
end

function comojogar()
	 storyboard.gotoScene("comojogar")
end

function scene:enterScene( event )
	startbutton:addEventListener("tap",startGame)
	creditsbutton:addEventListener("tap",startCredits)
	comojogarbotao: addEventListener("tap",comojogar)
end

function scene:exitScene( event )
	startbutton:removeEventListener("tap",startGame)
	creditsbutton:removeEventListener("tap",startCredits)
	comojogarbotao:removeEventListener("tap",comojogar)
		
end
-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )
return scene