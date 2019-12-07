
local CommonFunc = {
setFeatureEnabled = function (this, path, status)
    local feature = this:getFeature(path)
    if (feature) then
        feature:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED, status)
    end
end,
}
local init_state = 1
local timer_id_297 = 101
local timer_id_299 = 201
local timer_id_301 = 301
local timer_id_303 = 401
local timer_id_305 = 501
local timer_id_307 = 601
local timer_id_309 = 701
local timer_id_311 = 801
EventHandles = {
    handleEffectEvent = function (this, eventCode)
        if(init_state == 1) then 
            init_state = 0
            if (eventCode == 1) then
                CommonFunc.setFeatureEnabled(this, "GeneralEffect_5107", true)
                CommonFunc.setFeatureEnabled(this, "2DSticker_5106", true)
                CommonFunc.setFeatureEnabled(this, "2DSticker_5105", true)
                CommonFunc.setFeatureEnabled(this, "2DSticker_5104", true)
                CommonFunc.setFeatureEnabled(this, "2DSticker_5103", true)
                CommonFunc.setFeatureEnabled(this, "GeneralEffect_5102", true)
                CommonFunc.setFeatureEnabled(this, "Matting_5101", true)
                CommonFunc.setFeatureEnabled(this, "GeneralEffect_5100", true)
            end
        end
        return true
    end,
    }

