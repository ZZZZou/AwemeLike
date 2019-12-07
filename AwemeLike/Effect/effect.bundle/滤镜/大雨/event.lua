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
folder = "2DStickerV3_5101",
clip = { "clipname1", "clipname2","clipname1_Vertical", "clipname2_Vertical" }, 
entity = { "entityname65987788533645918C5D104AF82B9A49" }, 
}
EventHandles = {
    handleEffectEvent = function (this, eventCode)
        if (init_state == 1 and eventCode == 1) then
            init_state = 0
            local effectManager = this:getEffectManager()
            if effectManager then
                local display_width = effectManager:getInputWidth()
                local display_height = effectManager:getInputHeight()
                if (1.0 * display_height / display_width > 1.777777) then
                    Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip[3], 0)
                    Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip[4], 0)
                else
                    Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip[1], 0)
                    Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip[2], 0)
                end
            end
        end
        return true
    end,
    handleRecodeVedioEvent = function (this, eventCode)
        if (eventCode == 1) then
            local effectManager = this:getEffectManager()
            if effectManager then
                local display_width = effectManager:getInputWidth()
                local display_height = effectManager:getInputHeight()
                if (1.0 * display_height / display_width > 1.777777) then
                    Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip[3], 0)
                    Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip[4], 0)
                else
                    Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip[1], 0)
                    Sticker2DV3.playClip(this, feature_0.folder, feature_0.entity[1], feature_0.clip[2], 0)
                end
            end
        end
        return true
    end,
    }

