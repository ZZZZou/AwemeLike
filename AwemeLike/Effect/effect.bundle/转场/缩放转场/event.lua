local initFlag = true
local first = true
local blur = false
local status = 0
local gBeginTime = 0.0
local gCurrentTime = 0.0
local timerId1 = 12345
local scale1 = {
    1.0,
    1.022,
    1.1,
    1.261,
    1.564,
    2.176,
    3.01
}
local scale2 = {
    1.35,
    2.451,
    2.898,
    3.0
}
local blur = {
    0.0,
    0.0,
    0.0,
    20.0,
    30.0,
    40.0,
    50.0,
    50.0,
    40.0,
    10.0,
    0.0
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
        if (eventCode == 1 and initFlag == true) then
            initFlag = false
            math.randomseed(tostring(os.time()):reverse():sub(1, 7))
            timerId1 = math.random(10000, 99999)

            local feature_0 = this:getFeature("Grab0")
            local ge_0 = EffectSdk.castGeneralEffectFeature(feature_0)
            if (ge_0) then
                ge_0:pushCommandGrab("grab_orig", 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
            end

            this:addTimer(timerId1, EffectSdk.BEF_TIMER_EVENT_CIRCLE, 20)

            local effectManager = this:getEffectManager()
            if effectManager then
                gBeginTime = effectManager:getTimeStamp()
            end
        end
        return true
    end,
    handleTimerEvent = function(this, timerId, milliSeconds)
        if (timerId == timerId1) then
            local feature_0 = this:getFeature("Grab0")
            local ge_0 = EffectSdk.castGeneralEffectFeature(feature_0)
            if (ge_0) then
                ge_0:pushCommandGrab("grab_orig", 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
            end

            if (first) then
                first = false
                for i = 1, 2 do
                    local feature_1 = this:getFeature("GE_screen" .. i)
                    if (feature_1) then
                        feature_1:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED, true)
                    end
                end

                local feature_1 = this:getFeature("GE_blur")
                if (feature_1) then
                    feature_1:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED, true)
                end
            end

            local effectManager = this:getEffectManager()
            if effectManager then
                gCurrentTime = effectManager:getTimeStamp()
            end

            local frameCount = math.min(math.floor(getDiffTime(gBeginTime, gCurrentTime) * 16) + 1, #scale1 + #scale2)
            if (frameCount > #scale1 and status == 0) then
                status = 1
                local feature_0 = this:getFeature("GE_screen1")
                if (feature_0) then
                    feature_0:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED, false)
                end
            end

            if (status == 0) then
                local feature_0 = this:getFeature("GE_screen1")
                local ge_0 = EffectSdk.castGeneralEffectFeature(feature_0)
                if (ge_0) then
                    ge_0:setUniformFloat("screen1", 1, "scale", scale1[frameCount])
                end

                local feature_1 = this:getFeature("GE_blur")
                local ge_1 = EffectSdk.castGeneralEffectFeature(feature_1)
                if (ge_1) then
                    ge_1:setUniformFloat("blur", 1, "u_radius", blur[frameCount])
                    ge_1:setUniformFloat("blur1", 1, "u_radius", blur[frameCount])
                end
            elseif (status == 1) then
                local feature_0 = this:getFeature("GE_screen2")
                local ge_0 = EffectSdk.castGeneralEffectFeature(feature_0)
                if (ge_0) then
                    ge_0:setUniformFloat("screen2", 1, "scale", scale2[frameCount - #scale1])
                end

                local feature_1 = this:getFeature("GE_blur")
                local ge_1 = EffectSdk.castGeneralEffectFeature(feature_1)
                if (ge_1) then
                    ge_1:setUniformFloat("blur", 1, "u_radius", blur[frameCount])
                    ge_1:setUniformFloat("blur1", 1, "u_radius", blur[frameCount])
                end
            end

            if (frameCount >= #scale1 + #scale2 and status == 1) then
                status = 0

                -- print("cino delta: "..getDiffTime(gBeginTime, gCurrentTime))

                local effectManager = this:getEffectManager()
                if effectManager then
                    gBeginTime = effectManager:getTimeStamp()
                end

                local feature_0 = this:getFeature("GE_screen1")
                if (feature_0) then
                    feature_0:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED, true)
                end

                local ge_0 = EffectSdk.castGeneralEffectFeature(feature_0)
                if (ge_0) then
                    ge_0:setUniformFloat("screen1", 1, "scale", scale1[1])
                end
            end
        end
        return true
    end
}
