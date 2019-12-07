local initFlag = true
local canTrigger = true
local timerId1 = 12345
local count = 1
local gTimeBegin = 0
local gTimeCurrent = 0

local general_0 = "GE_show"
local move = {
    {x = 0.118518519, y = 0.072916667},
    {x = 0.119559114, y = 0.070314873},
    {x = 0.122671482, y = 0.063107442},
    {x = 0.128003284, y = 0.052217769},
    {x = 0.13571597, y = 0.038575979},
    {x = 0.14577575, y = 0.023101058},
    {x = 0.157824674, y = 0.00667115529031},
    {x = 0.17114710000263, y = -0.009922094},
    {x = 0.18468368815446, y = -0.025982692},
    {x = 0.19708803093111, y = -0.040914594},
    {x = 0.20676698651337, y = -0.054158902},
    {x = 0.21204338213383, y = -0.065048052},
    {x = 0.21229349545643, y = -0.072433204},
    {x = 0.21111111111111, y = -0.075},
    {x = 0.21028743024939, y = -0.076212377},
    {x = 0.20779968212584, y = -0.079222677},
    {x = 0.20175291553545, y = -0.08177258},
    {x = 0.19467259129903, y = -0.078865967},
    {x = 0.18773696357388, y = -0.076608604},
    {x = 0.1819070240526, y = -0.076734199},
    {x = 0.17976481719367, y = -0.077207308},
    {x = 0.18773581813141, y = -0.081601113},
    {x = 0.20946322911896, y = -0.086143997},
    {x = 0.22173151706244, y = -0.08749092},
    {x = 0.22239940866695, y = -0.087547664},
    {x = 0.22425222492715, y = -0.087777716},
    {x = 0.22702400248022, y = -0.088324174},
    {x = 0.23047914470308, y = -0.089251305},
    {x = 0.23466699502785, y = -0.090215434},
    {x = 0.2396692142756, y = -0.090382089},
    {x = 0.24483144211656, y = -0.089518644},
    {x = 0.24976673797017, y = -0.088070373},
    {x = 0.25443414392955, y = -0.086347832},
    {x = 0.25877449026264, y = -0.084536179},
    {x = 0.26272086241761, y = -0.082760214},
    {x = 0.26617877471684, y = -0.081125427},
    {x = 0.2690584468493, y = -0.079717952},
    {x = 0.27126323814905, y = -0.078615989},
    {x = 0.2726801255985, y = -0.077897818},
    {x = 0.27318179752695, y = -0.07764178},
    {x = 0.27539446710134, y = -0.075886411},
    {x = 0.27906045782632, y = -0.070472811},
    {x = 0.28309059044975, y = -0.062402202},
    {x = 0.28784127651796, y = -0.052823448},
    {x = 0.2938131661088, y = -0.042912984},
    {x = 0.30147519302936, y = -0.033965668},
    {x = 0.31079305066419, y = -0.027456511},
    {x = 0.31952954869245, y = -0.024452041},
    {x = 0.32322881788195, y = -0.023870652},
    {x = 0.32903287946536, y = -0.024644665},
    {x = 0.34208735517467, y = -0.027995873},
    {x = 0.35775634016309, y = -0.031887488},
    {x = 0.37137980569192, y = -0.034428283},
    {x = 0.37726142551241, y = -0.035120858},
    {x = 0.388233292010643, y = -0.035210924},
    {x = 0.3944363388028, y = -0.034962112},
    {x = 0.40885179397723, y = -0.034417264},
    {x = 0.42090321915549, y = -0.033749493},
    {x = 0.42592592592593, y = -0.033333333},
    {x = 0.44021577146277, y = -0.027822785},
    {x = 0.43968705740814, y = -0.009454641},
    {x = 0.43333333333333, y = 0.0}
}
local alpha = {
    0,
    0.04705882352941,
    0.09411764705882,
    0.14117647058824,
    0.18823529411765,
    0.23529411764706,
    0.28235294117647,
    0.32941176470588,
    0.37647058823529,
    0.42352941176471,
    0.47058823529412,
    0.51764705882353,
    0.56470588235294,
    0.61176470588235,
    0.65882352941176,
    0.70588235294118,
    0.75294117647059,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.8,
    0.76190476190476,
    0.72380952380952,
    0.68571428571429,
    0.64761904761905,
    0.60952380952381,
    0.57142857142857,
    0.53333333333333,
    0.4952380952381,
    0.45714285714286,
    0.41904761904762,
    0.38095238095238,
    0.34285714285714,
    0.3047619047619,
    0.26666666666667,
    0.22857142857143,
    0.19047619047619,
    0.15238095238095,
    0.11428571428571,
    0.07619047619048,
    0.03809523809524,
    0,
    0
}
local shift_c = {
    0.01,
    0.01,
    0.01,
    0.01,
    0.01,
    0.01,
    0.01,
    0.01,
    0.01,
    0.01,
    0.01,
    0.01,
    0.01,
    0.009,
    0.008,
    0.007,
    0.006,
    0.005,
    0.004,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.003,
    0.002,
    0.002,
    0.002,
    0.001,
    0.001,
    0.001,
    0,
    0,
    0
}

local getDiffTime = function(begin, now)
    local diff = now - begin
    if diff < 0 then
        diff = diff + 86400
    end
    return diff
end

function init(this)
    canTrigger = true

    local feature_0 = this:getFeature(general_0)
    local ge_0 = EffectSdk.castGeneralEffectFeature(feature_0)
    if (ge_0) then
        ge_0:setUniformVec2("show_effect", 1, "move", 0.0, 0.0)
        ge_0:setUniformFloat("show_effect", 1, "alpha", 0.0)
    end
end

EventHandles = {
    handleEffectEvent = function(this, eventCode)
        if (eventCode == 1 and initFlag == true) then
            initFlag = false
            math.randomseed(tostring(os.time()):reverse():sub(1, 7))
            timerId1 = math.random(10000, 99999)
            init(this)
            this:addTimer(timerId1, EffectSdk.BEF_TIMER_EVENT_CIRCLE, 10)

            local effectManager = this:getEffectManager()
            if effectManager then
                gTimeBegin = effectManager:getTimeStamp()
            end
        end
        return true
    end,
    handleTimerEvent = function(this, timerId)
        if (timerId == timerId1) then
            local effectManager = this:getEffectManager()
            if effectManager then
                gTimeCurrent = effectManager:getTimeStamp()
            end

            local delta = getDiffTime(gTimeBegin, gTimeCurrent)
            local frameCount = math.min(math.floor(delta * 16) + 1, #alpha)
            local feature_0 = this:getFeature(general_0)
            local ge_0 = EffectSdk.castGeneralEffectFeature(feature_0)
            if (ge_0) then
                ge_0:setUniformVec2("show_effect", 1, "move", move[frameCount].x, move[frameCount].y)
                ge_0:setUniformFloat("show_effect", 1, "alpha", alpha[frameCount])
                ge_0:setUniformVec2("show_effect", 1, "shift_r", shift_c[frameCount], shift_c[frameCount])
                ge_0:setUniformVec2("show_effect", 1, "shift_b", -shift_c[frameCount], -shift_c[frameCount])
            end

            if (frameCount == #alpha) then
                count = count + 1
                if (count == 4) then
                    count = 0
                    -- print("cino delta: "..getDiffTime(gTimeBegin, gTimeCurrent))
                    local effectManager = this:getEffectManager()
                    if effectManager then
                        gTimeBegin = effectManager:getTimeStamp()
                    end
                end
            end
        end
        return true
    end,
    handleRecodeVedioEvent = function(this, eventCode)
        if (eventCode == 1) then
            init(this)
        end
        return true
    end
}
