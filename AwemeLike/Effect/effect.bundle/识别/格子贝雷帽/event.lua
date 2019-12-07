
local CommonFunc = {
setFeatureEnabled = function (this, path, status)
    local feature = this:getFeature(path)
    if (feature) then
        feature:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED, status)
    end
end,
}

local FaceMakeupFunc = {
playMakeup = function (this, path, type)
    local feature = this:getFeature(path)
    local feature_makeup = EffectSdk.castFaceMakeupV2Feature(feature)
    if (feature_makeup) then
        feature_makeup:show(type)
        feature_makeup:seek(type, 0, 0)
        feature_makeup:play(type)
    end
end,
showMakeup = function (this, path, type)
    local feature = this:getFeature(path)
    local feature_makeup = EffectSdk.castFaceMakeupV2Feature(feature)
    if (feature_makeup) then
        feature_makeup:show(type)
    end
end,
hideMakeup = function (this, path, type)
    local feature = this:getFeature(path)
    local feature_makeup = EffectSdk.castFaceMakeupV2Feature(feature)
    if (feature_makeup) then
        feature_makeup:hide(type)
    end
end,
pauseMakeup = function (this, path, type)
    local feature = this:getFeature(path)
    local feature_makeup = EffectSdk.castFaceMakeupV2Feature(feature)
    if (feature_makeup) then
        feature_makeup:pause(type)
    end
end,
}

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, tonumber(string.sub(input, pos, st - 1)))
        pos = sp + 1
    end
    table.insert(arr, tonumber(string.sub(input, pos)))
    return arr
end

function getVersion()
    local version = {}
    if EffectSdk.getSDKVersion then
        local strVersion = EffectSdk.getSDKVersion()
        version = string.split(strVersion, ".")
    end
    return version
end

local init_state = 1
local timer_id_29 = 101
local timer_id_32 = 201
local timer_id_35 = 301
local timer_id_38 = 401
local timer_id_40 = 501
EventHandles = {
    handleEffectEvent = function (this, eventCode)
        if(init_state == 1 and eventCode == 1) then 
            init_state = 0
            local version = getVersion()
            if #version >=2 and (version[1] > 5 or (version[1] == 5 and version[2] >= 3)) then
                local effectmanager = this:getEffectManager()
                if effectmanager and effectmanager:getUseAmazing() then
                    print("HelloAmazing") 
                    this:addFeature("amazingfeature", true)
                    -- CommonFunc.setFeatureEnabled(this, "amazingfeature", true)
                else
                    print("HelloEffectSDK") 
                    this:addFeature("3DStickerV3_5104", true)
                    -- CommonFunc.setFeatureEnabled(this, "3DStickerV3_5104", true)
                    
                end
            else
                this:addFeature("3DStickerV3_5104", true)
                -- CommonFunc.setFeatureEnabled(this, "3DStickerV3_5104", true)
            end
            FaceMakeupFunc.playMakeup(this, "FaceMakeupV2_2999", "mouth_part2999")
            FaceMakeupFunc.playMakeup(this, "FaceMakeupV2_2999", "eye_part2998")
            FaceMakeupFunc.playMakeup(this, "FaceMakeupV2_2999", "mask2997")
            CommonFunc.setFeatureEnabled(this, "Filter_2998", true)
        end
        return true
    end,
    }

