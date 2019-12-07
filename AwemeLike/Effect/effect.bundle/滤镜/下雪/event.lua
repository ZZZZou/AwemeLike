local display_height = 1280
local display_width = 720

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
                    Sticker2DV3.playClip(this, "2DStickerV3_5100", "entitynameE31CFB620948482BB2CB25E0D449CA08", "clipname1_heightAlign", 0)
                else
                    Sticker2DV3.playClip(this, "2DStickerV3_5100", "entitynameE31CFB620948482BB2CB25E0D449CA08", "clipname1_widthAlign", 0)
                end 
            end
        end
        return true
    end,
    }

