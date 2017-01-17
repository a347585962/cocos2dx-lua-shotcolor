
-- 封装一个card

local CardSprite = class("CardSprite",function(filename)
    return display.newNode()
end)

function CardSprite:ctor(filename)
	
	self:setContentSize(cc.size(40, 40))
	self.mContentSize = self:getContentSize()

	self.mFontSprite = cc.Sprite:create(filename)
	self.mFontSprite:setPosition(cc.p(self.mContentSize.width * 0.5, self.mContentSize.height * 0.5))
	self:addChild(self.mFontSprite)

	self.mBackSprite = cc.Sprite:create("card.png")
	self.mBackSprite:setPosition(cc.p(self.mContentSize.width * 0.5, self.mContentSize.height * 0.5))
	self:addChild(self.mBackSprite)
	self.mBackSprite:setVisible(false)

	self.mIsClose = false
end

function CardSprite:close()

	local duration = 1.0
	local openAction = {
			cc.OrbitCamera:create(0.2, 1, 30, 0, 90, 0, 0),
			cc.CallFunc:create(function()
				self.mBackSprite:setVisible(true)
				self.mBackSprite:runAction(cc.OrbitCamera:create(0.2, 1, 30, 90, 90, 0, 0))
            end),
            cc.FadeOut:create(0.2),
            -- cc.RemoveSelf:create(),
		}
	self.mFontSprite:runAction(cc.Sequence:create(openAction))
end

function CardSprite:getClose()
	return self.mIsClose
end

function CardSprite:setClose(IsClose)
	self.mIsClose = IsClose
end

return CardSprite


-- local function doOneOpenAction(cardBgBtn, isSelect)
--     	cardBgBtn:stopAllActions()
-- 		cardBgBtn:setScale(1)
-- 		cardBgBtn:setTouchEnabled(false)

--         -- 新手引导信息
--         local _, _, eventID = GuideMgr:getGuideInfo()

-- 		local tempSize = cardBgBtn:getContentSize()
-- 		local openAction = {
-- 			cc.OrbitCamera:create(0.4, 1, 30, 0, 90, 0, 0),
-- 			cc.CallFunc:create(function()
-- 				cardBgBtn:loadTextures("c_111.png", "c_111.png")
-- 				-- 卡牌背景的大小
-- 		    	local tempCard = CardNode:create({
-- 		    		allowClick = (eventID ~= 507 and eventID ~= 509 and eventID ~= 510)
-- 		    	})
-- 		    	tempCard:setPosition(tempSize.width / 2, tempSize.height * 0.6)
-- 		    	tempCard:setScaleX(-1)
-- 		    	cardBgBtn:addChild(tempCard)

-- 				if isSelect then
-- 					tempCard:setCardData(dropInfo, {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName})
-- 				    -- 选中标志
--                     local sprite = ui.newSprite("c_157.png")
--                     sprite:setPosition(tempSize.width/2, tempSize.height/2)
--                     cardBgBtn:addChild(sprite)
--                 else
-- 					tempCard:setCardData(otherInfos[otherIndex])
-- 					otherIndex = otherIndex + 1
-- 				end
--             end),
--             cc.OrbitCamera:create(0.4, 1, 30, 90, 90, 0, 0)
-- 		}
-- 		if not isSelect then
-- 			table.insert(openAction, 1, cc.DelayTime:create(0.5))
-- 		end

-- 		cardBgBtn:runAction(cc.Sequence:create(openAction))
--     end







