local getPre = false
local getPrePre = false
local path = 'GESticker_BlingBling4/'
local curFrame = 2

EventHandles =
{
    handleEffectEvent = function (this, eventCode)
        this:addTimer(3214349, EffectSdk.BEF_TIMER_EVENT_CIRCLE, 1)
        return true
    end,
    handleTimerEvent = function (this, timerId, milliSeconds)
        if timerId ~= 3214349 then
            return
        end

        local feature = this:getFeature(path)
        if feature then
            local thisFeature = EffectSdk.castGeneralEffectFeature(feature)

            local effectManager = this:getEffectManager()
            if (effectManager) then
                local aspectRatio = effectManager:getInputAspectRatio()
                thisFeature:setUniformFloat("loveShape", 1, "aspectRatio", aspectRatio)
            end

            if (not getPrePre) then
                thisFeature:pushCommandGrab("frame0", 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, "history")
                getPrePre = true
                return true
            end

            if (not getPre) then
                thisFeature:pushCommandGrab("frame1", 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, "history")
                getPre = true
                return true
            end

            thisFeature:setUniformInt("smooth", 1, "ready", 1)
            thisFeature:pushCommandGrab("frame"..curFrame, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, "history")

            thisFeature:setUniformRenderCache("smooth", 1, "inputPreviousImageTexture", "frame" .. ((curFrame + 2) % 3))
            thisFeature:setUniformRenderCache("smooth", 1, "inputPrePreImageTexture", "frame" .. ((curFrame + 1) % 3))

            curFrame = curFrame + 1
            if curFrame > 2 then
                curFrame = 0
            end
        end

        return true
    end
}
