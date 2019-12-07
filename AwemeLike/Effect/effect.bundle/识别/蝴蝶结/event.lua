
local CommonFunc = {
setFeatureEnabled = function (this, path, status)
    local feature = this:getFeature(path)
    if (feature) then
        feature:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED, status)
    end
end,
}

local FaceMakeupFunc = {
playMakeup = function (this, path, type)
    local feature = this:getFeature(path)
    local feature_makeup = EffectSdk.castFaceMakeupV2Feature(feature)
    if (feature_makeup) then
        feature_makeup:show(type)
        feature_makeup:play(type)
        feature_makeup:seek(type, 0)
    end
end,
showMakeup = function (this, path, type)
    local feature = this:getFeature(path)
    local feature_makeup = EffectSdk.castFaceMakeupV2Feature(feature)
    if (feature_makeup) then
        feature_makeup:show(type)
    end
end,
hideMakeup = function (this, path, type)
    local feature = this:getFeature(path)
    local feature_makeup = EffectSdk.castFaceMakeupV2Feature(feature)
    if (feature_makeup) then
        feature_makeup:pause(type)
        feature_makeup:hide(type)
    end
end,
pauseMakeup = function (this, path, type, count)
    local feature = this:getFeature(path)
    local feature_makeup = EffectSdk.castFaceMakeupV2Feature(feature)
    if (feature_makeup) then
        feature_makeup:show(type)
        feature_makeup:pause(type)
        feature_makeup:seek(type, count)
    end
end,
}
local init_state = 1
local feature_0 = {
folder = "3DStickerV3_5107",
}
local feature_1 = {
folder = "FaceMakeupV2_2999",
makeupType = { "mask2999", "mouth_part2998", "eye_part2997", "pupil2996", "mask2995", "mask2994" }, 
}
local feature_2 = {
folder = "Filter_2998",
}
EventHandles = {
    handleEffectEvent = function (this, eventCode)
        if (init_state == 1 and eventCode == 1) then
            init_state = 0
            CommonFunc.setFeatureEnabled(this, feature_0.folder, true)
            FaceMakeupFunc.playMakeup(this, feature_1.folder, feature_1.makeupType[1])
            FaceMakeupFunc.playMakeup(this, feature_1.folder, feature_1.makeupType[2])
            FaceMakeupFunc.playMakeup(this, feature_1.folder, feature_1.makeupType[3])
            FaceMakeupFunc.playMakeup(this, feature_1.folder, feature_1.makeupType[4])
            FaceMakeupFunc.playMakeup(this, feature_1.folder, feature_1.makeupType[5])
            FaceMakeupFunc.playMakeup(this, feature_1.folder, feature_1.makeupType[6])
            CommonFunc.setFeatureEnabled(this, feature_2.folder, true)
        end
        return true
    end,
    }

