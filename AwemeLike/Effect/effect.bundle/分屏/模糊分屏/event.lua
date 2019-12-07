local grabFramePath = "GrabFrame/"

EventHandles = {
    handleEffectEvent = function(this, eventCode)
        this:addTimer(32527137, EffectSdk.BEF_TIMER_EVENT_CIRCLE, 10)
        return true
    end,
    handleTimerEvent = function(this, timerId, milliSeconds)
        if timerId ~= 32527137 then
            return
        end
        local grabFeature = this:getFeature(grabFramePath)
        local grabFrame = EffectSdk.castGeneralEffectFeature(grabFeature)

        if (grabFrame) then
            grabFrame:pushCommandGrab("frame" .. 0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
        end
        return true
    end
}
