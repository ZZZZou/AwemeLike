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
                        feature2DV3_1:resetClip("entitynameF777F6FAE610459A83A8B789828D1A67", "clipname1_A318F34D263446908BDD73BEC47B67B2_heightAlign")
                        feature2DV3_1:playClip("entitynameF777F6FAE610459A83A8B789828D1A67", "clipname1_A318F34D263446908BDD73BEC47B67B2_heightAlign", -1, 0)
                    else
                        feature2DV3_1:resetClip("entitynameF777F6FAE610459A83A8B789828D1A67", "clipname1_A318F34D263446908BDD73BEC47B67B2_widthAlign")
                        feature2DV3_1:playClip("entitynameF777F6FAE610459A83A8B789828D1A67", "clipname1_A318F34D263446908BDD73BEC47B67B2_widthAlign", -1, 0)
                    end
                end
        end
        return true
    end,
}
