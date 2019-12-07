local initFlag = true
local featureGrabPath = "GrabFrame/"
local featureGEPath = "PutFrame/"

local diff = 30
local count = 0
local intensity = 0.0

EventHandles =
{
    handleEffectEvent = function (this, eventCode)
                            this:addTimer( 3214349, EffectSdk.BEF_TIMER_EVENT_CIRCLE, 10)
                            return true
                        end,
    handleTimerEvent = function (this, timerId, milliSeconds)
        if timerId ~= 3214349 then
            return
        end
        local grab = this:getFeature(featureGrabPath)
        local ge = this:getFeature(featureGEPath)
        local featureGrab = EffectSdk.castGeneralEffectFeature(grab)
        local featureGE = EffectSdk.castGeneralEffectFeature(ge)
        
        if count == 0 then
            intensity = 0.0
            featureGE:setUniformFloat("mili", 1, "intensity", 0.0)
            featureGrab:pushCommandGrab("display_texture", 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
        else
            intensity = intensity + 1.0 / diff
            if intensity > 1.0 then
                intensity = 1.0
            end
            featureGE:setUniformFloat("mili", 1, "intensity", intensity)
        end

        count = count + 1
        count = count % diff
		return true
    end
}
