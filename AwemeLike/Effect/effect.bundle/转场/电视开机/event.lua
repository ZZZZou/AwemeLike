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
local grabCount = 0
local black = 0.0
local xscale = 0.0
local yscale = 0.0
local timeCount = 0.0
local A = 0.0
local maxA = 100.0
local moveState = false

local entityname = "entityname56805399E59F44BD8145BF4B3C7B4369"
local path = "2DStickerV3_5101"
local wave = "clipname2"
local turnon = "clipname1"

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
local gBeginState = false
EventHandles = {
    handleEffectEvent = function(this, eventCode)
        if (init_state == 1 and eventCode == 1) then
            init_state = 0
            moveState = false
            timeCount = 0.0
            black = 0.0
            xscale = 0.15
            yscale = 1.0
            A = 0.0
            math.randomseed(tostring(os.time()):reverse():sub(1, 7))
            grabTimerId = createRandomIndex(1000,9999, grabTimerId)
            douTimerId = math.random(0,999)
            this:addTimer(grabTimerId, EffectSdk.BEF_TIMER_EVENT_CIRCLE, 5)
            Sticker2DV3.playClip(this, path, entityname, turnon, 1, 2)
            Sticker2DV3.stopClip(this, path, entityname, wave)
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
                gBeginState = false 
                gDouState = false
                moveState = false
                timeCount = 0.0
                black = 0.0
                xscale = 0.15
                yscale = 1.0
                A = 0.0
                Sticker2DV3.playClip(this, path, entityname, turnon, 1, 2)
                Sticker2DV3.stopClip(this, path, entityname, wave)
                CommonFunc.setFeatureEnabled(this, "GEA", true)
                CommonFunc.setFeatureEnabled(this, "GEB", true)
                local feature = this:getFeature("GEA")
                local ge_feature = EffectSdk.castGeneralEffectFeature(feature)
                if ge_feature then
                    ge_feature:setUniformFloat("distortion", 1, "u_black", 0)
                end
            end
            if (not gBeginState) or gDouState then
                return true
            end
            if delta > 500 and  gDouState == false then
                gDouState = true
                CommonFunc.setFeatureEnabled(this, "GEA", false)
                CommonFunc.setFeatureEnabled(this, "GEB", false)
            end
            black = math.min(black  + 0.2, 1.0)
            if black < 1.0 then
                moveState = false
            end
            xscale = math.max(0.0, xscale - 0.03)
            yscale = math.max(0.0, xscale - 0.0005)
            timeCount = (timeCount+1.0)%999
            local feature = this:getFeature("GEA")
            local ge_feature = EffectSdk.castGeneralEffectFeature(feature)
            if ge_feature then
                ge_feature:setUniformFloat("distortion", 1, "u_black", black)
                ge_feature:setUniformFloat("distortion", 1, "u_xscale", xscale)
                ge_feature:setUniformFloat("distortion", 1, "u_yscale", 0.0)
                ge_feature:setUniformFloat("distortion", 1, "u_time", timeCount/1000.0)
            end

            local feature = this:getFeature("GEB")
            local ge_feature = EffectSdk.castGeneralEffectFeature(feature)
            if ge_feature then
                A = (A + 1)%8
                ge_feature:setUniformFloat("dou", 1, "u_texeloffset", math.floor(A/4) * maxA)
                if moveState then
                    ge_feature:setUniformVec2("dou", 1, "u_moveoffset", (math.random(0, 2000)-1000)/50000, (math.random(0, 2000)-1000)/50000)
                    Sticker2DV3.stopClip(this, path, entityname, wave, 0)    
                    moveState = false
                else
                    ge_feature:setUniformVec2("dou", 1, "u_moveoffset", 0, 0)
                    Sticker2DV3.playClip(this, path, entityname, wave, 0, -1)
                    moveState = true
                end

            end
        end
        return true
    end,


    handleAnimationEvent = function (this, entityName, clipName, eventCode)
        if eventCode==2 and entityName == entityname and clipName == turnon then
            Sticker2DV3.stopClip(this, path, entityname, turnon)
            local effectManager = this:getEffectManager()
            if effectManager then
                gBeginTimeStamp = effectManager:getTimeStamp()
            end 
            gBeginState = true
        end
        return true
    end
}
