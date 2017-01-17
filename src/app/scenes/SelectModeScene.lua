
local EllipseLayer3D = require("app.common.EllipseLayer")
local GameScene = require("app.scenes.GameScene")
-- 选择模式

SelectModeScene = class("SelectModeScene", function()
    return display.newScene("SelectModeScene")
end)

function SelectModeScene:ctor()

	local bg = cc.Sprite:create("home/bg.png")
    bg:setPosition(cc.p(display.cx, display.cy))
    self:addChild(bg)

    self.mBtnVector = {}
    self.mIsTouch = false

    self.mEllipseLayer = EllipseLayer3D.new({
    	longAxias = 300,
        shortAxias = 100,
        fixAngle = 90,
        totalItemNum = 4,
        unlockItemNum = 4,
        itemContentCallback = function(parrent, index)
            self:showModeDetails(parrent, index)
        end,
        alignCallback = function(index)
        end
	})
    self.mEllipseLayer:setPosition(cc.p(display.cx, display.cy))
    self:addChild(self.mEllipseLayer, 100)

    self:createTouchEventLayer()
end

function SelectModeScene:onEnter()

    NativeHelper:showBanner()
    
	local delay = cc.DelayTime:create(1.0)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(function ()
    	self.mEllipseLayer:moveToNextItem()
    end),
    cc.CallFunc:create(function ()
    	-- self.mEllipseLayer:moveToNextItem()
    end),
    cc.CallFunc:create(function ()
    	-- self.mEllipseLayer:moveToNextItem()
    end),
    cc.CallFunc:create(function ()
    	self.mEllipseLayer:moveToNextItem()

        for k,v in pairs(self.mBtnVector) do
            v:setTouchEnabled(true)
        end
        self.mIsTouch = true
    end))
    self:runAction(sequence)

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

function SelectModeScene:onExit()
end

-- 添加详细按钮
function SelectModeScene:showModeDetails(parrent, index)
	local images = {
		[1] = "game/mode1.png",
		[2] = "game/mode2.png",
		[3] = "game/mode3.png",
		[4] = "game/mode4.png",
	}
	-- 添加按钮
    local tempBtn  = cc.ui.UIPushButton.new({normal = images[index],})
    tempBtn:onButtonPressed(function(event)
         local scale = event.target:getScale()
         event.target:setScale(scale + 0.1)
        end)
    tempBtn:onButtonRelease(function(event)
            local scale = event.target:getScale()
            event.target:setScale(scale - 0.1)
        end)
    tempBtn:onButtonClicked(function()
        AudioHelper.playButtonEffect()
        print("startBtnClick--->"..index)
        print(index)
        if index%2 == 0 then
            GameData:getInstance():setIsTimeBar(false)
        end
        display.replaceScene(GameScene.new(), "crossFade" , 0.5)
    end)
    tempBtn:setPosition(0, 0)
    parrent:addChild(tempBtn)
    parrent.showNode = tempBtn
    tempBtn:setTouchEnabled(false)
    table.insert(self.mBtnVector,tempBtn)


    -- 刷新状态
    parrent.updateFunc = function(opacity)
        local nodeOpacity = opacity
        if nodeOpacity > 200 then
            nodeOpacity = 255
        end
		if nodeOpacity < 20 then
            nodeOpacity = 20
        end
		parrent.showNode:setOpacity(nodeOpacity)

        local scaleValue = opacity / 255 * 0.8
        scaleValue = cc.clampf(scaleValue, 0.5, 1.0)

        -- 

        -- 屏蔽掉后面的按钮触摸响应
        if scaleValue < 0.6 then
            if parrent.showNode and self.mIsTouch then
                parrent.showNode:setButtonEnabled(false)
            end
        else
            if parrent.showNode and self.mIsTouch then
                parrent.showNode:setButtonEnabled(true)
            end
        end
        -- parrent.showNode:setScale(scaleValue)
    end
end

-- 添加触摸事件处理
function SelectModeScene:createTouchEventLayer()
    local touchLayer = display.newLayer()

    local prev = {x = 0, y = 0}
    local start = {x = 0, y = 0}

    --设置滑动操作
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            prev.x, prev.y = x, y
            start.x, start.y = x, y

            return true
        elseif eventType == "moved" then
            local diffx = x - prev.x
            prev.x, prev.y = x, y

            if math.abs(diffx) > 5 then
                for k,v in pairs(self.mBtnVector) do
                    v:setTouchEnabled(false)
                end
            end

            if diffx > 0 then
                self.mEllipseLayer:setRadiansOffset(-1)
            end
            if diffx < 0 then
                self.mEllipseLayer:setRadiansOffset(1)
            end
        elseif eventType == "ended" or eventType == "cancelled" then
            local diffx = x - start.x
            if diffx > 150 then
                AudioHelper.playSlideEffect()
                self.mEllipseLayer:moveToPreviousItem()
                return
            end
            if diffx < -150 then
                AudioHelper.playSlideEffect()
                self.mEllipseLayer:moveToNextItem()
                return
            end
            self.mEllipseLayer:alignTheLayer(true)
        end
    end

    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(false)
    listenner:registerScriptHandler(
        function(touch, event)
            local p = touch:getLocation()
            return onTouch("began", p.x, p.y)
        end,
        cc.Handler.EVENT_TOUCH_BEGAN)
    listenner:registerScriptHandler(
        function(touch, event)
            local p = touch:getLocation()
            onTouch("moved", p.x, p.y)
        end,
        cc.Handler.EVENT_TOUCH_MOVED)
    listenner:registerScriptHandler(
        function(touch, event)
            local p = touch:getLocation()
            onTouch("ended", p.x, p.y)
        end,
        cc.Handler.EVENT_TOUCH_ENDED)
    listenner:registerScriptHandler(
        function(touch, event)
            local p = touch:getLocation()
            onTouch("ended", p.x, p.y)
        end,
        cc.Handler.EVENT_TOUCH_CANCELLED)

    local eventDispatcher = touchLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)

    self:addChild(touchLayer, 10)
end

return SelectModeScene