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
playLastClip = function(this, path, entityName, clipName)
    local feature = this:getFeature(path)
    local feature_2dv3 = EffectSdk.castSticker2DV3Feature(feature)
    if (feature_2dv3) then
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
local init_state = 1
local timer_id_953 = 101
local timer_id_955 = 201
EventHandles = {
    handleEffectEvent = function (this, eventCode)
        if(init_state == 1) then 
            init_state = 0
            if (eventCode == 1) then
                local effectManager = this:getEffectManager()
                display_width = effectManager:getInputWidth()
                display_height = effectManager:getInputHeight()
                if(1.0*display_height/display_width > 854.0/480.0 ) then
                    Sticker2DV3.playClip(this, "2DStickerV3_5107", "entityname09FEEEF574BC4B3AB60E2C1E3D286319", "clipname1_heightAlign", 0)
                else
                    Sticker2DV3.playClip(this, "2DStickerV3_5107", "entityname09FEEEF574BC4B3AB60E2C1E3D286319", "clipname1_widthAlign", 0)
                end
                if(1.0*display_height/display_width > 889.0/500.0 ) then
                    Sticker2DV3.playClip(this, "2DStickerV3_5107", "entityname09FEEEF574BC4B3AB60E2C1E3D286319", "clipname2_heightAlign", 0)
                else
                    Sticker2DV3.playClip(this, "2DStickerV3_5107", "entityname09FEEEF574BC4B3AB60E2C1E3D286319", "clipname2_widthAlign", 0)
                end
                if(1.0*display_height/display_width > 889.0/500.0 ) then
                    Sticker2DV3.playClip(this, "2DStickerV3_5107", "entityname09FEEEF574BC4B3AB60E2C1E3D286319", "clipname3_heightAlign", 0)
                else
                    Sticker2DV3.playClip(this, "2DStickerV3_5107", "entityname09FEEEF574BC4B3AB60E2C1E3D286319", "clipname3_widthAlign", 0)
                end
                if(1.0*display_height/display_width > 889.0/500.0 ) then
                    Sticker2DV3.playClip(this, "2DStickerV3_5107", "entityname09FEEEF574BC4B3AB60E2C1E3D286319", "clipname4_heightAlign", 0)
                else
                    Sticker2DV3.playClip(this, "2DStickerV3_5107", "entityname09FEEEF574BC4B3AB60E2C1E3D286319", "clipname4_widthAlign", 0)
                end
                if(1.0*display_height/display_width > 889.0/500.0 ) then
                    Sticker2DV3.playClip(this, "2DStickerV3_5107", "entityname09FEEEF574BC4B3AB60E2C1E3D286319", "clipname5_heightAlign", 0)
                else
                    Sticker2DV3.playClip(this, "2DStickerV3_5107", "entityname09FEEEF574BC4B3AB60E2C1E3D286319", "clipname5_widthAlign", 0)
                end
                if(1.0*display_height/display_width > 889.0/500.0 ) then
                    Sticker2DV3.playClip(this, "2DStickerV3_5107", "entityname09FEEEF574BC4B3AB60E2C1E3D286319", "clipname6_heightAlign", 0)
                else
                    Sticker2DV3.playClip(this, "2DStickerV3_5107", "entityname09FEEEF574BC4B3AB60E2C1E3D286319", "clipname6_widthAlign", 0)
                end
                CommonFunc.setFeatureEnabled(this, "GeneralEffect_5106", true)
                CommonFunc.setFeatureEnabled(this, "Filter_5105", true)
            end
        end
        return true
    end,
    }

