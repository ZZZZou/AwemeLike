
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
playLastClip = function (this, path, entityName, clipName)
    local feature = this:getFeature(path)
    local feature_2dv3 = EffectSdk.castSticker2DV3Feature(feature)
    if (feature_2dv3) then
        feature_2dv3:resumeClip(entityName, clipName, false)
        feature_2dv3:appearClip(entityName, clipName, true)
    end
end,
}

local CommonFunc = {
    setFeatureEnabled = function (this, path, status)
        local feature = this:getFeature(path)
        if (feature) then
            feature:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED, status)
        end
    end,
}

function createRandomIndex (minValue, maxValue, last_value)
    local random_last_value = last_value
    while random_last_value == last_value
    do
        random_last_value = math.random(minValue, maxValue)
    end
    return random_last_value
end

local hasbit = function (x, p)
    return x % (p + p) >= p
end

local getDiffTime = function(begin, now)
    local diff = now - begin
    if diff < 0 then
        diff = diff + 86400
    end
    return diff
end

local init_state = 1
local gEyeBlinkState = 0
local gFinishPuzzle = 0
local path = "2DStickerV3_5104"
local entity = "entitynameD0F5EFB660344CAD8D0297D8FEB016AD"
local clips = {appear1 = "clipname1",appear2 = "clipname2", boom = "clipname4", flicker = "clipname3"}
local gBeginTimestamp = 0
local gCurrentTimestamp = 0
local gGrabTimerId = 999
local timeThis
local timeLast
local timeCumu
local timeDelta
local gFilter = 1
local gExposure = 0.0
local blurstate = true
local setShaderFloatUniform = function(this, name, effect, var, value)
    local feature = this:getFeature(name)
    if (feature) then
        local featureES = EffectSdk.castGeneralEffectFeature(feature)
        if (featureES) then
            featureES:setUniformFloat(effect, 3, var, value)
        end
    end
end


EventHandles = {
    handleEffectEvent = function (this, eventCode)
        if (eventCode == 1 and init_state == 1) then
            init_state = 0
            gEyeBlinkState = 0
            math.randomseed(tostring(os.time() + 100):reverse():sub(1, 7))
            gGrabTimerId = createRandomIndex(0,9999,gGrabTimerId)
            this:addTimer(gGrabTimerId, EffectSdk.BEF_TIMER_EVENT_CIRCLE, 5)
            local effectManager = this:getEffectManager()
            if effectManager then
                gBeginTimestamp = effectManager:getTimeStamp()
            end
            blurstate = true
        end
        return true
    end,

    handleTimerEvent = function (this, timerId, milliSeconds)
        if (timerId == gGrabTimerId) then 
            local effectManager = this:getEffectManager()
            if effectManager then
                gCurrentTimestamp = effectManager:getTimeStamp()
            end
            local frame = getDiffTime(gBeginTimestamp, gCurrentTimestamp)
            if frame > 3.0 then
                local effectManager = this:getEffectManager()
                if effectManager then
                    gBeginTimestamp = effectManager:getTimeStamp()
                end
                return true
            end
            local degree = 1.0
            degree =  math.max(0.0, math.sin((frame * math.pi + math.pi)/3.2))
            local feature = this:getFeature("blur")
            local ge_feature = EffectSdk.castGeneralEffectFeature(feature)
            if(ge_feature) then
                ge_feature:setUniformFloat("bufferB", 1, "radius", 5.0 * math.min(1.0,degree))
            end
        end
        return true
    end,
    }

