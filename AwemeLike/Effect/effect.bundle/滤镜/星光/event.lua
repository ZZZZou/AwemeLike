local display_height = 1280
local display_width = 720


EventHandles = 
{
    handleEffectEvent = function (this, eventCode)
        if (eventCode == 1) then
            local effectManager = this:getEffectManager()
            display_width = effectManager:getInputWidth()
            display_height = effectManager:getInputHeight()

                local feature_1 = this:getFeature("2DStickerV3_5101")
                local feature2DV3_1 = EffectSdk.castSticker2DV3Feature(feature_1)
                if(feature2DV3_1)then
                    if(1.0 * display_height / display_width < 16.0 / 9) then
                        feature2DV3_1:setVertices(
                                    "entityname9816F38B63E94A86A660A502F2922EC1",
                                    "clipname1_CA6F020B5C7A4A968A0C8A424BCBFF90",
                                    0,
                                    0,
                                    0-(-display_height+display_width*16.0/9)/2 / display_height
                        )
                        feature2DV3_1:setVertices(
                            "entityname9816F38B63E94A86A660A502F2922EC1",
                            "clipname1_CA6F020B5C7A4A968A0C8A424BCBFF90",
                            1,
                            1,
                            0-(-display_height+display_width*16.0/9)/2 / display_height
                        )
                        feature2DV3_1:setVertices(
                            "entityname9816F38B63E94A86A660A502F2922EC1",
                            "clipname1_CA6F020B5C7A4A968A0C8A424BCBFF90",
                            2,
                            0,
                            1+(-display_height+display_width*16.0/9)/2 / display_height
                        )
                        feature2DV3_1:setVertices(
                            "entityname9816F38B63E94A86A660A502F2922EC1",
                            "clipname1_CA6F020B5C7A4A968A0C8A424BCBFF90",
                            3,
                            1,
                            1+(-display_height+display_width*16.0/9)/2 / display_height
                        )
                    else
                        feature2DV3_1:setVertices(
                            "entityname9816F38B63E94A86A660A502F2922EC1",
                            "clipname1_CA6F020B5C7A4A968A0C8A424BCBFF90",
                            0,
                            0-(-display_width+display_height*9.0/16.0)/2/display_width,
                            0
                        )
                        feature2DV3_1:setVertices(
                            "entityname9816F38B63E94A86A660A502F2922EC1",
                            "clipname1_CA6F020B5C7A4A968A0C8A424BCBFF90",
                            1,
                            1+(-display_width+display_height*9.0/16.0)/2/display_width,
                            0
                        )
                        feature2DV3_1:setVertices(
                            "entityname9816F38B63E94A86A660A502F2922EC1",
                            "clipname1_CA6F020B5C7A4A968A0C8A424BCBFF90",
                            2,
                            0-(-display_width+display_height*9.0/16.0)/2/display_width,
                            1
                        )
                        feature2DV3_1:setVertices(
                            "entityname9816F38B63E94A86A660A502F2922EC1",
                            "clipname1_CA6F020B5C7A4A968A0C8A424BCBFF90",
                            3,
                            1+(-display_width+display_height*9.0/16.0)/2/display_width,
                            1
                        )
                    end
                end
                if (feature2DV3_1) then
                    feature2DV3_1:resetClip("entityname9816F38B63E94A86A660A502F2922EC1", "clipname1_CA6F020B5C7A4A968A0C8A424BCBFF90")
                    feature2DV3_1:playClip("entityname9816F38B63E94A86A660A502F2922EC1", "clipname1_CA6F020B5C7A4A968A0C8A424BCBFF90", -1, 0)
                end

                local feature_2 = this:getFeature("2DStickerV3_5100")
                local feature2DV3_2 = EffectSdk.castSticker2DV3Feature(feature_2)
                if(feature2DV3_2)then
                    if(1.0 * display_height / display_width < 16.0 / 9) then
                        feature2DV3_2:setVertices(
                                    "entityname65EA6565295D4532922E7C5FBC48F9B5",
                                    "clipname1_26EF815F67E44A2E9B6924A31C5891DE",
                                    0,
                                    0,
                                    0-(-display_height+display_width*16.0/9)/2 / display_height
                        )
                        feature2DV3_2:setVertices(
                            "entityname65EA6565295D4532922E7C5FBC48F9B5",
                            "clipname1_26EF815F67E44A2E9B6924A31C5891DE",
                            1,
                            1,
                            0-(-display_height+display_width*16.0/9)/2 / display_height
                        )
                        feature2DV3_2:setVertices(
                            "entityname65EA6565295D4532922E7C5FBC48F9B5",
                            "clipname1_26EF815F67E44A2E9B6924A31C5891DE",
                            2,
                            0,
                            1+(-display_height+display_width*16.0/9)/2 / display_height
                        )
                        feature2DV3_2:setVertices(
                            "entityname65EA6565295D4532922E7C5FBC48F9B5",
                            "clipname1_26EF815F67E44A2E9B6924A31C5891DE",
                            3,
                            1,
                            1+(-display_height+display_width*16.0/9)/2 / display_height
                        )
                    else
                        feature2DV3_2:setVertices(
                            "entityname65EA6565295D4532922E7C5FBC48F9B5",
                            "clipname1_26EF815F67E44A2E9B6924A31C5891DE",
                            0,
                            0-(-display_width+display_height*9.0/16.0)/2/display_width,
                            0
                        )
                        feature2DV3_2:setVertices(
                            "entityname65EA6565295D4532922E7C5FBC48F9B5",
                            "clipname1_26EF815F67E44A2E9B6924A31C5891DE",
                            1,
                            1+(-display_width+display_height*9.0/16.0)/2/display_width,
                            0
                        )
                        feature2DV3_2:setVertices(
                            "entityname65EA6565295D4532922E7C5FBC48F9B5",
                            "clipname1_26EF815F67E44A2E9B6924A31C5891DE",
                            2,
                            0-(-display_width+display_height*9.0/16.0)/2/display_width,
                            1
                        )
                        feature2DV3_2:setVertices(
                            "entityname65EA6565295D4532922E7C5FBC48F9B5",
                            "clipname1_26EF815F67E44A2E9B6924A31C5891DE",
                            3,
                            1+(-display_width+display_height*9.0/16.0)/2/display_width,
                            1
                        )
                    end
                end
                if (feature2DV3_2) then
                    feature2DV3_2:resetClip("entityname65EA6565295D4532922E7C5FBC48F9B5", "clipname1_26EF815F67E44A2E9B6924A31C5891DE")
                    feature2DV3_2:playClip("entityname65EA6565295D4532922E7C5FBC48F9B5", "clipname1_26EF815F67E44A2E9B6924A31C5891DE", -1, 0)
                end
        end
        return true
    end,
}
