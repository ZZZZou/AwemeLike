local ResolutionAdaptation = {
adaptationMethod16x9 = function (this, path,entityName, clipName )
    local effectManager = this:getEffectManager()
    local display_width = effectManager:getInputWidth()
    local display_height = effectManager:getInputHeight()
    local feature = this:getFeature(path)
    local feature2DV3 = EffectSdk.castSticker2DV3Feature(feature)
    if(feature2DV3)then
        if(1.0 * display_height / display_width < 16.0 / 9) then
            local deltav = (-display_height+display_width*16.0/9)/2/display_height
            feature2DV3:setVertices(
                entityName,
                clipName,
                0,
                0,
                0-deltav
            )
            feature2DV3:setVertices(
                entityName,
                clipName,
                1,
                1,
                0-deltav 
            )
            feature2DV3:setVertices(
                entityName,
                clipName,
                2,
                0,
                1+deltav
            )
            feature2DV3:setVertices(
                entityName,
                clipName,
                3,
                1,
                1+deltav
            )
        else
            local deltau = (-display_width+display_height*9.0/16.0)/2/display_width
            feature2DV3:setVertices(
                entityName,
                clipName,
                0,
                0-deltau,
                0
            )
            feature2DV3:setVertices(
                entityName,
                clipName,
                1,
                1+deltau,
                0
            )
            feature2DV3:setVertices(
                entityName,
                clipName,
                2,
                0-deltau,
                1
            )
            feature2DV3:setVertices(
                entityName,
                clipName,
                3,
                1+deltau,
                1
            )
        end
    end
end,
adaptationMethod648x540 = function (this, path,entityName, clipName )
    local effectManager = this:getEffectManager()
    local display_width = effectManager:getInputWidth()
    local display_height = effectManager:getInputHeight()
    local feature = this:getFeature(path)
    local feature2DV3 = EffectSdk.castSticker2DV3Feature(feature)
    if(feature2DV3)then
        if(1.0 * display_height / display_width < 16.0 / 9) then
            local deltav = ( 648.0 / 540 * display_width / display_height - 1.0  ) / 2
            feature2DV3:setVertices(
                entityName,
                clipName,
                0,
                0,
                0-deltav
            )
            feature2DV3:setVertices(
                entityName,
                clipName,
                1,
                1,
                0-deltav 
            )
            feature2DV3:setVertices(
                entityName,
                clipName,
                2,
                0,
                1+deltav
            )
            feature2DV3:setVertices(
                entityName,
                clipName,
                3,
                1,
                1+deltav
            )
        else
            local deltau = ( 9.0 / 16.0 * display_height / display_width   - 1.0 ) / 2.0
            local deltav = (1.0 - 648.0 / 960.0) / 2.0
            feature2DV3:setVertices(
                entityName,
                clipName,
                0,
                0.0-deltau,
                0.0+deltav
            )
            feature2DV3:setVertices(
                entityName,
                clipName,
                1,
                1.0+deltau,
                0.0+deltav
            )
            feature2DV3:setVertices(
                entityName,
                clipName,
                2,
                0.0-deltau,
                1.0-deltav
            )
            feature2DV3:setVertices(
                entityName,
                clipName,
                3,
                1.0+deltau,
                1.0-deltav
            )
        end
    end
end
}


local Sticker2DV3 = {
playClip = function (this, path, entityName, clipName, playTimes)
    if (clipName == "clipname3") then 
        ResolutionAdaptation.adaptationMethod648x540(this, path ,entityName, clipName )
    else
        ResolutionAdaptation.adaptationMethod16x9(this, path ,entityName, clipName )
    end
    
    local feature = this:getFeature(path)
    local feature_2dv3 = EffectSdk.castSticker2DV3Feature(feature)
    if (feature_2dv3) then
        feature_2dv3:resetClip(entityName, clipName)
        feature_2dv3:playClip(entityName, clipName, -1, playTimes)
    end
end,
stopClip = function (this, path, entityName, clipName)
    if (clipName == "clipname3") then 
        ResolutionAdaptation.adaptationMethod648x540(this, path ,entityName, clipName )
    else
        ResolutionAdaptation.adaptationMethod16x9(this, path ,entityName, clipName )
    end
    local feature = this:getFeature(path)
    local feature_2dv3 = EffectSdk.castSticker2DV3Feature(feature)
    if (feature_2dv3) then
        feature_2dv3:resumeClip(entityName, clipName, false)
        feature_2dv3:appearClip(entityName, clipName, false)
        feature_2dv3:resetClip(entityName, clipName)
    end
end,
playLastClip = function(this, path, entityName, clipName)
    if (clipName == "clipname3") then 
        ResolutionAdaptation.adaptationMethod648x540(this, path ,entityName, clipName )
    else
        ResolutionAdaptation.adaptationMethod16x9(this, path ,entityName, clipName )
    end
    local feature = this:getFeature(path)
    local feature_2dv3 = EffectSdk.castSticker2DV3Feature(feature)
    if (feature_2dv3) then
        feature_2dv3:appearClip(entityName, clipName, true)
    end
end,
}
local init_state = 1
EventHandles = {
    handleEffectEvent = function (this, eventCode)
        if(init_state == 1) then 
            init_state = 0
            if (eventCode == 1) then
                Sticker2DV3.playClip(this, "2DStickerV3_5105", "entitynameC1ED3190F808475693FD3C92998584C9", "clipname1", 0)
                Sticker2DV3.playClip(this, "2DStickerV3_5105", "entitynameC1ED3190F808475693FD3C92998584C9", "clipname2", 0)
                Sticker2DV3.playClip(this, "2DStickerV3_5105", "entitynameC1ED3190F808475693FD3C92998584C9", "clipname3", 0)
                Sticker2DV3.playClip(this, "2DStickerV3_5105", "entitynameC1ED3190F808475693FD3C92998584C9", "clipname4", 0)
                Sticker2DV3.playClip(this, "2DStickerV3_5105", "entitynameC1ED3190F808475693FD3C92998584C9", "clipname5", 0)
                Sticker2DV3.playClip(this, "2DStickerV3_5105", "entitynameC1ED3190F808475693FD3C92998584C9", "clipname6", 0)
            end
        end
        return true
    end,
    }

