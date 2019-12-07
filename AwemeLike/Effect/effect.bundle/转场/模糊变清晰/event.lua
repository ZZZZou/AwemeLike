local display_height = 1280
local display_width = 720

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
        feature_2dv3:resetClip(entityName, clipName)
    end
end,
playLastClip = function (this, path, entityName, clipName)
    local feature = this:getFeature(path)
    local feature_2dv3 = EffectSdk.castSticker2DV3Feature(feature)
    if (feature_2dv3) then
        feature_2dv3:appearClip(entityName, clipName, true)
    end
end,
}

--return second
local getDiffTime = function(begin, now)
    local diff = now - begin
    if diff < 0 then
        diff = diff + 86400
    end
    return diff
end

function createRandomIndex (minValue, maxValue, last_value)
    local random_last_value = last_value
    while random_last_value == last_value
    do
        random_last_value = math.random(minValue, maxValue)
    end
    return random_last_value
end

local CommonFunc = {
setFeatureEnabled = function (this, path, status)
    local feature = this:getFeature(path)
    if (feature) then
        feature:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED, status)
    end
end,
}

local init_state = 1
--time
local gBeginTimestamp = 0
local gCurrentTimestamp = 0
local timer_id_render = 111
local gFrameCount = 0

--image
local gScale = 1.0
local fore = {path = "2DStickerV3_5100", entity = "entitynameAE31F9116E9946DBBE0AAB6211D3E16B", clipname = "clipname1", fps = 16}
EventHandles = {
    handleEffectEvent = function (this, eventCode)
        if (eventCode == 1 and init_state == 1) then
            init_state = 0
            math.randomseed(tostring(os.time() + 100):reverse():sub(1, 7))
            timer_id_render = createRandomIndex(1, 500, timer_id_render)
            local effectManager = this:getEffectManager()
            if effectManager then
                gBeginTimestamp = effectManager:getTimeStamp()
                display_width = effectManager:getInputWidth()
                display_height = effectManager:getInputHeight()
            end
            this:addTimer(timer_id_render, EffectSdk.BEF_TIMER_EVENT_CIRCLE, 5) --kuihua use 30fps
            if(1.0*display_height/display_width > 889.0/500.0 ) then
                Sticker2DV3.playClip(this, fore.path, fore.entity, fore.clipname .. "_heightAlign", 1)
            else
                Sticker2DV3.playClip(this, fore.path, fore.entity, fore.clipname .. "_widthAlign", 1)
            end
            -- Sticker2DV3.playClip(this, fore.path, fore.entity, fore.clipname, 1)
        end
        return true
    end,

    handleTimerEvent = function(this, timerId, milliSeconds)
        if (timerId == timer_id_render) then
            local effectManager = this:getEffectManager()
            if effectManager then
                gCurrentTimestamp = effectManager:getTimeStamp()
            end
            local delta = getDiffTime(gBeginTimestamp, gCurrentTimestamp)
            if delta > 1.5 then
                --restart
                gScale = 1.0
                CommonFunc.setFeatureEnabled(this, "GEA", true)
                CommonFunc.setFeatureEnabled(this, "GEB", true)
                local effectManager = this:getEffectManager()
                if effectManager then
                    gBeginTimestamp = effectManager:getTimeStamp()
                end
                delta = 0
                local feature = this:getFeature("GEA")
                local ge_feature = EffectSdk.castGeneralEffectFeature(feature)
                if ge_feature then
                    ge_feature:setUniformFloat("gx", 1, "uScale", 0.0)
                    ge_feature:setUniformFloat("gy", 1, "uScale", 0.0)
                end
                local feature = this:getFeature("GEB")
                local ge_feature = EffectSdk.castGeneralEffectFeature(feature)
                if ge_feature then
                    ge_feature:setUniformFloat("scale", 1, "u_scale", 1.0)
                end
                if(1.0*display_height/display_width > 889.0/500.0 ) then
                    Sticker2DV3.playClip(this, fore.path, fore.entity, fore.clipname .. "_heightAlign", 1)
                else
                    Sticker2DV3.playClip(this, fore.path, fore.entity, fore.clipname .. "_widthAlign", 1)
                end
            end
            gFrameCount =  delta * fore.fps
            if gFrameCount <= 10 then
                gScale = 1.0 + 0.05 *(1.0 - math.cos(gFrameCount/10 * math.pi))
            elseif gFrameCount <= 15 then
                -- body
                gScale = 1.1 + 0.025 *(1.0 - math.cos((gFrameCount-10)/(15-10) * math.pi))
            elseif gFrameCount <= 23 then
                -- body
                gScale = 1.0 + 0.075 *(1.0 + math.cos((gFrameCount-15)/(23-15) * math.pi))
            end
            local feature = this:getFeature("GEA")
            local ge_feature = EffectSdk.castGeneralEffectFeature(feature)
            if ge_feature then
                ge_feature:setUniformFloat("gx", 1, "uScale", 12 *(gScale-1.0))
                ge_feature:setUniformFloat("gy", 1, "uScale", 12 *(gScale-1.0))
            end
            local feature = this:getFeature("GEB")
            local ge_feature = EffectSdk.castGeneralEffectFeature(feature)
            if ge_feature then
                ge_feature:setUniformFloat("scale", 1, "u_scale", gScale)
            end
        end
        return true
    end,

    handleAnimationEvent = function(this, entityName, clipName, eventCode)
        if(eventCode==2 and entityName==fore.entity and string.find(clipName,fore.clipname)) then
            CommonFunc.setFeatureEnabled(this, "GEA", false)
            CommonFunc.setFeatureEnabled(this, "GEB", false)
        end
        return true
    end
    
    }

