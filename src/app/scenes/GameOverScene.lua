

local GameOverLayer = require("app.layers.GameOverLayer")

local GameOverScene = class("GameOverScene", function()
    return display.newScene("GameOverScene")
end)

function GameOverScene:ctor()
	print(GameData:getInstance():getScore())
	self.mOverLayer = GameOverLayer.new({score = GameData:getInstance():getScore()})
	self:addChild(self.mOverLayer)

end

function GameOverScene:onEnter()

    AudioHelper.playGameOverMusic()

	self.mOverLayer:startAction()

	if device.platform == "android" then
        self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
            if event.key == "back" then
                -- 显示对话框  
                NativeHelper.showAlert("Confirm Exit", "Are you sure want to go home?", function (event)
                    NativeHelper:showInterstitialAd()
                    display.replaceScene(require("app.scenes.MainScene").new(), "crossFade" , 0.5)
                end)       
            end
        end)
        self:setKeypadEnabled(true)
    end 
end

function GameOverScene:onExit()
end


return GameOverScene
