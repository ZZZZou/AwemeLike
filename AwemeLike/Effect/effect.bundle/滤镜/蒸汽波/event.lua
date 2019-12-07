 local display_height = 1280
local display_width = 720


EventHandles = 
{
    handleEffectEvent = function (this, eventCode)
        if (eventCode == 1) then
            local effectManager = this:getEffectManager()
            display_width = effectManager:getInputWidth()
            display_height = effectManager:getInputHeight()
                local feature_1 = this:getFeature("2DStickerV3_5100")
                local feature2DV3_1 = EffectSdk.castSticker2DV3Feature(feature_1)
                if (feature2DV3_1) then
                    if(1.0*display_height/display_width > 1334.0/750.0 ) then
                        feature2DV3_1:resetClip("entityname_heightAlign", "clipname")
                        feature2DV3_1:playClip("entityname_heightAlign", "clipname", -1, 0)
                    else
                        feature2DV3_1:resetClip("entityname_widthAlign", "clipname")
                        feature2DV3_1:playClip("entityname_widthAlign", "clipname", -1, 0)
                    end
                end

                local feature_2 = this:getFeature("2DStickerV3_5101")
                local feature2DV3_2 = EffectSdk.castSticker2DV3Feature(feature_2)
                if (feature2DV3_2) then
                    if(1.0*display_height/display_width > 1334.0/750.0 ) then
                        feature2DV3_2:resetClip("entityname_heightAlign", "clipname")
                        feature2DV3_2:playClip("entityname_heightAlign", "clipname", -1, 0)
                    else
                        feature2DV3_2:resetClip("entityname_widthAlign", "clipname")
                        feature2DV3_2:playClip("entityname_widthAlign", "clipname", -1, 0)
                    end
                end

                local feature_3 = this:getFeature("2DStickerV3_5102")
                local feature2DV3_3 = EffectSdk.castSticker2DV3Feature(feature_3)
                if (feature2DV3_3) then
                    if(1.0*display_height/display_width > 1334.0/750.0 ) then
                        feature2DV3_3:resetClip("entityname_heightAlign", "clipname")
                        feature2DV3_3:playClip("entityname_heightAlign", "clipname", -1, 0)
                    else
                        feature2DV3_3:resetClip("entityname_widthAlign", "clipname")
                        feature2DV3_3:playClip("entityname_widthAlign", "clipname", -1, 0)
                    end
                end
        end
        return true
    end
}
