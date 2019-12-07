local display_height = 1280
local display_width = 720

local CommonFunc = { 
setFeatureEnabled = function (this, path, status)
    local feature = this:getFeature(path)
    if (feature) then
        feature:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED, status)
    end
end,
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
    end
end,
} 
local init_state = 1
local feature_0 = {
folder = "2DStickerV3_5102",
clip_height = { "clipname1_heightAlign", "clipname2_heightAlign", "clipname3_heightAlign" }, 
clip_width = { "clipname1_widthAlign", "clipname2_widthAlign", "clipname3_widthAlign" }, 
entity = { "entitynameCAD30638EC524D0E8F0F1D98A8540E75" }, 
}
EventHandles = {
    handleEffectEvent = function (this, eventCode)
        CommonFunc.setFeatureEnabled(this, feature_0.folder, true)
        if (init_state == 1 and eventCode == 1) then
            init_state = 0
            local effectManager = this:getEffectManager()
            if(effectManager) then
                display_width = effectManager:getInputWidth()
                display_height = effectManager:getInputHeight()
            end
            if(1.0*display_height/display_width > 818.0/460.0 ) then
                Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_height[1], 0)
                Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_height[2], 0)
                Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_height[3], 0)
            else
                Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_width[1], 0)
                Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_width[2], 0)
                Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_width[3], 0)
            end
        end
        return true
    end,
    handleRecodeVedioEvent = function (this, eventCode)
        if (eventCode == 1) then
            local effectManager = this:getEffectManager()
            if(effectManager) then
                display_width = effectManager:getInputWidth()
                display_height = effectManager:getInputHeight()
            end
            if(1.0*display_height/display_width > 818.0/460.0 ) then
                Sticker2DV3.stopClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_height[1])
                Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_height[1], 0)
                Sticker2DV3.stopClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_height[2])
                Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_height[2], 0)
                Sticker2DV3.stopClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_height[3])
                Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_height[3], 0)
            else
                Sticker2DV3.stopClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_width[1])
                Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_width[1], 0)
                Sticker2DV3.stopClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_width[2])
                Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_width[2], 0)
                Sticker2DV3.stopClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_width[3])
                Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip_width[3], 0)
            end 
        end
        return true
    end,
    }

