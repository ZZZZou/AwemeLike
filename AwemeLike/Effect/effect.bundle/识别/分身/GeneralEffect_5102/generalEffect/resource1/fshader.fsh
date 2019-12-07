precision highp float;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTextureMask4;

varying vec2 textureCoordinate;

bool validCoordinate(vec2 coord) {
  if(coord.x >= 0.0 && coord.x <= 1.0 && coord.y >=0.0 && coord.y <= 1.0) {
    return true;
  }
  return false;
}

vec2 scaleTexture() {
  return  (textureCoordinate - vec2(0.5))*1.05 + vec2(0.5);
}

void main()
{
  float d = 0.08;
  vec2 _coord = scaleTexture();
  vec2 v1 = _coord + vec2(-0.25, 0.25) + vec2(-d, 0.0);
  vec2 v2 = _coord + vec2(0.25, 0.25) + vec2(0.0, d);
  vec2 v3 = _coord + vec2(0.25, -0.25) + vec2(d, 0.0);
  vec2 v4 = _coord + vec2(-0.25, -0.25) + vec2(0.0, -d);
  v2 = _coord + vec2(0.25, 0.25);
  v3 = _coord + vec2(0.35, -0.15);
  v4 = _coord + vec2(-0.30, -0.20);

  const float _w = 0.9;
  float w1=0.0, w2=0.0, w3=0.0, w4=0.5;
  vec4 color0 = texture2D(inputImageTexture, textureCoordinate);
  vec4 colorS = vec4(0.0);
  float w = 0.0;
  //w1 *= texture2D(inputImageTextureMask1, v1).r; w1 = clamp(w1, 0.0, 1.0);
  //w2 *= texture2D(inputImageTextureMask2, v2).r; w2 = clamp(w2, 0.0, 1.0);
  //w3 *= texture2D(inputImageTextureMask3, v3).r; w3 = clamp(w3, 0.0, 1.0);
  w4 *= texture2D(inputImageTextureMask4, v4).r; w4 = clamp(w4, 0.0, 1.0);
  w = w1+w2+w3+w4;
  
  //colorS += texture2D(inputImageTexture, v1) * w1;
  
  //colorS += texture2D(inputImageTexture, v2) * w2;

  //colorS += texture2D(inputImageTexture, v3) * w3;

  colorS += texture2D(inputImageTexture, v4) * w4;
  
  color0 = colorS;
 
  gl_FragColor = color0;
}
