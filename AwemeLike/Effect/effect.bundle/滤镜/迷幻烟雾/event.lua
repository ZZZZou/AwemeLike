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
    end
end,
playLastClip = function (this, path, entityName, clipName)
    local feature = this:getFeature(path)
    local feature_2dv3 = EffectSdk.castSticker2DV3Feature(feature)
    if (feature_2dv3) then
        feature_2dv3:resumeClip(entityName, clipName, false)
        feature_2dv3:appearClip(entityName, clipName, true)
    end
end,
}
local init_state = 1
EventHandles = {
    handleEffectEvent = function (this, eventCode)
        if (eventCode == 1 and init_state == 1) then
            init_state = 0
            local effectManager = this:getEffectManager()
            display_width = effectManager:getInputWidth()
            display_height = effectManager:getInputHeight()
            if(1.0*display_height/display_width > 854.0/480.0 ) then
                Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname689452B7C11248EB8A79D887E8645FDA", "clipname1_heightAlign", 0)
            else
                Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname689452B7C11248EB8A79D887E8645FDA", "clipname1_widthAlign", 0)
            end
            if(1.0*display_height/display_width > 854.0/480.0 ) then
                Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname689452B7C11248EB8A79D887E8645FDA", "clipname2_heightAlign", 0)
            else
                Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname689452B7C11248EB8A79D887E8645FDA", "clipname2_widthAlign", 0)
            end
            if(1.0*display_height/display_width > 889.0/500.0 ) then
                Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname689452B7C11248EB8A79D887E8645FDA", "clipname3_heightAlign", 0)
            else
                Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname689452B7C11248EB8A79D887E8645FDA", "clipname3_widthAlign", 0)
            end
            if(1.0*display_height/display_width > 854.0/480.0 ) then
                Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname689452B7C11248EB8A79D887E8645FDA", "clipname4_heightAlign", 0)
            else
                Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname689452B7C11248EB8A79D887E8645FDA", "clipname4_widthAlign", 0)
            end
            -- Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname689452B7C11248EB8A79D887E8645FDA", "clipname1", 0)
            -- Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname689452B7C11248EB8A79D887E8645FDA", "clipname2", 0)
            -- Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname689452B7C11248EB8A79D887E8645FDA", "clipname3", 0)
            -- Sticker2DV3.playClip(this, "2DStickerV3_5103", "entityname689452B7C11248EB8A79D887E8645FDA", "clipname4", 0)
        end
        return true
    end,
    }

