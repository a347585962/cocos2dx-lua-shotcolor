
-- local SelectModeScene = 

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()

    AudioHelper.playHomeBgMusic()

    -- bg
    local bg = cc.Sprite:create("home/bg.png")
    bg:setPosition(cc.p(display.cx, display.cy))
    self:addChild(bg)

    -- hero
    self.mHero = cc.Sprite:create("home/hero.png")
    self.mHero:setAnchorPoint(cc.p(1.0, 0))
    self.mHero:setScale(0.8)
    self.mHero:setPosition(cc.p(display.width - 10 + 500, 10))
    self:addChild(self.mHero)

    -- 道具
    self.mPlate = cc.Sprite:create("home/s.png")
	self.mPlate:setPosition(cc.p(display.cx - 580 * 0.65 - 1000, display.height * 3 / 4 + 40))
	self:addChild(self.mPlate)

    -- logo
    self.mLogo1 = cc.Sprite:create("home/logo1.png")
    self.mLogo1:setAnchorPoint(cc.p(1.0, 0.5))
    self.mLogo1:setScale(0.7)
    self.mLogo1:setPosition(cc.p(display.cx - 1000, display.height * 3 / 4))
    self:addChild(self.mLogo1)

    -- logo
    self.mLogo2 = cc.Sprite:create("home/logo2.png")
    self.mLogo2:setAnchorPoint(cc.p(0, 0.5))
    self.mLogo2:setScale(0.7)
    self.mLogo2:setPosition(cc.p(display.cx + 1000, display.height * 3 / 4))
    self:addChild(self.mLogo2)

    -- 开始按钮
    self.mStartBtn = cc.ui.UIPushButton.new({normal = "home/start.png",})
    self.mStartBtn:setPosition(cc.p(display.cx, display.cy - 50))
    self.mStartBtn:setScale(0.7)
    self.mStartBtn:setOpacity(0)
    self:addChild(self.mStartBtn)
    self.mStartBtn:setTouchEnabled(false)
    self.mStartBtn:onButtonPressed(function(event)
            event.target:setScale(0.8)
        end)
    self.mStartBtn:onButtonRelease(function(event)
            event.target:setScale(0.7)
        end)
    self.mStartBtn:onButtonClicked(function()
        print("startBtnClick")

        AudioHelper.playStartEffect()
        display.replaceScene(SelectModeScene.new(), "crossFade" , 0.5)
        NativeHelper:showInterstitialAd()
    end)
end

function MainScene:onEnter()

    -- 道具动作
    self:toolAction()

    NativeHelper:hideBanner()

    if device.platform == "android" then
        self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
            if event.key == "back" then
                -- 显示对话框  
                NativeHelper.showAlert("Confirm Exit", "Are you sure exit game ?", function (event)
                    cc.Director:getInstance():endToLua()
                end)       
            end
        end)
        self:setKeypadEnabled(true)
    end 

end

function MainScene:onExit()
end

-- 道具动作
function MainScene:toolAction()

    AudioHelper.playShowToolEffect()
    -- 英雄动画
    transition.execute(self.mHero, cc.EaseElasticOut:create(cc.MoveTo:create(0.5, cc.p(display.width - 10, 10)),1.0))
    transition.execute(self.mHero, cc.RepeatForever:create(
        cc.Sequence:create(cc.MoveBy:create(2.0, cc.p(0, 10)),cc.MoveBy:create(2.0, cc.p(0, -10)))))

    -- logo 动画
    transition.execute(self.mLogo1, cc.EaseElasticOut:create(cc.MoveBy:create(1.0, cc.p(1000, 0)),1.0))
    transition.execute(self.mLogo2, cc.EaseElasticOut:create(cc.MoveBy:create(1.0, cc.p(-1000, 0)),1.0), {
        onComplete = function ()
        AudioHelper.playShowToolEffect()
            -- 盘子动画
            transition.execute(self.mPlate, cc.EaseElasticOut:create(cc.MoveBy:create(1.0, cc.p(1000, 0)),1.0))
            transition.execute(self.mPlate, cc.RepeatForever:create(cc.RotateBy:create(0.5, 30)), { 
                onComplete = self:btnAction(),
                AudioHelper.playShowToolEffect()
            })
        
        end
    })

end 

-- 按钮动画
function MainScene:btnAction()
    
    transition.execute(self.mStartBtn, cc.FadeIn:create(1.0))
    transition.execute(self.mStartBtn, cc.RepeatForever:create(
        cc.Sequence:create(
            cc.RotateTo:create(0.25, -10),
            cc.RotateTo:create(0.25, 10),
            cc.RotateTo:create(0.25, -10),
            cc.RotateTo:create(0.25, 10),
            cc.RotateTo:create(0.25, 0),
            cc.DelayTime:create(2.0)
    )))
    self.mStartBtn:setTouchEnabled(true)
end

return MainScene













