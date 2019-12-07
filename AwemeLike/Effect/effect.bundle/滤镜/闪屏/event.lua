
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
local timer_id_19 = 401
EventHandles = {
    handleTimerEvent = function (this, timerId, milliSeconds)
        if (timerId == timer_id_19) then
            CommonFunc.setFeatureEnabled(this, "Filter_5097", false)
            CommonFunc.setFeatureEnabled(this, "Filter_5100", true)
            timer_id_13 = timer_id_13 + 1
            this:addTimer(timer_id_13, EffectSdk.BEF_TIMER_EVENT_ONCE, 166)
            timer_id_19 = timer_id_19 + 1
        end
        if (timerId == timer_id_17) then
            CommonFunc.setFeatureEnabled(this, "Filter_5098", false)
            CommonFunc.setFeatureEnabled(this, "Filter_5097", true)
            timer_id_19 = timer_id_19 + 1
            this:addTimer(timer_id_19, EffectSdk.BEF_TIMER_EVENT_ONCE, 166)
            timer_id_17 = timer_id_17 + 1
        end
        if (timerId == timer_id_15) then
            CommonFunc.setFeatureEnabled(this, "Filter_5099", false)
            CommonFunc.setFeatureEnabled(this, "Filter_5098", true)
            timer_id_17 = timer_id_17 + 1
            this:addTimer(timer_id_17, EffectSdk.BEF_TIMER_EVENT_ONCE, 166)
            timer_id_15 = timer_id_15 + 1
        end
        if (timerId == timer_id_13) then
            CommonFunc.setFeatureEnabled(this, "Filter_5100", false)
            CommonFunc.setFeatureEnabled(this, "Filter_5099", true)
            timer_id_15 = timer_id_15 + 1
            this:addTimer(timer_id_15, EffectSdk.BEF_TIMER_EVENT_ONCE, 166)
            timer_id_13 = timer_id_13 + 1
        end
        return true
    end,
    handleEffectEvent = function (this, eventCode)
        if (eventCode == 1 and init_state == 1) then
            init_state = 0
            CommonFunc.setFeatureEnabled(this, "Filter_5100", true)
            timer_id_13 = timer_id_13 + 1
            this:addTimer(timer_id_13, EffectSdk.BEF_TIMER_EVENT_ONCE, 166)
        end
        return true
    end,
    }

