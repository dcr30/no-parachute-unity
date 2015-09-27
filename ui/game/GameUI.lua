local DeathUI 			= require "ui/game/DeathUI"
local PauseUI 			= require "ui/game/PauseUI"
local EndUI 			= require "ui/game/EndUI"
local MenuButton 		= require "ui/menu/MenuButton"
local TextFieldShadow 	= require "ui/TextFieldShadow"

local GameUI = Core.class(Sprite)


local LIFES_BLINKING_TIME = 3
local LIFES_BLINKING_DELAY = 0.25

function GameUI:init()
	self.touchButton = Bitmap.new(Assets:getTexture("assets/button.png"))
	self.touchButton:setAnchorPoint(0.5, 0.5)
	self.touchButton:setScale(math.min(0.3 * utils.scale, 0.3))
	self.touchButton:setAlpha(0.5)
	self:addChild(self.touchButton)
	self.touchButton:setVisible(false)

	self.deathUI = DeathUI.new()
	self:addChild(self.deathUI)
	self.deathUI:setVisible(false)

	self.pauseUI = PauseUI.new()
	self:addChild(self.pauseUI)
	self.pauseUI:setVisible(false)

	self.pauseButton = Bitmap.new(Assets:getTexture("assets/pause.png"))
	self.pauseButton:setScale(5 * utils.scale)
	self.pauseButton:setX(utils.screenWidth - self.pauseButton:getWidth() * 1.2)
	self.pauseButton:setY(utils.screenHeight - self.pauseButton:getHeight() * 1.2)
	self:addChild(self.pauseButton)

	self.restartButton = Bitmap.new(Assets:getTexture("assets/restart.png"))
	self.restartButton:setScale(50 / 190 * utils.scale * 1.15)
	self.restartButton:setX(self.restartButton:getWidth() * 0.15) -- left screen side
	--self.restartButton:setX(self.pauseButton:getX() - self.restartButton:getWidth() * 1.2) -- stick to pause button
	self.restartButton:setY(utils.screenHeight - self.restartButton:getHeight() * 1.15)
	self:addChild(self.restartButton)

	self.backButton = MenuButton.new(nil, "Exit to menu")
	self.backButton:setScale(4 * utils.scale)
	self.backButton:setVisible(false)
	self.backButton:setPosition(utils.screenWidth / 2 - self.backButton:getWidth() / 2, utils.screenHeight - self.backButton:getHeight() * 0.5)
	self:addChild(self.backButton)

	local pixelFont = TTFont.new("assets/fonts/pixel.ttf", 48)
	self.progressMax = 0
	self.progressText = TextFieldShadow.new(pixelFont, "0")
	self.progressText:setScale(1 * utils.scale)
	self.progressText:setAlpha(0.7)
	self.progressText:setTextColor(0xFFFFFF)
	self.progressTextColor = {0.2 * 200, 0.4 * 200, 1 * 200}
	self.progressTextColorTarget = self.progressTextColor
	self.progressTextScaleTarget = self.progressText:getScale()

	self:addChild(self.progressText)

	-- Иконки 
	self.lifesIconsContainer = Sprite.new()
	self:addChild(self.lifesIconsContainer)
	self.lifesIcons = {}
	local heartTexture1 = Assets:getTexture("assets/heart1.png")
	local heartTexture2 = Assets:getTexture("assets/heart2.png")
	local heartScale = 6 * utils.scale
	for i = 1, 3 do
		local heart = Sprite.new()
		local bg = Bitmap.new(heartTexture2)
		heart:addChild(bg)
		self.lifesIcons[i] = Bitmap.new(heartTexture1)
		heart:addChild(self.lifesIcons[i])

		heart:setScale(heartScale)
		heart:setX((i - 1) * (heart:getWidth() + heartScale))
		self.lifesIconsContainer:addChild(heart)
	end
	self.lifesIconsContainer:setY(heartScale)--self.progressBar:getHeight())
	--self.lifesIconsContainer:setX(utils.screenWidth / 2 - self.lifesIconsContainer:getWidth() / 2)
	self.lifesIconsContainer:setX(heartScale)
	self.lifesIconsContainer:setAlpha(0.7)
	self.lifesBlinkingTime = 0
	self.lifesBlinkingDelay = 0
	self.lifesBlinkingIndex = 0

	self.endUI = EndUI.new()
	self:addChild(self.endUI)
	self.endUI:setVisible(false)
end

function GameUI:setLifesCount(count)
	for i = 1, 3 do
		local isVisible = i <= count
		if isVisible == false and self.lifesIcons[i]:isVisible() ~= isVisible then
			self.lifesBlinkingIndex = i
		end
		self.lifesIcons[i]:setVisible(isVisible)
	end
	self.lifesBlinkingTime = LIFES_BLINKING_TIME
end

function GameUI:setProgress(progress)
	progress = math.min(1, progress)
	progress = math.max(0, progress)

	self.progressText:setText(tostring(self.progressMax - math.floor(progress * self.progressMax)))
	self.progressText:setPosition(utils.screenWidth - self.progressText:getWidth() - 5 * utils.scale, 2.5 * utils.scale + self.progressText:getHeight())
end

function GameUI:highlightProgress()
	self.progressTextColor = {255, 230, 0}
	self.progressText:setScale(self.progressTextScaleTarget * 1.5)
end

function GameUI:setDeathUIVisible(isVisible, ...)
	self.deathUI:setVisible(isVisible)
	self.pauseButton:setVisible(not isVisible)
	self.restartButton:setVisible(not isVisible)
	self.backButton:setVisible(isVisible)
	self.progressText:setVisible(not isVisible)
	self.lifesIconsContainer:setVisible(not isVisible)
	if isVisible then
		self.deathUI:show(...)
	end
end

function GameUI:setPauseUIVisible(isVisible)
	self:setDeathUIVisible(false)
	self.backButton:setVisible(isVisible)
	self.pauseUI:setVisible(isVisible)
	self.pauseButton:setVisible(not isVisible)
	self.restartButton:setVisible(not isVisible)
	self.progressText:setVisible(not isVisible)
	self.lifesIconsContainer:setVisible(not isVisible)
end

function GameUI:showEndUI()
	self.touchButton:setVisible(false)
	self:setDeathUIVisible(false)
	self.deathUI:setVisible(false)
	self.endUI:setVisible(true)
	self.pauseButton:setVisible(false)
	self.restartButton:setVisible(false)
	self.endUI:reset()
end

function GameUI:update(deltaTime)
	if self.progressText:isVisible() then
		for i=1,3 do
			self.progressTextColor[i] = math.min(255, self.progressTextColor[i] + (self.progressTextColorTarget[i] - self.progressTextColor[i]) * 0.02)
		end
		local currentScale = self.progressText:getScale()
		self.progressText:setScale(currentScale + (self.progressTextScaleTarget - currentScale) * 0.12)
		self.progressText:setTextColor(utils.rgbToHex(self.progressTextColor))
	end
	if self.endUI:isVisible() then
		self.endUI:update(deltaTime)
	end

	if self.lifesBlinkingIndex > 0 then
		if self.lifesBlinkingTime > 0 then
			self.lifesBlinkingTime = self.lifesBlinkingTime - deltaTime

			if self.lifesBlinkingDelay > 0 then
				self.lifesBlinkingDelay = self.lifesBlinkingDelay - deltaTime
			else
				self.lifesBlinkingDelay = LIFES_BLINKING_DELAY
				self.lifesIcons[self.lifesBlinkingIndex]:setVisible(not self.lifesIcons[self.lifesBlinkingIndex]:isVisible())
			end
		else
			self.lifesIcons[self.lifesBlinkingIndex]:setVisible(false)
			self.lifesBlinkingIndex = 0
		end
	end
end

return GameUI