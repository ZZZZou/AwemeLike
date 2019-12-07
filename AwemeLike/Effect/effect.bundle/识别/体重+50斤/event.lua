
local CommonFunc = {
setFeatureEnabled = function (this, path, status)
    local feature = this:getFeature(path)
    if (feature) then
        feature:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED, status)
    end
end,
}
local init_state = 1
local timer_id_971 = 101
local timer_id_973 = 201
local timer_id_975 = 301
EventHandles = {
    handleEffectEvent = function (this, eventCode)
        if(init_state == 1) then 
            init_state = 0
            if (eventCode == 1) then
                CommonFunc.setFeatureEnabled(this, "FaceStretch_5102", true)
                CommonFunc.setFeatureEnabled(this, "FaceDistortionV2_5101", true)
                CommonFunc.setFeatureEnabled(this, "FaceMakeupV2_5100", true)
            end
        end
        return true
    end,
    }

