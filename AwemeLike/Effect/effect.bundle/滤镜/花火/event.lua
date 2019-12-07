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
                    if (feature2DV3_1) then
                        if(1.0*display_height/display_width > 960.0/540.0 ) then
                            feature2DV3_1:resetClip("entitynameD0CDD7E0109F4868AACA571AFC5B522D", "clipname1_041FD28D3E6E4C29955FEEA5D39B4969_heightAlign")
                            feature2DV3_1:playClip("entitynameD0CDD7E0109F4868AACA571AFC5B522D", "clipname1_041FD28D3E6E4C29955FEEA5D39B4969_heightAlign", -1, 0)
                        else
                            feature2DV3_1:resetClip("entitynameD0CDD7E0109F4868AACA571AFC5B522D", "clipname1_041FD28D3E6E4C29955FEEA5D39B4969_widthAlign")
                            feature2DV3_1:playClip("entitynameD0CDD7E0109F4868AACA571AFC5B522D", "clipname1_041FD28D3E6E4C29955FEEA5D39B4969_widthAlign", -1, 0)        
                        end
                    end
                   end
        end
        return true
    end,
}
