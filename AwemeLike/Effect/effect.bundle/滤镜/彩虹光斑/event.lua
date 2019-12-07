local display_height = 1280
local display_width = 720

local ResolutionAdaptation = {
    adaptationMethod492x540_topAlign = function (this, path,entityName, clipName )
        local effectManager = this:getEffectManager()
        display_width = effectManager:getInputWidth()
        display_height = effectManager:getInputHeight()
        local feature = this:getFeature(path)
        local feature2DV3 = EffectSdk.castSticker2DV3Feature(feature)
        if(feature2DV3)then
            if(1.0 * display_height / display_width < 16.0 / 9) then
                local deltav = ( 960.0 / 540 * display_width / display_height - 1.0  ) / 2
                local deltavprime = (492.0 / 540.0 *  display_width / display_height)
                feature2DV3:setVertices(
                    entityName,
                    clipName,
                    0,
                    0,
                    0-deltav
                )
                feature2DV3:setVertices(
                    entityName,
                    clipName,
                    1,
                    1,
                    0-deltav 
                )
                feature2DV3:setVertices(
                    entityName,
                    clipName,
                    2,
                    0,
                    0-deltav+deltavprime
                )
                feature2DV3:setVertices(
                    entityName,
                    clipName,
                    3,
                    1,
                    0-deltav+deltavprime
                )
            else
                local deltau = ( 9.0 / 16.0 * display_height / display_width   - 1.0 ) / 2.0
                local deltavprime = 492.0 / 960.0
                feature2DV3:setVertices(
                    entityName,
                    clipName,
                    0,
                    0.0-deltau,
                    0.0
                )
                feature2DV3:setVertices(
                    entityName,
                    clipName,
                    1,
                    1.0+deltau,
                    0.0
                )
                feature2DV3:setVertices(
                    entityName,
                    clipName,
                    2,
                    0.0-deltau,
                    0.0+deltavprime
                )
                feature2DV3:setVertices(
                    entityName,
                    clipName,
                    3,
                    1.0+deltau,
                    0.0+deltavprime
                )
            end
        end
    end
    }

local Sticker2DV3 = {
playClip = function (this, path, entityName, clipName, playTimes)
    local feature = this:getFeature(path)
    local feature_2dv3 = EffectSdk.castSticker2DV3Feature(feature)
    if (feature_2dv3) then
        feature_2dv3:resetClip(entityName, clipName)
        feature_2dv3:playClip(entityName, clipName, -1, playTimes)
    end
end,
stopClip = function (this, path, entityName, clipName)
    local feature = this:getFeature(path)
    local feature_2dv3 = EffectSdk.castSticker2DV3Feature(feature)
    if (feature_2dv3) then
        feature_2dv3:resumeClip(entityName, clipName, false)
        feature_2dv3:appearClip(entityName, clipName, false)
        feature_2dv3:resetClip(entityName, clipName)
    end
end,
playLastClip = function(this, path, entityName, clipName)
    local feature = this:getFeature(path)
    local feature_2dv3 = EffectSdk.castSticker2DV3Feature(feature)
    if (feature_2dv3) then
        feature_2dv3:appearClip(entityName, clipName, true)
    end
end,
}
local init_state = 1
EventHandles = {
    handleEffectEvent = function (this, eventCode)
        if(init_state == 1) then 
            init_state = 0
            if (eventCode == 1) then
                local effectManager = this:getEffectManager()
                display_width = effectManager:getInputWidth()
                display_height = effectManager:getInputHeight()
                if(1.0*display_height/display_width > 960.0/540.0 ) then
                    Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname6ABCBBFEBD6D4A78A06F7F6C84D87079", "clipname1_heightAlign", 0)
                else
                    Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname6ABCBBFEBD6D4A78A06F7F6C84D87079", "clipname1_widthAlign", 0)
                end
                ResolutionAdaptation.adaptationMethod492x540_topAlign(this, "2DStickerV3_5103", "entityname6ABCBBFEBD6D4A78A06F7F6C84D87079", "clipname2")
                Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname6ABCBBFEBD6D4A78A06F7F6C84D87079", "clipname2", 0)
                if(1.0*display_height/display_width > 960.0/540.0 ) then
                    Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname6ABCBBFEBD6D4A78A06F7F6C84D87079", "clipname3_heightAlign", 0)
                else
                    Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname6ABCBBFEBD6D4A78A06F7F6C84D87079", "clipname3_widthAlign", 0)
                end
                if(1.0*display_height/display_width > 960.0/540.0 ) then
                    Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname6ABCBBFEBD6D4A78A06F7F6C84D87079", "clipname4_heightAlign", 0)
                else
                    Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname6ABCBBFEBD6D4A78A06F7F6C84D87079", "clipname4_widthAlign", 0)
                end
            end
        end
        return true
    end,
    }

