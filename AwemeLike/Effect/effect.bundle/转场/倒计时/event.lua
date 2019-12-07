local initialized = false
local gTimeBegin = 0
local gTimeCurrent = 0
local frameCount = 0
local gFPS = 16
local scale = 0
local angle = 0
-- local blur = 0
local last = false
local display_height = 1280
local display_width = 720
local fromStart = false

local timerId1 = 123456
local entity_name = "entitynameD0F04B13689246B3952BABD26181139E"

local getDiffTime = function(begin, now)
    local diff = now - begin
    if diff < 0 then
        diff = diff + 86400
    end
    return diff
end

EventHandles = {
    handleEffectEvent = function(this, eventCode)
        if (eventCode == 1 and initialized == false) then
            timerId1 = timerId1 + 1
            initialized = true
            local effectManager = this:getEffectManager()
            if effectManager then
                gTimeBegin = effectManager:getTimeStamp()
                display_width = effectManager:getInputWidth()
                display_height = effectManager:getInputHeight()
            end

            local feature_0 = this:getFeature("2DStickerV3")
            local sticker2DV3_0 = EffectSdk.castSticker2DV3Feature(feature_0)
            if (sticker2DV3_0) then
                if (1.0 * display_height / display_width > 889.0 / 500.0) then
                    sticker2DV3_0:resetClip(entity_name, "clipname1_heightAlign")
                    sticker2DV3_0:playClip(entity_name, "clipname1_heightAlign", -1, 1)
                else
                    sticker2DV3_0:resetClip(entity_name, "clipname1_widthAlign")
                    sticker2DV3_0:playClip(entity_name, "clipname1_widthAlign", -1, 1)
                end
            end
            blur = 0

            feature_0:addTimer(timerId1, EffectSdk.BEF_TIMER_EVENT_CIRCLE, 5)
        end
        return true
    end,
    handleTimerEvent = function(this, timerId, milliSeconds)
        local effectManager = this:getEffectManager()
        if effectManager then

        end
        if (timerId == timerId1) then
            local effectManager = this:getEffectManager()
            if effectManager then
                gTimeCurrent = effectManager:getTimeStamp()
                display_width = effectManager:getInputWidth()
                display_height = effectManager:getInputHeight()

                if (getDiffTime(gTimeBegin, gTimeCurrent) > 1.75) then
                    gTimeBegin = effectManager:getTimeStamp()
                    fromStart = true
                end
            end
            frameCount = getDiffTime(gTimeBegin, gTimeCurrent) * gFPS

            if (fromStart) then
                fromStart = false
                local feature_0 = this:getFeature("2DStickerV3")
                local sticker2DV3_0 = EffectSdk.castSticker2DV3Feature(feature_0)
                if (sticker2DV3_0) then
                    if (1.0 * display_height / display_width > 889.0 / 500.0) then
                        sticker2DV3_0:resetClip(entity_name, "clipname1_heightAlign")
                        sticker2DV3_0:playClip(entity_name, "clipname1_heightAlign", -1, 1)
                    else
                        sticker2DV3_0:resetClip(entity_name, "clipname1_widthAlign")
                        sticker2DV3_0:playClip(entity_name, "clipname1_widthAlign", -1, 1)
                    end
                end
            end

            if (frameCount <= 7 and frameCount > 0) then
                scale = frameCount * 0.028571
            elseif (frameCount > 7 and frameCount <= 13) then
                scale = (13 - frameCount) * 0.028571
            elseif (frameCount > 13 and frameCount <= 18) then
                scale = (frameCount - 13) * 0.04
            elseif (frameCount >= 20 and frameCount <= 24) then
                scale = 0.76 - (frameCount - 20) * 0.22
                angle = 3.14 / 6 - (frameCount - 20) * 3.14 / 18
                -- blur = 1
            elseif (frameCount > 28 and last == true) then
                -- blur = 0
                last = false
                local feature_0 = this:getFeature("2DStickerV3")
                local sticker2DV3_0 = EffectSdk.castSticker2DV3Feature(feature_0)
                if (sticker2DV3_0) then
                    if (1.0 * display_height / display_width > 889.0 / 500.0) then
                        sticker2DV3_0:appearClip(entity_name, "clipname1_heightAlign", false)
                        sticker2DV3_0:resumeClip(entity_name, "clipname1_heightAlign", false)
                    else
                        sticker2DV3_0:appearClip(entity_name, "clipname1_widthAlign", false)
                        sticker2DV3_0:resumeClip(entity_name, "clipname1_widthAlign", false)
                    end
                -- sticker2DV3_0:appearClip(entity_name, "clipname1", false)
                -- sticker2DV3_0:resumeClip(entity_name, "clipname1", false)
                end
            else
                -- blur = 0
            end
        end

        local feature_0 = this:getFeature("GE_count/")
        local ge_0 = EffectSdk.castGeneralEffectFeature(feature_0)
        if (ge_0) then
            ge_0:setUniformFloat("baseDraw", 1, "scaling", scale)
            ge_0:setUniformFloat("baseDraw", 1, "angle", angle)
            -- ge_0:setUniformInt("baseDraw", 1, "rotate_blur", blur)
        end
        return true
    end,
    handleAnimationEvent = function(this, entityName, clipName, eventCode)
        local effectManager = this:getEffectManager()
        if effectManager then
            display_width = effectManager:getInputWidth()
            display_height = effectManager:getInputHeight()
        end
        if (eventCode == 2 and entityName == entity_name and string.find(clipName, "clipname1")) then
            local feature_0 = this:getFeature("2DStickerV3")
            local sticker2DV3_0 = EffectSdk.castSticker2DV3Feature(feature_0)
            if (sticker2DV3_0) then
                if (1.0 * display_height / display_width > 889.0 / 500.0) then
                    sticker2DV3_0:resumeClip(entity_name, "clipname1_heightAlign", false)
                    sticker2DV3_0:appearClip(entity_name, "clipname1_heightAlign", true)
                else
                    sticker2DV3_0:resumeClip(entity_name, "clipname1_widthAlign", false)
                    sticker2DV3_0:appearClip(entity_name, "clipname1_widthAlign", true)
                end
                -- sticker2DV3_0:resumeClip(entity_name, "clipname1", false)
                -- sticker2DV3_0:appearClip(entity_name, "clipname1", true)
                last = true
            end
        end
        return true
    end
}
