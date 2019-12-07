local Sticker2DV3 = {
    playClip = function(this, path, entityName, clipName, playTimes, playSpeed)
        local feature = this:getFeature(path)
        local feature_2dv3 = EffectSdk.castSticker2DV3Feature(feature)
        if (feature_2dv3) then
            feature_2dv3:resetClip(entityName, clipName)
            feature_2dv3:playClip(entityName, clipName, playSpeed, playTimes)
        end
    end,
    stopClip = function(this, path, entityName, clipName)
        local feature = this:getFeature(path)
        local feature_2dv3 = EffectSdk.castSticker2DV3Feature(feature)
        if (feature_2dv3) then
            feature_2dv3:resumeClip(entityName, clipName, false)
            feature_2dv3:appearClip(entityName, clipName, false)
            feature_2dv3:resetClip(entityName, clipName)
        end
    end,
    playLastClip = function(this, path, entityName, clipName)
        local feature = this:getFeature(path)
        local feature_2dv3 = EffectSdk.castSticker2DV3Feature(feature)
        if (feature_2dv3) then
            feature_2dv3:appearClip(entityName, clipName, true)
        end
    end
}



local init_state = 1
local uniform_state = 0
local touch_state = 0 --0:none 1:move/end
local need_init = 1
local color_idx = 0

local grabTimerId = 477
local douTimerId = 470
local resetTimerId = 9999
local blackTimerId = 600
local grabCount = 0
local black = 0.0
local xscale = 0.0
local yscale = 0.0
local timeCount = 0.0
local A = 0.0
local maxA = 180.0
local moveState = false

local entityname = "entityname56805399E59F44BD8145BF4B3C7B4369"
local path = "2DStickerV3_5101"
local wave = "clipname2"
local turnoff = "clipname1"

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

local getDiffTime = function(begin, now)
    local diff = now - begin
    if diff < 0 then
        diff = diff + 86400
    end
    return diff
end

local gBeginTimeStamp = 0
local gCurrentTimeStamp = 0
local gDouState = false
EventHandles = {
    handleEffectEvent = function(this, eventCode)
        if (init_state == 1 and eventCode == 1) then
            init_state = 0
            moveState = false
            timeCount = 0.0
            black = 0.0
            xscale = 0.15
            yscale = 0.15
            A = 0.0
            math.randomseed(tostring(os.time()):reverse():sub(1, 7))
            grabTimerId = createRandomIndex(10000, 15000, grabTimerId)
            -- douTimerId = math.random(0,999)
            -- blackTimerId = math.random(10000, 19999)
            -- resetTimerId = createRandomIndex(10000, 15000, resetTimerId)
            this:addTimer(grabTimerId, EffectSdk.BEF_TIMER_EVENT_CIRCLE, 5)
            -- this:addTimer(douTimerId, EffectSdk.BEF_TIMER_EVENT_ONCE, 200)
            -- this:addTimer(resetTimerId, EffectSdk.BEF_TIMER_EVENT_CIRCLE, 1200)
            Sticker2DV3.playClip(this, path, entityname, wave, 0, -1)
            Sticker2DV3.stopClip(this, path, entityname, turnoff)
            local effectManager = this:getEffectManager()
            if effectManager then
                gBeginTimeStamp = effectManager:getTimeStamp()
            end 
        end
        return true
    end,


    handleTimerEvent = function(this, timerId, milliSeconds)
        if (timerId == grabTimerId) then
            local effectManager = this:getEffectManager()
            if effectManager then
                gCurrentTimeStamp = effectManager:getTimeStamp()
            end 
            local delta = getDiffTime(gBeginTimeStamp, gCurrentTimeStamp) * 1000
            if delta > 1200 then
                local effectManager = this:getEffectManager()
                if effectManager then
                    gBeginTimeStamp = effectManager:getTimeStamp()
                end 
                delta = 0
                gDouState = false
                moveState = false
                timeCount = 0.0
                black = 0.0
                xscale = 0.15
                yscale = 0.15
                A = 0.0
                Sticker2DV3.playClip(this, path, entityname, wave, 0, -1)
                Sticker2DV3.stopClip(this, path, entityname, turnoff)
            end
            if gDouState then
                return true
            end
            if delta > 200 and gDouState == false then
                gDouState = true
                Sticker2DV3.playClip(this, path, entityname, turnoff, 1, -1)
                local feature = this:getFeature("GEA")
                local ge_feature = EffectSdk.castGeneralEffectFeature(feature)
                if ge_feature then
                    ge_feature:setUniformInt("distortion", 1, "u_black", 1)
                end
                return true
            end
            xscale = math.max(0.0, xscale - 0.03)
            yscale = math.max(0.0, xscale - 0.0005)
            timeCount = (timeCount+1.0)%999
            local feature = this:getFeature("GEA")
            local ge_feature = EffectSdk.castGeneralEffectFeature(feature)
            if ge_feature then
                ge_feature:setUniformFloat("distortion", 1, "u_xscale", math.random(1,10)/100)
                ge_feature:setUniformFloat("distortion", 1, "u_yscale", math.random(100,400)/6000)
                ge_feature:setUniformFloat("distortion", 1, "u_time", timeCount/1000.0)
                ge_feature:setUniformInt("distortion", 1, "u_black", 0)
            end

            local feature = this:getFeature("GEB")
            local ge_feature = EffectSdk.castGeneralEffectFeature(feature)
            if ge_feature then
                A = (A + 1)%8
                ge_feature:setUniformFloat("dou", 1, "u_texeloffset", math.floor(A/4) * maxA)
            end
        end
        return true
    end,
}
