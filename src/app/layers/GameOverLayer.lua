
-- 游戏完成界面界面 

local GameOverLayer = class("GameOverLayer",function()
    return display.newLayer()
end)

--[[
-- params 中的各项为
	{
		score      :   分数
	}
]]
function GameOverLayer:ctor(params)

	params = params or {}
	self.mScore = params.score or 0
	self.mTempScore = 0

	self.mBgSprite = cc.Sprite:create("game/gameoverback.png")
	self.mBgSprite:setPosition(cc.p(display.cx, display.cy))
	self:addChild(self.mBgSprite)

	-- 计算图片大小	
	local temptexture = cc.Director:getInstance():getTextureCache():addImage("ui/number.png")
	local tempSize = temptexture:getContentSize()
    local itemWidth = tempSize.width / 10
    local itemHeight = tempSize.height
    -- 添加数字
    self.mScoreLabel = cc.Label:createWithCharMap(
    	temptexture, 
    	itemWidth, 
    	tempSize.height, 
    	48
    )
    self.mScoreLabel:setString(string.format("%s", self:getScoreStr(self.mTempScore)))
    self.mScoreLabel:setAnchorPoint(cc.p(0.5, 1.0))
    self.mScoreLabel:setPosition(cc.p(556, 522))
    self.mBgSprite:addChild(self.mScoreLabel)

end

function GameOverLayer:startAction()
	self:scoreAction()
end

-- 分数动画
function GameOverLayer:scoreAction()

    local time = self.mScore < 100 and 0.1 or 0.01

	local scheduler = cc.Director:getInstance():getScheduler()
	local onScheduler = function()

		if self.mTempScore >= self.mScore then
            scheduler:unscheduleScriptEntry(self.mScheduleHandle)
			self.mScheduleHandle = nil

            self:showOther()
        else
            self.mTempScore = self.mTempScore + 1
            AudioHelper.playShowWatchEffect()
            self.mScoreLabel:setString(string.format("%s", self:getScoreStr(self.mTempScore)))
		end

	end
    self.mScheduleHandle = scheduler:scheduleScriptFunc(onScheduler, time, false)
    
end

-- 显示其他ui
function GameOverLayer:showOther()
    -- 历史最高分数
    local tempScore = 0
    local scoreHigh = cc.UserDefault:getInstance():getIntegerForKey(EventsName.eScoreNum,0)
    tempScore = scoreHigh
    if self.mScore > scoreHigh then
        cc.UserDefault:getInstance():setIntegerForKey(EventsName.eScoreNum, tonumber(self.mScore))
        cc.UserDefault:getInstance():flush()
        tempScore = self.mScore
    end

    local label = display.newTTFLabel({
        text = string.format("High Score:%s",tempScore),
        font = "Arial",
        size = 64,
        color = cc.c3b(0, 94, 255), -- 使用纯红色
    })
    label:setPosition(cc.p(556, 380))
    self.mBgSprite:addChild(label)

    -- 重玩
    local replayBtn = cc.ui.UIPushButton.new({normal = "ui/replay.png",})
    replayBtn:setPosition(cc.p(354, 250))
    replayBtn:setOpacity(0)
    self.mBgSprite:addChild(replayBtn)
    replayBtn:onButtonPressed(function(event)
            AudioHelper.playButtonEffect()
            event.target:setScale(1.1)
        end)
    replayBtn:onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
    replayBtn:onButtonClicked(function()

        display.replaceScene(require("app.scenes.GameScene").new(), "crossFade" , 0.5)
    end)
    replayBtn:runAction(cc.FadeIn:create(0.5))


    local homeBtn = cc.ui.UIPushButton.new({normal = "ui/home.png",})
    homeBtn:setPosition(cc.p(760, 250))
    homeBtn:setOpacity(0)
    self.mBgSprite:addChild(homeBtn)
    homeBtn:onButtonPressed(function(event)
            AudioHelper.playButtonEffect()
            event.target:setScale(1.1)
        end)
    homeBtn:onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
    homeBtn:onButtonClicked(function()
        NativeHelper:showInterstitialAd()
        display.replaceScene(require("app.scenes.MainScene").new(), "crossFade" , 0.5)
    end)
    homeBtn:runAction(cc.FadeIn:create(0.5))

end

-- 获取分数
function GameOverLayer:getScoreStr(score)
	local temp = tonumber(score)
    	local str  = ""
    	for i=1,3 do
    		temp = temp / 10
    		if temp < 1 then
    			str = str.."0"
    		end
    	end
    	str = str..score
    	return str
end

return GameOverLayer

