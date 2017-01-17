
-- 游戏场景
local ColorBtnLayer = require("app.layers.ColorBtnLayer")
local CardLayer = require("app.layers.CardLayer")
local UILayer = require("app.layers.UILayer")


local GameScene = class("GameScene", function()
    return display.newScene("GameScene")
end)

function GameScene:ctor()

	AudioHelper.playGameBgMusic()
	-- 背景
	self.mBg = cc.Sprite:create(string.format("game/%s.jpg",math.random(5)))
	self.mBg :setPosition(cc.p(display.cx, display.cy))
    self:addChild(self.mBg)
	
	-- 分层添加
	self:addChild(UILayer.new())
	self:addChild(CardLayer.new())
	self:addChild(ColorBtnLayer.new())
	
	-- 背景的动画
	local detal = 5
	local time  = 2.0
	local move1 = cc.MoveBy:create(time, cc.p(0,         detal))
	local move2 = cc.MoveBy:create(time, cc.p(0,         -detal * 2))
	local move3 = cc.MoveBy:create(time, cc.p(-detal,    detal))
	local move4 = cc.MoveBy:create(time, cc.p(detal * 2, 0))
	local move5 = cc.MoveBy:create(time, cc.p(-detal,    detal))
	local move6 = cc.MoveBy:create(time, cc.p(0,         -detal))

	transition.execute(self.mBg, cc.RepeatForever:create(cc.Sequence:create(move1,move2,move3,move4,move5,move6)))

end

function GameScene:onEnter()
end

function GameScene:onExit()
end


return GameScene