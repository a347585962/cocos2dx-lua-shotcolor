--
-- Author: wusonglin
-- Date: 2016-06-14 14:59:15
-- 存放游戏数据 单例
--

GameData = {}
function GameData:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    self.mIsTimeBar = true
    self.mScore = 0
    return o
end

function GameData:getInstance()
    if self.gameData == nil then
        self.gameData = self:new()
    end

    return self.gameData
end

function GameData:geleaseInstance()
	if self.gameData then
		self.gameData = nil
	end
end

-- 设置有没有时间条
function GameData:setIsTimeBar(value)
    self.mIsTimeBar = value
end

function GameData:getIsTimeBar()
    return self.mIsTimeBar
end

-- 设置有没有时间条
function GameData:setScore(value)
    self.mScore = value
end

function GameData:getScore()
    return self.mScore 
end







