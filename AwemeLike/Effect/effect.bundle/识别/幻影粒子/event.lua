local initFlag = true
local count = 0
local delay = 1
local maxCount = delay * 6
local gTimerId = 98572
local stickerEntity = "entityname0955CBC8BAE74016BCE6BE07DBE63608"
local stickerClip = "clipname1"
local width = 8.0
local faceWidthMin = 50
local faceWidthMax = 550
local zoom = 0.6
local zoomMin = 0.4
local zoomMax = 1.0
local initTimerId = 235622
local initTimerId2 = 46363
local initTimerId3 = 46932
local initTimerId4 = 439832
local lerp = function(v0, v1, t)
    if t < 0 then
        t = 0
    end
    if t > 1 then
        t = 1
    end
    return (1 - t) * v0 + t * v1
end

EventHandles = {
    handleEffectEvent = function(this, eventCode)
        if initFlag and eventCode == 1 then
            this:addTimer(gTimerId, EffectSdk.BEF_TIMER_EVENT_CIRCLE, 10)
            local grabFeature = this:getFeature("GrabMatting")
            grabFeature = EffectSdk.castGeneralEffectFeature(grabFeature)
            if grabFeature then
                grabFeature:pushCommandGrab("grabMatting0", 0.0, 0.0, 1.0, 1.0, 0.5, 0.5)
                for i = 1, maxCount do
                    grabFeature:pushCommandGrab("grabMatting"..i, 0.0, 0.0, 1.0, 1.0, 0.5, 0.5)
                end
            end
            grabFeature = this:getFeature("GrabOrigin")
            if grabFeature then
                grabFeature = EffectSdk.castGeneralEffectFeature(grabFeature)
                grabFeature:pushCommandGrab("grabOrigin", 0.0, 0.0, 1.0, 1.0, 0.75, 0.75)
            end
            this:addTimer(initTimerId, EffectSdk.BEF_TIMER_EVENT_ONCE, 10)
            initFlag = false
        end
        return true
    end,
    handleTimerEvent = function(this, timerId, milliSeconds)
        if timerId == gTimerId then
            local grabFeature = this:getFeature("GrabOrigin")
            grabFeature = EffectSdk.castGeneralEffectFeature(grabFeature)
            if grabFeature then
                grabFeature:pushCommandGrab("grabOrigin", 0.0, 0.0, 1.0, 1.0, 0.75, 0.75)
            end
            local grabFeature2 = this:getFeature("GrabMatting")
            grabFeature2 = EffectSdk.castGeneralEffectFeature(grabFeature2)
            if grabFeature2 then
                for i = maxCount, 1, -1 do
                    grabFeature2:pushCommandMove("grabMatting" .. i - 1, "grabMatting" .. i)
                    grabFeature2:pushCommandRemove("grabMatting" .. i - 1)
                end
                grabFeature2:pushCommandGrab("grabMatting0", 0.0, 0.0, 1.0, 1.0, 0.5, 0.5)
            end     
        elseif timerId == initTimerId then
            local feature = this:getFeature("GESticker_Composite")  
            if feature then
                feature:setFeatureStatus(4, true)               
            end
            local feature2 = this:getFeature("GESticker_Matting")
            if  feature2 then
                feature2:setFeatureStatus(4, true)
            end        
            local stickerV3Feature = this:getFeature("2DStickerV3_5100")
            stickerV3Feature = EffectSdk.castSticker2DV3Feature(stickerV3Feature)
            if stickerV3Feature then
                stickerV3Feature:resetClip(stickerEntity, stickerClip)
                stickerV3Feature:playClip(stickerEntity, stickerClip, -1, 0)
            end        
            this:addTimer(initTimerId2, EffectSdk.BEF_TIMER_EVENT_ONCE, 10 )
        elseif timerId == initTimerId2 then
           
            this:addTimer(initTimerId3, EffectSdk.BEF_TIMER_EVENT_ONCE, 10 )
        elseif timerId == initTimerId3 then
            this:addTimer(initTimerId4, EffectSdk.BEF_TIMER_EVENT_ONCE, 10 )
        elseif timerId == initTimerId4 then
            local feature = this:getFeature("GESticker_Composite")   
            if feature then
                feature = EffectSdk.castGeneralEffectFeature(feature)
                feature:setUniformFloat("composite", 1, "u_init", 1.0)
            end
        end
    end,
    handleFaceInfoEvent = function(this, faceInfo)
        local left0 = faceInfo:getFaceRect(0).left
        local right0 = faceInfo:getFaceRect(0).right
        local faceWidth = math.abs(right0 - left0)
        width = lerp(2, 8, (faceWidth - faceWidthMin) / (faceWidthMax - faceWidthMin))
        -- zoom = lerp(zoomMin, zoomMax,(faceWidth - faceWidthMin) / (faceWidthMax - faceWidthMin))
        local matFeature = this:getFeature("GESticker_Matting")
        matFeature = EffectSdk.castGeneralEffectFeature(matFeature)
        if matFeature then
            matFeature:setUniformFloat("gx", 1, "scale", width)
            matFeature:setUniformFloat("gy", 1, "scale", width)
        end
        -- local compFeature = this:getFeature("GESticker_Composite")
        -- compFeature = EffectSdk.castGeneralEffectFeature(compFeature)
        -- if compFeature then
        --     compFeature:setUniformFloat("composite", 1, "u_zoom", zoom)
        -- end
    end
}
