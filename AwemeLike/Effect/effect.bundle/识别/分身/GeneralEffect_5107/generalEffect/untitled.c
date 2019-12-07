{
    "effect": [
               {
               "name": "16",
               "viewport": [0, 0, 320, 480],
               "vertexShader": "resource1/16.vsh",
               "vUniforms": [
                ],
               "fragmentShader": "resource1/16.fsh",
               "fUniforms": [
                             {
                             "name": "inputImageTexture",
                             "type": 100
                             }
                             ]
               },
               {
               "name": "19",
               "viewport": [0, 0, 320, 480],
               "inputEffect": ["16"],
               "vertexShader": "resource1/19.vsh",
               "vUniforms": [
               ],
               "fragmentShader": "resource1/19.fsh",
               "fUniforms": [
                             {
                             "name": "inputImageTexture",
                             "type": 1000,
                             "inputEffectIndex": 0
                             }
                             ]
               },
               {
               "name": "22",
               "viewport": [0, 0, 320, 480],
               "inputEffect": ["19"],
               "vertexShader": "resource1/22.vsh",
               "vUniforms": [
               ],
               "fragmentShader": "resource1/22.fsh",
               "fUniforms": [
                             {
                             "name": "inputImageTexture",
                             "type": 1000,
                             "inputEffectIndex": 0
                             }
                             ]
               }
               ],
    "version": 1.1
}
