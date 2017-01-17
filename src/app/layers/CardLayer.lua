
-- 显示的卡牌layer

local scheduler  = require("framework.scheduler")
local CardSprite = require("app.objs.CardSprite")


local CardLayer = class("CardLayer",function()
    return display.newLayer()
end)

-- 颜色类型
local ColorCardType = {
	RedCard = 1,
	YellowCard = 2,
	GreenCard = 3,
	BlueCard = 4,
}

local colorRes = {
	[1] = "redCard.png",
	[2] = "yellowCard.png",
	[3] = "greenCard.png",
	[4] = "blueCard.png",
}

local colorRgb = {
	cc.c4f(1,0,0,1),
	cc.c4f(1,1,0,1),
	cc.c4f(0,1,0,1),
	cc.c4f(0,0,1,1),
}

local BtnPos = {
	[1] = cc.p(150, 100),
	[2] = cc.p(display.cx - 150, 200),
	[3] = cc.p(display.width - 150, 100),
	[4] = cc.p(display.cx + 150, 200),
}

function CardLayer:ctor()
	-- 初始化容器，用于存放颜色卡片
	self.mColorVector = {}
	-- 需要生成的卡片数量
	self.mColorNum = 0

	-- 初始化卡片
	self:createCard()
	-- 增加监听函数
	self:addEventLisenter()
end

-- 创建卡片
function CardLayer:createCard()
	-- 容器置空
	self.mColorVector = {}
	-- 数量增加
	self.mColorNum = self.mColorNum > 5 and self.mColorNum + math.random(-4, 2) or self.mColorNum + 1
	self.mColorNum = self.mColorNum < 1 and 1 or self.mColorNum
	self.mColorNum = self.mColorNum > 7 and 7 or self.mColorNum
	local smallWidth = 90
	-- 计算坐标
	local detalPosX = (display.width - ( 40 * self.mColorNum + smallWidth * (self.mColorNum - 1))) / 2
	-- 循环生成
	for i=1,self.mColorNum do
		local rand = math.random(4)
		local card = CardSprite.new(colorRes[rand])
		card:setPosition(cc.p(detalPosX + (50 + smallWidth) * (i - 1) + 20, 430))
		card:setAnchorPoint(cc.p(0.5, 0.5))
		self:addChild(card)
		card:setTag(rand)
		card:setScale(0.8)

		table.insert(self.mColorVector, card)	
	end
	
end

-- 注册消息事件
function CardLayer:addEventLisenter()
	local listener = cc.EventListenerCustom:create(EventsName.eClick, function(event)
		local index = event.index
		-- 点击颜色按钮
		self:clickBtnColor(index)
	end)  
  	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()  
  	eventDispatcher:addEventListenerWithFixedPriority(listener, 1) 

  	local function onNodeEvent(eventType)
        if eventType == "enter" then
            print("enter")
        elseif eventType == "exit" then
            print("exit")
            cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners(EventsName.eClick)
        end
    end
    self:registerScriptHandler(onNodeEvent)

end

-- 点击颜色按钮
function CardLayer:clickBtnColor(index)
	print(index)
	-- 一轮是否结束
	local isOverOne = false
	local line = nil
	-- 循环遍历容器
	for i,v in ipairs(self.mColorVector) do
		-- 获取卡牌状态
		local isClose = v:getClose()
		local tag = v:getTag()
		isOverOne = false
		-- 比较是否完成
		if not isClose and index == v:getTag() then
			print("11111111")
			v:setClose(true)
			v:close()
			isOverOne = true
			
			local points = {
				{
					[1] = BtnPos[index].x,
					[2] = BtnPos[index].y
				},
				{
					[1] = v:getPositionX(),
					[2] = v:getPositionY(),
				},
				
			}
			local params = { 
				borderColor = colorRgb[index],
				borderWidth = 2.0,
			}
			-- 画线
			line = display.newLine(points,params)
			self:addChild(line)
			index = -1
			-- 线的动画
			line:runAction(cc.Sequence:create(
				cc.FadeOut:create(0.2),
				cc.RemoveSelf:create()
			))

			-- 发送点击正确的消息
			Notification:postNotification(EventsName.eGetOneScore)
		elseif not isClose and index ~= v:getTag() and index > 0 then
			AudioHelper.playShootFailueEffect()
			local points = {
				{
					[1] = BtnPos[index].x,
					[2] = BtnPos[index].y
				},
				{
					[1] = v:getPositionX(),
					[2] = v:getPositionY(),
				},
				
			}
			local params = { 
				borderColor = colorRgb[index],
				borderWidth = 2.0,
			}
			-- 画线
			line = display.newLine(points,params)
			self:addChild(line)
			-- 线的动画
			line:runAction(cc.Sequence:create(
				cc.FadeOut:create(0.2),
				cc.RemoveSelf:create()
			))

			local label = display.newTTFLabel({
			    text = "Oh, Click Wrong",
			    font = "Arial",
			    size = 64,
			    color = cc.c3b(255, 0, 0), 
			})
			label:setPosition(cc.p(display.cx, display.cy))
			self:addChild(label, 100)

			local array = {}
		    table.insert(array, cc.CallFunc:create(function() label:setVisible(true) end))
		    table.insert(array, cc.ScaleTo:create(0.1, 0.5))
		    table.insert(array, cc.ScaleTo:create(0.1, 1.0))
		    table.insert(array, cc.MoveBy:create(1.1, cc.p(0, 50)))
		    table.insert(array, cc.FadeOut:create(0.2))
		    table.insert(array, cc.CallFunc:create(function()
		        label:removeFromParent()
		        -- 发送完成一批正确的消息
				Notification:postNotification(EventsName.eGameOver)
		    end))

		    label:runAction(cc.Sequence:create(array))

			Notification:postNotification(EventsName.eUnEnableTouch)
			v:setZOrder(100)
			local scale = v:getScale()
			v:runAction(cc.Sequence:create(
				cc.ScaleTo:create(0.5, scale + 0.3), 
				cc.ScaleTo:create(0.5, scale), 
				cc.CallFunc:create(function ()
					
			end)))
			-- 失败
			return
		end
	end

	if isOverOne then
		
		-- 延时生成  增加资源释放
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function ()
			-- 发送完成一批正确的消息
			AudioHelper.playOneTableEffect()
			Notification:postNotification(EventsName.eGetOneVector)
			-- 移除
			for k,v in pairs(self.mColorVector) do
				v:removeFromParent()
			end
			self:createCard()
		end)))
		
	end
end



















return CardLayer