
local CommonFunc = {
setFeatureEnabled = function (this, path, status)
    local feature = this:getFeature(path)
    if (feature) then
        feature:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED, status)
    end
end,
}
local init_state = 1
local timer_id_13 = 101
local timer_id_15 = 201
local timer_id_17 = 301
EventHandles = {
    handleEffectEvent = function (this, eventCode)
        if(init_state == 1 and eventCode == 1) then
            init_state = 0
            CommonFunc.setFeatureEnabled(this, "3DStickerV3_5102", true)
            CommonFunc.setFeatureEnabled(this, "FaceMakeupV2_2999", true)
            CommonFunc.setFeatureEnabled(this, "Filter_2998", true)
        end
        return true
    end,
    }

