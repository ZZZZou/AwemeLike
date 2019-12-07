local display_height = 1280
local display_width = 720

EventHandles = 
{
    handleEffectEvent = function (this, eventCode)
        if (eventCode == 1) then
                local feature_1 = this:getFeature("2DStickerV3_5100")
                local feature2DV3_1 = EffectSdk.castSticker2DV3Feature(feature_1)
                if (feature2DV3_1) then
                    local effectManager = this:getEffectManager()
                    display_width = effectManager:getInputWidth()
                    display_height = effectManager:getInputHeight()
                    if(1.0*display_height/display_width > 960.0/540.0 ) then        
                        feature2DV3_1:resetClip("entitynameD03C337BC632491191904EB91506ED15", "clipname1_ABB4908A8A8B4D21A21A2103A9F064D9_heightAlign")
                        feature2DV3_1:playClip("entitynameD03C337BC632491191904EB91506ED15", "clipname1_ABB4908A8A8B4D21A21A2103A9F064D9_heightAlign", -1, 0)
                    else
                        feature2DV3_1:resetClip("entitynameD03C337BC632491191904EB91506ED15", "clipname1_ABB4908A8A8B4D21A21A2103A9F064D9_widthAlign")
                        feature2DV3_1:playClip("entitynameD03C337BC632491191904EB91506ED15", "clipname1_ABB4908A8A8B4D21A21A2103A9F064D9_widthAlign", -1, 0)
                    end
                end
        end
        return true
    end,
}
