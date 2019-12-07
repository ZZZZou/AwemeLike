local initFlag = true
local width = 0.55
local xPos = -0.55
local speed = 0.04
local grabFramePath = "GrabFrame/"
local putFramePath = "PutFrame/"
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
        local grabFeature = this:getFeature(grabFramePath)
        local putFeature = this:getFeature(putFramePath)
        local grabFrame = EffectSdk.castGeneralEffectFeature(grabFeature)
        local putFrame = EffectSdk.castGeneralEffectFeature(putFeature)
        if (initFlag) then
            xPos = -width
            grabFrame:pushCommandGrab("mlcgTexture", 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
            putFrame:setUniformFloat("mlcg_1", 1, "xPos", xPos)
            initFlag = false
        else 
            xPos = xPos + speed
            putFrame:setUniformFloat("mlcg_1", 1, "xPos", xPos)
        end
        if (xPos > 1.0) then
            xPos = -width
            grabFrame:pushCommandRemove("mlcgTexture")
            grabFrame:pushCommandGrab("mlcgTexture", 0.0, 0.0, 1.0, 1.0, 1.0, 1.0)
            putFrame:setUniformFloat("mlcg_1", 1, "xPos", xPos)
        end
		return true
    end
}
