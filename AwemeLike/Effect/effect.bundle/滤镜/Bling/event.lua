local init_state = 1
featurePath = 'GeneralEffect_5100'
num31 = 22
preIsPortrait = 1

function checkAspectRatio(this)
    local feature = this:getFeature(featurePath)
    if (feature) then
        local GEFeature = EffectSdk.castGeneralEffectFeature(feature)
        local effectManager = this:getEffectManager()
        if (effectManager) then
            local aspectRatio = effectManager:getInputAspectRatio()
            isPortrait = 1
            if (aspectRatio < 1.0) then
                isPortrait = 0
            end
            if preIsPortrait ~= isPortrait then
                for i = 1,num31 do
                    GEFeature:setUniformInt("31_"..i, 1, "isPortrait", isPortrait)
                end
                preIsPortrait = isPortrait
            end
        end
    end
end

EventHandles = 
{
    handleEffectEvent = function (this, eventCode)
    if(init_state == 1) then 
        init_state = 0
        print("eventCode",eventCode)
        if (eventCode == 1) then
            this:addTimer(3214349, EffectSdk.BEF_TIMER_EVENT_CIRCLE, 10)
            checkAspectRatio(this)
            local feature_1 = this:getFeature("GeneralEffect_5100")
            if (feature_1) then
                feature_1:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED, true)
            end
        end
        end
        return true
    end,

    handleTimerEvent = function (this, timerId, milliSeconds)
        if timerId ~= 3214349 then
            return
        end
        checkAspectRatio(this)
		return true
    end
}
