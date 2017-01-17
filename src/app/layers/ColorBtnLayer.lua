
-- 按钮层
-- local SelectModeScene = require("app.scenes.SelectModeScene")

local ColorBtnLayer = class("ColorBtnLayer",function()
    return display.newLayer()
end)

-- 颜色类型
local ColorBtnType = {
	RedBtn = 1,
	YellowBtn = 2,
	GreenBtn = 3,
	BlueBtn = 4,
}

local BtnPos = {
	[1] = cc.p(150, 100),
	[2] = cc.p(display.cx - 150, 200),
	[3] = cc.p(display.width - 150, 100),
	[4] = cc.p(display.cx + 150, 200),
}

function ColorBtnLayer:ctor()

	self.mBtnTable = {}

	-- 初始化按钮
	for i=1,4 do
		local colorBtn  = cc.ui.UIPushButton.new({normal = string.format("%s.png", i),pressed = string.format("%s_1.png", i)})
		colorBtn:setTag(i)
		colorBtn:setScale(1.4)
	    colorBtn:onButtonPressed(function(event)
	    	AudioHelper.playShootEffect()
	        end)
	    colorBtn:onButtonRelease(function(event)
	        end)
	    colorBtn:onButtonClicked(function(event)
	    		
	    	print(event.target:getTag())
	    	-- 发送开始的消息
			Notification:postNotification(EventsName.eTimeStart)

	    	local tag = event.target:getTag()
	    	-- 按钮点击开始	
	    	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	    	local event = cc.EventCustom:new(EventsName.eClick)  
			event.index = tag  
			eventDispatcher:dispatchEvent(event)  
	    	-- test    	
	    	-- display.replaceScene(SelectModeScene.new(), "crossFade" , 0.5)
	    end)
	    colorBtn:setPosition(BtnPos[i])
	    if i % 2 == 0 then
	    	colorBtn:setOpacity(0)
	    	colorBtn:setScale(10.0)
	    else
	    	colorBtn:setScale(0.5)
	    	colorBtn:setPosition(display.cx, display.height + 200)
	    end
	    
	    colorBtn:setTouchEnabled(false)
	    self:addChild(colorBtn)	
		table.insert(self.mBtnTable, colorBtn)
	end

	for i,btn in ipairs(self.mBtnTable) do
		
		local spawn = nil
		if i % 2 == 0 then
	    	local scale = cc.ScaleTo:create(0.5 - i * 0.05, 1.4)
			local fade  = cc.FadeIn:create(0.5 - i * 0.05)
			spawn = cc.Spawn:create(scale, fade)
	    else
	    	local scale = cc.ScaleTo:create(1.0, 1.4)
			local move  = cc.MoveTo:create(1.0, BtnPos[i])
			spawn = cc.Spawn:create(scale, move)
	    end

		transition.execute(btn, cc.Sequence:create(cc.DelayTime:create(i % 2 == 0 and i * 0.15 or 0), cc.CallFunc:create(function ()
			AudioHelper.playShowToolEffect()
		end),spawn, cc.CallFunc:create(function ()
			if i == 4 then
				for k,v in pairs(self.mBtnTable) do
					v:setTouchEnabled(true)
				end
			end
		end)))
	end
       
	self.mBord = cc.Sprite:create("ui/bord.png")
	self.mBord:setAnchorPoint(cc.p(0.5, 1.0))
	self.mBord:setPosition(cc.p(display.cx, 135 - 500))
	self:addChild(self.mBord)

	self.mBord:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.5),
		cc.MoveBy:create(0.5, cc.p(0, 500)),
		cc.CallFunc:create(function ()
			
			local detal = 5
			local time  = 2.0
			local move1 = cc.MoveBy:create(time, cc.p(0,         detal))
			local move2 = cc.MoveBy:create(time, cc.p(0,         -detal * 2))
			local move3 = cc.MoveBy:create(time, cc.p(-detal,    detal))
			local move4 = cc.MoveBy:create(time, cc.p(detal * 2, 0))
			local move5 = cc.MoveBy:create(time, cc.p(-detal,    detal))
			local move6 = cc.MoveBy:create(time, cc.p(0,         -detal))

			transition.execute(self.mBord, cc.RepeatForever:create(cc.Sequence:create(move3,move4,move2,move1,move6,move5)))
		end
	)))

    local function onNodeEvent(eventType)
        if eventType == "enter" then
            print("enter")
        elseif eventType == "exit" then
            print("exit")
            cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners(EventsName.eClick)
        end
    end
    self:registerScriptHandler(onNodeEvent)

    -- 游戏结束
	Notification:registerAutoObserver(self, function ()
		-- 禁止按钮
    	for k,v in pairs(self.mBtnTable) do
			v:setTouchEnabled(false)
		end
		
	end, EventsName.eUnEnableTouch)
end

function ColorBtnLayer:onEnter()

	print("onEnter()")
	
end

function ColorBtnLayer:onExit()
end


return ColorBtnLayer