precision highp float;

varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
uniform float sensitivity;
const mediump float harrisConstant = 0.10;
uniform vec3 color;


void main() {
    mediump vec3 derivativeElements = texture2D(inputImageTexture, textureCoordinate).rgb;
    mediump float derivativeSum = derivativeElements.x + derivativeElements.y;
    mediump float zElement = (derivativeElements.z * 2.0) - 1.0;
    mediump float cornerness = derivativeElements.x * derivativeElements.y - (zElement * zElement) - harrisConstant * derivativeSum * derivativeSum;
    mediump float value = cornerness * sensitivity;
    if(value > 1.2) {
        // gl_FragColor = vec4(vec3(value), 1.0);
        gl_FragColor = vec4(color, 1.0);
    }
    else {
        gl_FragColor = vec4(vec3(0.0), 1.0);
    }
}
