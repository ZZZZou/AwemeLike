local CommonFunc = {
    setFeatureEnabled = function(this, path, status)
        local feature = this:getFeature(path)
        if (feature) then
            feature:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED, status)
        end
    end
}
local init_state = 1

local gBeginTimestamp = 0
local gCurrentTimestamp = 0
local gGrabTimerId = 999
local gEyebrowState = false
local gCenterX = 0
local gCenterY = 0
local gDeltaX = 0
local gDeltaY = 0
local gRadius = 0

local array = {}
local move = {-2.5, -2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2, 2.5}
local big_move = {-6.0, -5.5, -5.0, -4.5, -4.0, 4.0, 4.5, 5.0, 5.5, 6.0}
local timer_count = 1
local sticker_0 = {
    folder = "2DStickerV3_5103",
    entity = "entitynameF5BDF692324A4DD6B72A6D25CB61A8A0"
}
local filters = {
    "Filter_2997", "Filter_2998"
}

function createRandomIndex(minValue, maxValue, last_value)
    local random_last_value = last_value
    while random_last_value == last_value do
        random_last_value = math.random(minValue, maxValue)
    end
    return random_last_value
end

function fract(x)
    return x - math.floor(x)
end

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
            math.randomseed(tostring(os.time() + 100):reverse():sub(1, 7))
            gGrabTimerId = createRandomIndex(0, 5000, gGrabTimerId)
            this:addTimer(gGrabTimerId, EffectSdk.BEF_TIMER_EVENT_CIRCLE, 5)
            local effectManager = this:getEffectManager()
            if effectManager then
                gBeginTimestamp = effectManager:getTimeStamp()
            end

            local feature_0 = this:getFeature(sticker_0.folder)
            local sticker2DV3_0 = EffectSdk.castSticker2DV3Feature(feature_0)
            if (sticker2DV3_0) then
                sticker2DV3_0:resetClip(sticker_0.entity, "clipname1")
                sticker2DV3_0:playClip(sticker_0.entity, "clipname1", -1, 0)
            end

            for i = 1, #filters do
                local feature_1 = this:getFeature(filters[i])
                if(feature_1) then
                    feature_1:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED, true)
                end
            end
        end
        return true
    end,
    handleTimerEvent = function(this, timerId, milliSeconds)
        if timerId == gGrabTimerId then
            local effectManager = this:getEffectManager()
            if effectManager then
                gCurrentTimestamp = effectManager:getTimeStamp()
            end
            local delta = getDiffTime(gBeginTimestamp, gCurrentTimestamp)
            local feature = this:getFeature("GEHead")
            feature = EffectSdk.castGeneralEffectFeature(feature)
            if feature then
                feature:setUniformFloat("wave", 1, "iTime", delta)
            end

            if (timer_count % 5 == 0) then
                if (timer_count % 400 == 0) then
                    local array_count = math.random(1, 10)
                    local stayed_color = math.random(1, 3)

                    local feature = this:getFeature("GEHead")
                    local ge_0 = EffectSdk.castGeneralEffectFeature(feature)
                    if (ge_0) then
                        ge_0:setUniformFloat("shift_color", 1, "move", big_move[array_count])
                        ge_0:setUniformInt("shift_color", 1, "stay_color", stayed_color)
                    end
                else
                    local array_count = math.random(1, 11)
                    local stayed_color = math.random(1, 3)

                    local feature = this:getFeature("GEHead")
                    local ge_0 = EffectSdk.castGeneralEffectFeature(feature)
                    if (ge_0) then
                        ge_0:setUniformFloat("shift_color", 1, "move", move[array_count])
                        ge_0:setUniformInt("shift_color", 1, "stay_color", stayed_color)
                    end
                end
            end
            timer_count = timer_count + 1
        end
        return true
    end,
    handleRecodeVedioEvent = function(this, eventCode)
        if (eventCode == 1) then
            local effectManager = this:getEffectManager()
            if effectManager then
                gBeginTimestamp = effectManager:getTimeStamp()
            end
            timer_count = 1
        end
        return true
    end
}
