
require("config")
require("cocos.init")
require("framework.init")

require("app.scenes.SelectModeScene")
require("app.common.Notification")
require("app.common.GameData")

require("app.common.AudioHelper")

require("app.common.NativeHelper")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local customListenerBg = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT",
                                handler(self, self.onEnterBack))
    eventDispatcher:addEventListenerWithFixedPriority(customListenerBg, 1)
    local customListenerFg = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT",
                                handler(self, self.onEnterFore))
    eventDispatcher:addEventListenerWithFixedPriority(customListenerFg, 1)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    math.randomseed(os.time())
    self:enterScene("MainScene")
    
end

function MyApp:onEnterBack()
	NativeHelper:showToast("进入后台")
end

function MyApp:onEnterFore()
	NativeHelper:showInterstitialAd()
    NativeHelper:showToast("从后台回来")
end


return MyApp
