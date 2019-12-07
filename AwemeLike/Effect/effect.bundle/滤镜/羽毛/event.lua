EventHandles = 
{
    handleEffectEvent = function (this, eventCode)
        if (eventCode == 1) then
                local feature_1 = this:getFeature("2DStickerV3_5100")
                local feature2DV3_1 = EffectSdk.castSticker2DV3Feature(feature_1)
                if (feature2DV3_1) then
                    local effectManager = this:getEffectManager()
                    local display_width = effectManager:getInputWidth()
                    local display_height = effectManager:getInputHeight()
                    if(1.0*display_height/display_width > 960.0/540.0 ) then
                        feature2DV3_1:resetClip("entityname4807F356054944E1B92412CD34BC582B", "clipname1_239A2D382D26438F99FAF53A4C1F73E5_heightAlign")
                        feature2DV3_1:playClip("entityname4807F356054944E1B92412CD34BC582B", "clipname1_239A2D382D26438F99FAF53A4C1F73E5_heightAlign", -1, 0)
                    else
                        feature2DV3_1:resetClip("entityname4807F356054944E1B92412CD34BC582B", "clipname1_239A2D382D26438F99FAF53A4C1F73E5_widthAlign")
                        feature2DV3_1:playClip("entityname4807F356054944E1B92412CD34BC582B", "clipname1_239A2D382D26438F99FAF53A4C1F73E5_widthAlign", -1, 0)
                    end
                end
        end
        return true
    end,
}
