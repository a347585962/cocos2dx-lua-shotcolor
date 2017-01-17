

-- 游戏的UI
-- 包含：
--     得分进度条
--     分数
--     时间条

local GameOverScene = require("app.scenes.GameOverScene")

local UILayer = class("UILayer",function()
    return display.newLayer()
end)

-- 构造函数
--[[
-- params结构：是否展示控件,默认三个都展示
	{
		scoreBar   分数条		
		scoreNum   具体分数  	
		timeBar	   时间条		
	}
--]]
function UILayer:ctor(params)
	params = params or {}
	-- 初始化参数
	self.mIsScoreBar = params.scoreBar or true
	self.mIsScoreNum = params.scoreNum or true
	self.mIsTimeBar  = GameData:getInstance():getIsTimeBar()

	GameData:getInstance():setScore(0)

	-- 初始分数
	self.mScoreNum = 0

	-- 是否开始
	self.mIsStart = false

	-- 定时器
	self.mScheduleHandle = nil

	-- 添加各个控件并且注册监听事件
	self:initScoreBar()
	self:initScoreNum()
	self:initTimeBar()
	
	-- 注册消息
	self:initNotification()
end

-- 添加分数条
function UILayer:initScoreBar()

	local scoreBarBg = cc.Sprite:create("ui/timescore.png")
	scoreBarBg:setAnchorPoint(cc.p(0.0, 1.0))
	scoreBarBg:setPosition(cc.p(10, display.height - 10))
	self:addChild(scoreBarBg)
	scoreBarBg:setScale(0.7)

	self.mScoreLogo = cc.Sprite:create("ui/score0.png")
	self.mScoreLogo:setAnchorPoint(cc.p(0, 0))
	scoreBarBg:addChild(self.mScoreLogo)

	-- 分数条
	self.mScoreBar = require("app.common.ProgressBar").new({
        barImage = "ui/score2.png",
        maxValue = 300,
        currValue = 300,
    })
    self.mScoreBar:setAnchorPoint(cc.p(0, 0))
    scoreBarBg:addChild(self.mScoreBar)

    self.mScoreBar:doProgress(1, 1.0)
end

-- 添加数字label
function UILayer:initScoreNum()
	
	-- local initScore = 1
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

    self.mScoreLabel:setString(string.format("%s", self:getScoreStr(self.mScoreNum)))
    self.mScoreLabel:setAnchorPoint(cc.p(0.5, 1.0))
    self.mScoreLabel:setPosition(cc.p(display.cx, display.height - 10))
    self:addChild(self.mScoreLabel)

end

-- 添加时间条
function UILayer:initTimeBar()

	if not self.mIsTimeBar then return end

	local timeBarBg = cc.Sprite:create("ui/timeback.png")
	timeBarBg:setAnchorPoint(cc.p(1.0, 1.0))
	timeBarBg:setPosition(cc.p(display.width - 10, display.height - 10))
	self:addChild(timeBarBg)
	timeBarBg:setScale(0.7)

	local timeLogo = cc.Sprite:create("ui/time.png")
	timeLogo:setAnchorPoint(cc.p(0, 0))
	timeBarBg:addChild(timeLogo)

	-- 时间条
	self.mTimeBar = require("app.common.ProgressBar").new({
        barImage = "ui/timeheal.png",
        maxValue = 150,
        -- currValue  = 100,
    })
    self.mTimeBar:setAnchorPoint(cc.p(0, 0))
    timeBarBg:addChild(self.mTimeBar)

    self.mTimeBar:doProgress(150, 1.0)

    --  时间条
	Notification:registerAutoObserver(self.mTimeBar, function ()
		local rand = math.random(2)
		-- 添加时间
		local currValue = self.mTimeBar:getCurrValue() + 15 * rand
		self.mTimeBar:setCurrValue(currValue)

		local label = display.newTTFLabel({
		    text = string.format("+%ss",rand),
		    font = "Arial",
		    size = 64,
		    color = cc.c3b(128, 0, 128), 
		})
		label:setPosition(cc.p(display.width - 50, display.height - 100))
		self:addChild(label)

		label:runAction(cc.Sequence:create(
			cc.EaseSineIn:create(cc.MoveTo:create(1.05, cc.p(display.width - 50, display.height))),
			cc.CallFunc:create(function ()

			end),
			cc.RemoveSelf:create()
		))

	end, EventsName.eGetOneVector)

	-- 时间开始
	self:timeStart()
end

-- 注册消息事件
function UILayer:initNotification()

	-- 随机得分
	local randScore = {1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,2,2,2,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5}
	local numRand = table.nums(randScore)
	
	-- 得分条
	Notification:registerAutoObserver(self.mScoreBar, function ()
		
		local score = randScore[math.random(numRand)]
		-- 设置分数
		local currValue = self.mScoreBar:getCurrValue() + score
		self.mScoreBar:setCurrValue(currValue)

		

		-- 得分数字
		self.mScoreNum = self.mScoreNum + score
		local label = display.newTTFLabel({
		    text = string.format("+%s",score),
		    font = "Arial",
		    size = 64,
		    color = cc.c3b(255, 255, 0), -- 使用纯红色
		})
		label:setPosition(cc.p(display.cx, 400))
		self:addChild(label)

		label:runAction(cc.Sequence:create(
			cc.EaseSineIn:create(cc.MoveTo:create(1.0, cc.p(display.cx, display.height - 10))),
			cc.CallFunc:create(function ()
				
				-- 记录分数
				GameData:getInstance():setScore(self.mScoreNum)
				self.mScoreLabel:setString(string.format("%s", self:getScoreStr(self.mScoreNum)))

			end),
			cc.RemoveSelf:create()
		))

	end, EventsName.eGetOneScore)

	-- 结束计时
	Notification:registerAutoObserver(self.mScoreBar, function ()
		
		-- 停止定时器
		if self.mScheduleHandle then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.mScheduleHandle)
    		self.mScheduleHandle = nil
		end
		AudioHelper.playGameOverEffect()
    	display.replaceScene(GameOverScene.new(), "crossFade" , 0.5)

	end, EventsName.eGameOver)

end

-- 游戏开始计时
function UILayer:timeStart()
	local scheduler = cc.Director:getInstance():getScheduler()
	-- 开始计时
	Notification:registerAutoObserver(self.mTimeBar, function ()
		
		if self.mIsStart then return end
		self.mIsStart = true

		local onScheduler = function()
			print("开始")
			local currValue = self.mTimeBar:getCurrValue() - 10
			self.mTimeBar:setCurrValue(currValue)

			if currValue < 5 then
				-- 游戏结束
				scheduler:unscheduleScriptEntry(self.mScheduleHandle)
    			self.mScheduleHandle = nil
				Notification:postNotification(EventsName.eGameOver)
			end
		end
    	self.mScheduleHandle = scheduler:scheduleScriptFunc(onScheduler, 1.0, false)

	end, EventsName.eTimeStart)

	
end

-- 获取分数
function UILayer:getScoreStr(score)
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

return UILayer






