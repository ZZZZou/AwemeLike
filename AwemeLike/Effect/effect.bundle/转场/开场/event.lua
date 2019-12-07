local init_state = 1
local timerId1 = 12345
local gTimeBegin = 0.0
local gTimeCurrent = 0.0
local m_bFirst = true
local upper = {
    0.5,
    0.5,
    0.4605855855855856,
    0.3795045045045045,
    0.2972972972972973,
    0.22409909909909909,
    0.16328828828828829,
    0.11373873873873874,
    0.07545045045045046,
    0.04504504504504504,
    0.02364864864864865,
    0.009009009009009009,
    0.0011261261261261261,
    0.0
}
local lower = {
    0.5,
    0.5,
    0.5382882882882883,
    0.6193693693693694,
    0.7015765765765766,
    0.7747747747747747,
    0.8355855855855856,
    0.8851351351351351,
    0.9234234234234234,
    0.9538288288288288,
    0.9752252252252253,
    0.9898648648648649,
    0.9977477477477478,
    1.0
}

local getDiffTime = function(begin, now)
    local diff = now - begin
    if diff < 0 then
        diff = diff + 86400
    end
    return diff
end

EventHandles = {
    handleEffectEvent = function(this, eventCode)
        if (init_state == 1 and eventCode == 1) then
            init_state = 0
            math.randomseed(tostring(os.time()):reverse():sub(1, 7))
            timerId1 = math.random(1000, 9999)

            local effectManager = this:getEffectManager()
            if effectManager then
                gTimeBegin = effectManager:getTimeStamp()
            end

            this:addTimer(timerId1, EffectSdk.BEF_TIMER_EVENT_CIRCLE, 10)
        end
        return true
    end,
    handleTimerEvent = function(this, timerId, milliSeconds)
        if (timerId == timerId1) then
            local effectManager = this:getEffectManager()
            if effectManager then
                if m_bFirst then
                    gTimeBegin = effectManager:getTimeStamp()
                    m_bFirst = false
                end
                gTimeCurrent = effectManager:getTimeStamp()
                if (getDiffTime(gTimeBegin, gTimeCurrent) >= 1.75) then
                    gTimeBegin = effectManager:getTimeStamp()
                end
            end

            local delta = getDiffTime(gTimeBegin, gTimeCurrent)
            local frameCount = math.min(math.floor(delta * 16) + 1, #upper)
            local feature_0 = this:getFeature("GE_black")
            local ge_0 = EffectSdk.castGeneralEffectFeature(feature_0)
            if (ge_0) then
                ge_0:setUniformFloat("black", 1, "upper", upper[frameCount])
                ge_0:setUniformFloat("black", 1, "lower", lower[frameCount])
            end
        end
        return true
    end
}
