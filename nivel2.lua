local storyboard = require( "storyboard" )
local scene = storyboard.newScene()


local playerSpeedY = 0
local playerSpeedX = 0
local playerMoveSpeed = 7
local playerWidth  = 60
local playerHeight = 48
local bulletWidth  = 3
local bulletHeight =  19
local islandHeight = 81
local islandWidth = 100
local numberofEnemysToGenerate = 0
local numberOfEnemysGenerated = 0
local playerBullets = {}
local enemyBullets = {}
local islands = {}
local planeGrid = {}
local enemyPlanes = {}
local livesImages = {}
local numberOfLives = 3
local freeLifes = {}

--local enemyGroup
local playerIsInvincible = false
local gameOver = false
local next_level = false
local numberOfTicks = 0

local islandGroup
local planeGroup
local player
local planeSoundChannel
local firePlayerBulletTimer
local generateIslandTimer
local fireEnemyBulletsTimer
local generateFreeLifeTimer
local rectUp
local rectDown
local rectLeft
local rectRight
local tm
--local tempEnemy
local controleponto

function scene:createScene( event )
        local group = self.view
         setupBackground()
         setupGroups()
         setupDisplay()
         setupPlayer()
         setupLivesImages()
         setupDPad()
         resetPlaneGrid()
         next_level()

end
-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

--
function scene:enterScene( event )
        local group = self.view
        --local previousScene = storyboard.getPrevious()
        --storyboard.removeScene(previousScene)
		rectUp:addEventListener( "touch", movePlane)
		rectDown:addEventListener( "touch", movePlane)
		rectLeft:addEventListener( "touch", movePlane)
		rectRight:addEventListener( "touch", movePlane)
		local planeSound = audio.loadStream("planesound.mp3")
       planeSoundChannel = audio.play( planeSound, {loops=-1} )
       Runtime:addEventListener("enterFrame", gameLoop)
       startTimers()
       generateEnemys()
       tm = timer.performWithDelay(10, next_level, 0)

end
scene:addEventListener( "enterScene", scene )

function setupBackground ()
		local background = display.newRect( 0, 0, display.contentWidth, display.contentHeight)
		background:setFillColor( 0,.70,1)
		scene.view:insert(background)
end

function setupGroups()
	 islandGroup = display.newGroup()
     planeGroup = display.newGroup()
     enemyGroup = display.newGroup()
     scene.view:insert(islandGroup)
     scene.view:insert(planeGroup)
     scene.view:insert(enemyGroup)

end
function setupDisplay ()
    local tempRect = display.newRect(0,display.contentHeight-110,display.contentWidth,124);
	tempRect:setFillColor(0,0,0);
	scene.view:insert(tempRect)
	local direita = display.newImage("direita.png",display.contentWidth-100,display.contentHeight-90);
    scene.view:insert(direita)
    local esquerda = display.newImage("esquerda.png",display.contentWidth-190,display.contentHeight-90);
    scene.view:insert(esquerda)
    local cima = display.newImage("cima.png",10,display.contentHeight - 110)
    scene.view:insert(cima)
    local baixo = display.newImage("baixo.png",10,display.contentHeight - 75)
    scene.view:insert(baixo)
end

function setupPlayer()
player = display.newImage("player.png",(display.contentWidth/2)-(playerWidth/2),(display.contentHeight - 170)-playerHeight)
player.name = "Player"
scene.view:insert(player)
end

function setupLivesImages()
	for i = 1, 6 do
 		local tempLifeImage = display.newImage("imagens/life.png",  40* i - 20, 20)
 		table.insert(livesImages,tempLifeImage)
 		scene.view:insert(tempLifeImage)
 		if( i > 3) then
 			tempLifeImage.isVisible = false;
 		end
	end
end

function setupDPad()
	rectUp = display.newRect( 45, display.contentHeight-95, 25, 30)
	rectUp:setFillColor(1,0,0)
	rectUp.id ="up"
	rectUp.isVisible = false;
	rectUp.isHitTestable = true;
	scene.view:insert(rectUp)

	rectDown = display.newRect( 45,display.contentHeight-50, 20,80)
	rectDown:setFillColor(1,0,0)
	rectDown.id ="down"
	rectDown.isVisible = false;
	rectDown.isHitTestable = true;
	scene.view:insert(rectDown)

	rectLeft = display.newRect( 590,display.contentHeight-60,25, 25)
	rectLeft:setFillColor(1,0,0)
	rectLeft.id ="left"
	rectLeft.isVisible = false;
	rectLeft.isHitTestable = true;
	scene.view:insert(rectLeft)

	rectRight= display.newRect( 690,display.contentHeight-60, 25,25)
	rectRight:setFillColor(1,0,0)
	rectRight.id ="right"
	rectRight.isVisible = false;
	rectRight.isHitTestable = true;
	scene.view:insert(rectRight)

end

function resetPlaneGrid()
	planeGrid = {}
	for i=1, 11 do
		table.insert(planeGrid,0)
	end
end

function movePlane(event)
	if event.phase == "began" then
          if(event.target.id == "up") then
          	playerSpeedY = -playerMoveSpeed
          end
           if(event.target.id == "down") then
          	playerSpeedY = playerMoveSpeed
          end
           if(event.target.id == "left") then
          	playerSpeedX = -playerMoveSpeed
          end
           if(event.target.id == "right") then
          	playerSpeedX = playerMoveSpeed
          end
     elseif event.phase == "ended" then
       
playerSpeedX = 0
       playerSpeedY = 0 
   end
end


function movePlayer()
    player.x = player.x + playerSpeedX
	player.y = player.y + playerSpeedY
	if(player.x < 0) then
		player.x = 0
	end
	if(player.x > display.contentWidth - playerWidth) then
		player.x = display.contentWidth - playerWidth
	end
	if(player.y   < 0) then
		player.y = 0
	end
	if(player.y > display.contentHeight - 70- playerHeight) then
		player.y = display.contentHeight - 70 - playerHeight
	end
end

function gameLoop()
	numberOfTicks = numberOfTicks + 1
    movePlayer()
    movePlayerBullets()
    checkPlayerBulletsOutOfBounds()
    moveIslands()
    checkIslandsOutOfBounds()
    moveFreeLifes()
    checkFreeLifesOutOfBounds()
    checkPlayerCollidesWithFreeLife()
    moveEnemyPlanes()
    moveEnemyBullets()
    checkEnemyBulletsOutOfBounds()
    checkEnemyPlanesOutOfBounds()
    checkPlayerBulletsCollideWithEnemyPlanes()
    checkEnemyBulletsCollideWithPlayer()
    checkEnemyPlaneCollideWithPlayer() 
end

function firePlayerBullet()
	local tempBullet = display.newImage("bullet.png",(player.x+playerWidth/2) - bulletWidth,player.y-bulletHeight)
	table.insert(playerBullets,tempBullet);
	planeGroup:insert(tempBullet)
end 

function startTimers()
	 firePlayerBulletTimer =    timer.performWithDelay(2000, firePlayerBullet ,-1)
     generateIslandTimer = timer.performWithDelay( 5000, generateIsland ,-1)
     generateFreeLifeTimer = timer.performWithDelay(7000,generateFreeLife, - 1)
       fireEnemyBulletsTimer = timer.performWithDelay(2000,fireEnemyBullets,-1)
       
end

function movePlayerBullets()
	if(#playerBullets > 0) then
		for i=1,#playerBullets do
			playerBullets[i]. y = playerBullets[i].y - 7
		end
	end
end

function checkPlayerBulletsOutOfBounds()
	if(#playerBullets > 0) then
		for i=#playerBullets,1,-1 do
             if(playerBullets[i].y < -18) then
				playerBullets[i]:removeSelf()
				playerBullets[i] = nil
				table.remove(playerBullets,i)
             end
		end
	end
end
function generateIsland()
      local tempIsland = display.newImage("island1.png", math.random(0,display.contentWidth - islandWidth),-islandHeight)
      table.insert(islands,tempIsland)
 	 islandGroup:insert( tempIsland )
end
function moveIslands()
	if(#islands > 0) then
		
for i=1, #islands do
			islands[i].y = islands[i].y + 3
		end
	end
end

function  checkIslandsOutOfBounds() 
 	if(#islands > 0) then
 		for i=#islands,1,-1 do
 			if(islands[i].y > display.contentHeight) then
 				islands[i]:removeSelf()
 				islands[i] = nil
 				table.remove(islands,i)
 			end
 		end
 	end
  end
  
 function generateFreeLife ()
	if(numberOfLives >= 6) then
		return
	end
	local freeLife = display.newImage("imagens/newlife.png", math.random(0,display.contentWidth - 40), 0);
	table.insert(freeLifes,freeLife)
	planeGroup:insert(freeLife)
end 

function moveFreeLifes()
	if(#freeLifes > 0) then
		for i=1,#freeLifes do
			freeLifes[i].y = freeLifes[i].y  +5
		end
	end
end

function  checkFreeLifesOutOfBounds() 
 	if(#freeLifes > 0) then
 		for i=#freeLifes,1,-1 do
 			if(freeLifes[i].y > display.contentHeight) then
 				freeLifes[i]:removeSelf()
 				freeLifes[i] = nil
 				table.remove(freeLifes,i)
 				print("VIDA GRÁTIS") -- 
 			end
 		end
 	end
 end

 function hasCollided( obj1, obj2 )
   if ( obj1 == nil ) then 
      return false
   end
   if ( obj2 == nil ) then  
      return false
   end

   local left = obj1.contentBounds.xMin <= obj2.contentBounds.xMin and obj1.contentBounds.xMax >= obj2.contentBounds.xMin
   local right = obj1.contentBounds.xMin >= obj2.contentBounds.xMin and obj1.contentBounds.xMin <= obj2.contentBounds.xMax
   local up = obj1.contentBounds.yMin <= obj2.contentBounds.yMin and obj1.contentBounds.yMax >= obj2.contentBounds.yMin
   local down = obj1.contentBounds.yMin >= obj2.contentBounds.yMin and obj1.contentBounds.yMin <= obj2.contentBounds.yMax

   return (left or right) and (up or down)
end

function   checkPlayerCollidesWithFreeLife() 
	if(#freeLifes > 0) then
		for i=#freeLifes,1,-1 do
			if(hasCollided(freeLifes[i], player)) then
				freeLifes[i]:removeSelf()
				freeLifes[i] = nil
				table.remove(freeLifes, i)
				numberOfLives = numberOfLives + 1
				hideLives()
				showLives()
			end
		end
	end
end
function hideLives()
	for i=1, 6 do
		livesImages[i].isVisible = false
	end
end

function showLives()
	for i=1, numberOfLives do
         livesImages[i].isVisible = true;
	end
end

function generateEnemys()
	numberOfEnemysToGenerate = math.random(3,7)
	timer.performWithDelay( 2000, generateEnemyPlane,numberOfEnemysToGenerate)
end

function generateEnemyPlane()
	if(gameOver ~= true) then
		local randomGridSpace = math.random(8)
   	 local randomEnemyNumber = math.random(3)
		local tempEnemy 
			if(planeGrid[randomGridSpace]~=0) then
				generateEnemyPlane()
				return
			else
			if(randomEnemyNumber == 1)then
				tempEnemy =  display.newImage("enemy1.png", (randomGridSpace*65)-28,-60)
				tempEnemy.type = "regular"
				--scene.view:insert(tempEnemy)
			elseif(randomEnemyNumber == 3) then
				tempEnemy =  display.newImage("enemy2.png", display.contentWidth/2 - playerWidth/2,-60)
				tempEnemy.type = "waver"
			else
				tempEnemy =  display.newImage("enemy3.png", (randomGridSpace*65)-28,-60)
				tempEnemy.type = "chaser"
			end
			planeGrid[randomGridSpace] = 1
	    	table.insert(enemyPlanes,tempEnemy)
	    	--enemyGroup:insert(tempEnemy)
	   	   	planeGroup:insert(tempEnemy)
	   	    --scene.view:insert(tempEnemy)
	    	numberOfEnemysGenerated = numberOfEnemysGenerated+1;
			end
       	 if(numberOfEnemysGenerated == numberOfEnemysToGenerate)then
        		numberOfEnemysGenerated = 0;
        		resetPlaneGrid()
        		timer.performWithDelay(2000,generateEnemys,1)
       	 end
	end
end
function moveEnemyPlanes()
	if(#enemyPlanes > 0) then
		for i=1, #enemyPlanes do
			
if(enemyPlanes[i].type ==  "regular") then
		    	moveRegularPlane(enemyPlanes[i])
			elseif(enemyPlanes[i].type == "waver") then
				moveWaverPlane(enemyPlanes[i])

    	    else
	 		 moveChaserPlane(enemyPlanes[i])
			end
		end
	end
end

function moveRegularPlane(plane)
		plane.y = plane.y+4
end

function moveWaverPlane(plane)
		 plane.y =plane.y+4
	    plane.x =  (display.contentWidth/2)+ 250* math.cos(numberOfTicks * 0.5 * math.pi/30) ;
end

function moveChaserPlane(plane)
	if(plane.x < player.x)then
		plane.x =plane.x +4
	end
	if(plane.x  > player.x)then
		plane.x = plane.x - 4
	end
    plane.y = plane.y + 4
end

function fireEnemyBullets()
	if(#enemyPlanes >= 2) then
		local numberOfEnemyPlanesToFire = math.floor(#enemyPlanes/2)
   	 local tempEnemyPlanes = table.copy(enemyPlanes)
   	 local function fireBullet() 
    		local randIndex = math.random(#tempEnemyPlanes)
    		local tempBullet = display.newImage("bullet.png",(tempEnemyPlanes[randIndex].x+playerWidth/2) + bulletWidth,tempEnemyPlanes[randIndex].y+playerHeight+bulletHeight)
    		tempBullet.rotation = 180
    		planeGroup:insert(tempBullet)
	   	 table.insert(enemyBullets,tempBullet);
	   	 table.remove(tempEnemyPlanes,randIndex)
   	 end

			for i = 0, numberOfEnemyPlanesToFire do
				fireBullet()
			end

	end
end
function moveEnemyBullets()
	if(#enemyBullets > 0) then
		for i=1,#enemyBullets do
			enemyBullets[i]. y = enemyBullets[i].y + 7
		end
	end
end
function   checkEnemyBulletsOutOfBounds() 
	if(#enemyBullets > 0) then
		for i=#enemyBullets,1,-1 do
			if(enemyBullets[i].y > display.contentHeight) then
				enemyBullets[i]:removeSelf()
				enemyBullets[i] = nil
				table.remove(enemyBullets,i)
			end				
		end
	end
end

function checkEnemyPlanesOutOfBounds()
	if(#enemyPlanes> 0) then
		for i=#enemyPlanes,1,-1 do
             if(enemyPlanes[i].y > display.contentHeight) then
				enemyPlanes[i]:removeSelf()
				enemyPlanes[i] = nil
				table.remove(enemyPlanes,i)

             end
		end
	end
end

local score = 0


local scoreNumber = display.newText(score, 460, 10, "Sabo Filled", 26)
scoreNumber.xScale = 1.2
scoreNumber.yScale = 1.2

local scoreText = display.newText("Pontos:", 300, 10, "Sabo Filled", 30)
scoreNumber.xScale = 1.2

local levelText = display.newText("Nível 2", 30, 52, "Sabo Filled", 30)
scoreNumber.xScale = 1.2

function next_level()
	if (controleponto == 10) then	
    display.remove( scoreNumber )
    display.remove( scoreText )
    display.remove( levelText )
	storyboard.gotoScene("fimdejogo")
	end
end

function checkPlayerBulletsCollideWithEnemyPlanes()
	if(#playerBullets > 0 and #enemyPlanes > 0) then
		for i=#playerBullets,1,-1 do
			for j=#enemyPlanes,1,-1 do
				if(hasCollided(playerBullets[i], enemyPlanes[j])) then
					playerBullets[i]:removeSelf()
				    playerBullets[i] =  nil
				    table.remove(playerBullets,i)
				    generateExplosion(enemyPlanes[j].x,enemyPlanes[j].y)
                    
                    scoreNumber.text = tostring(tonumber(scoreNumber.text) + 1)

                    controleponto = tonumber(scoreNumber.text)

				    enemyPlanes[j]:removeSelf()
				    enemyPlanes[j] = nil
				    table.remove(enemyPlanes,j)
				    local explosion = audio.loadStream("explosion.mp3")
					local backgroundMusicChannel = audio.play( explosion, {fadein=1000 } )
				end
			end
		end
	end
end
function generateExplosion(xPosition , yPosition)
	local options = { width = 60,height = 49,numFrames = 6}
	local explosionSheet = graphics.newImageSheet( "explosion.png", options )
	local sequenceData = {
  	 {  start=1, count=6, time=400,   loopCount=1 }
	}
	local explosionSprite = display.newSprite( explosionSheet, sequenceData )
	explosionSprite.x = xPosition
    explosionSprite.y = yPosition
	explosionSprite:addEventListener( "sprite", explosionListener )
	explosionSprite:play()
end

function explosionListener( event )
 	
if ( event.phase == "ended" ) then

		local explosion = event.target 
		explosion:removeSelf()
		explosion = nil
	end
end

function    checkEnemyBulletsCollideWithPlayer()
	if(#enemyBullets > 0) then
		for i=#enemyBullets,1,-1 do
			if(hasCollided(enemyBullets[i],player)) then
				enemyBullets[i]:removeSelf()
				enemyBullets[i] = nil
				table.remove(enemyBullets,i)
				if(playerIsInvincible == false) then
					killPlayer()
				end
			end
		end
	end
end
function killPlayer()
	numberOfLives = numberOfLives- 1;
  	 if(numberOfLives == 0) then
        	gameOver = true
			doGameOver()
	  else
          spawnNewPlayer()
		   hideLives()
		   showLives()
			playerIsInvincible = true

	end
end

function  doGameOver()
	display.remove( scoreNumber )
        display.remove( scoreText )
        display.remove( levelText )
	storyboard.gotoScene("gameover")
end

-- Respawn do avião
function spawnNewPlayer()
	local numberOfTimesToFadePlayer = 3
	local numberOfTimesPlayerHasFaded = 0
	local  function fadePlayer()
        player.alpha = 0;
        transition.to( player, {time=400, alpha=1,  })
        numberOfTimesPlayerHasFaded = numberOfTimesPlayerHasFaded + 1

  	if(numberOfTimesPlayerHasFaded == numberOfTimesToFadePlayer) then
  		playerIsInvincible = false
  	end
  end
  fadePlayer()
    	timer.performWithDelay(400, fadePlayer,numberOfTimesToFadePlayer)
end

function   checkEnemyPlaneCollideWithPlayer() 
	if(#enemyPlanes > 0) then
		for i=#enemyPlanes,1,-1 do
			if(hasCollided(enemyPlanes[i], player)) then
				enemyPlanes[i]:removeSelf()
				enemyPlanes[i] = nil
				table.remove(enemyPlanes,i)
				if(playerIsInvincible == false) then
				    killPlayer()
				end
			end
		end
	end
end

-- Called when scene is about to move offscreen:

function scene:exitScene( event )
        local group = self.view
        rectUp:removeEventListener( "touch", movePlane)
		rectDown:removeEventListener( "touch", movePlane)
		rectLeft:removeEventListener( "touch", movePlane)
		rectRight:removeEventListener( "touch", movePlane)
        audio.stop(planeSoundChannel)
        audio.dispose(planeSoundChannel)
       Runtime:removeEventListener("enterFrame", gameLoop)
       cancelTimers()
       storyboard.removeScene("inicia")
       storyboard.removeScene("gameover")
       storyboard.removeScene("fimDejogo")

end
scene:addEventListener( "exitScene", scene )
function cancelTimers()
	timer.cancel( firePlayerBulletTimer )
	timer.cancel(generateIslandTimer)
	timer.cancel(fireEnemyBulletsTimer)
	timer.cancel(generateFreeLifeTimer)
	timer.cancel(tm)

end
return scene
