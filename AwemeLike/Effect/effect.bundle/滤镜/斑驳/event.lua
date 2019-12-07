local eventDoneCount = 0
local eventCount = 1
EventHandles =
{
    handleEffectEvent = function (this, eventCode)
        local featurea2dv3_0 = this:getFeature("2DStickerV3")
        local sticker2DV3Featurea2dv3_0 = EffectSdk.castSticker2DV3Feature(featurea2dv3_0)
        if(sticker2DV3Featurea2dv3_0) then
            local effectManager = this:getEffectManager()
            local display_width = effectManager:getInputWidth()
            local display_height = effectManager:getInputHeight()
            if (sticker2DV3Featurea2dv3_0) then
                if(1.0*display_height/display_width > 960.0/540.0 ) then
                    sticker2DV3Featurea2dv3_0:playClip("entity38e195771ecd442e882c79634277fd51", "oneRelation_heightAlign", -1, 0)
                else
                    sticker2DV3Featurea2dv3_0:playClip("entity38e195771ecd442e882c79634277fd51", "oneRelation_widthAlign", -1, 0)
                end
            end
            
        end
        return true
    end,
    handleFaceActionEvent = function (this, faceIndex, action)
        local hasActionTriggered = false;

        if (hasActionTriggered) then
            eventDoneCount = eventDoneCount + 1
        end
        return true
    end,
    handleHandGestureEvent = function (this, handIndex, action)
        local hasActionTriggered = false;

        if (hasActionTriggered) then
            eventDoneCount = eventDoneCount + 1
        end
        return true
    end,
    handleAnimationEvent = function (this, entityName, clipName, eventCode)
        local hasActionTriggered = false;

        if (hasActionTriggered) then
            eventDoneCount = eventDoneCount + 1
        end
        return true
    end,
}