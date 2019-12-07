
local flag = true
featurePath = '2DStickerV3'
EventHandles =
{
    handleEffectEvent = function (this, eventCode)
        local feature = this:getFeature(featurePath)
        local stickerLightFeature = EffectSdk.castSticker2DV3Feature(feature)
        stickerLightFeature:playClip("entity", "leak", -1, 0)
        return true
    end,

}
