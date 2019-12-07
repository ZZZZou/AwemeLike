
//LineColor vec3 {
//    0,
//    0,
//    1
//}
//Blue bool {
//    0
//}
//Mirror bool {
//    0
//}
//Rainbow bool {
//    0
//}
//Texture sampler2D {
//    0
//}

varying lowp vec2 DestinationTexCoord;
varying mediump vec3 EyeNormal;
uniform sampler2D inputImageTexture;
uniform int Mirror;
uniform int Blue;
uniform mediump vec3 LineColor;
uniform int Rainbow;
mediump vec4 getRainbowColor() {
    mediump vec2 colorPosition = EyeNormal.xy * 1.2 + 0.5;
    mediump vec3 yellowCyan = mix(vec3(0.5, 0.5, 0.0), vec3(0.0, 0.0, 1.0), colorPosition.x);
    mediump vec3 redGreen = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), colorPosition.y);
    return vec4((yellowCyan + redGreen), 1.0);
}
mediump vec4 getMirrorColor() {
    mediump vec2 coord = EyeNormal.xy * vec2(0.5, -0.5) + vec2(0.5, 0.5);
    coord = mod(coord, 1.0);
    return texture2D(inputImageTexture, coord);
}
mediump vec4 getBlueColor() {
    return vec4(LineColor, 1.0);
}
void main(void) {
	lowp vec4 pixelColor = texture2D(inputImageTexture, DestinationTexCoord);
    lowp float r = pow(pixelColor.r, 0.6);
    lowp float g = pow(pixelColor.g, 0.6);
    lowp float b = pow(pixelColor.b, 0.6);
    pixelColor = vec4(r,g,b,pixelColor.a);

    gl_FragColor = pixelColor;
    if (Blue > 0 && Rainbow > 0) {
        gl_FragColor = mix(getBlueColor(), getRainbowColor(), 0.35);
    } else if (Mirror > 0 && Rainbow > 0) {
        gl_FragColor = mix(getMirrorColor(), getRainbowColor(), 0.4);
    } else if (Blue > 0) {
        gl_FragColor = getBlueColor();
    } else if (Mirror > 0) {
        gl_FragColor = getMirrorColor();
    } else if (Rainbow > 0) {
        gl_FragColor = getRainbowColor();
    } else {
        gl_FragColor = pixelColor;
    }
}
