precision highp float; 

varying vec2 textureCoordinate; 
uniform sampler2D mattingTexture0; 
uniform sampler2D mattingTexture1; 
uniform sampler2D mattingTexture2; 
uniform sampler2D mattingTexture3; 
uniform sampler2D mattingTexture4; 
uniform sampler2D mattingTexture5; 
uniform sampler2D noiseTexture; 
uniform sampler2D originTexture; 
uniform vec3 u_flameColor0;
uniform vec3 u_flameColor1;
uniform float u_maskContrast;
uniform float u_maskOffset;
uniform float u_zoom; 
uniform float u_init;

void main() {
	vec2 noiseUV = fract(textureCoordinate / u_zoom);
	vec4 noiseColor = texture2D(noiseTexture, noiseUV);
	float originMat = texture2D(mattingTexture0, textureCoordinate).r;
	float matExt0 = texture2D(mattingTexture0, textureCoordinate).a;
	float matExt1 = texture2D(mattingTexture1, textureCoordinate).a;
	float matExt2 = texture2D(mattingTexture2, textureCoordinate).a;
	float matExt3 = texture2D(mattingTexture3, textureCoordinate).a;
	float matExt4 = texture2D(mattingTexture4, textureCoordinate).a;
	float matExt5 = texture2D(mattingTexture5, textureCoordinate).a;
	float ttl0 = matExt0 * 1.;
	float ttl1 = matExt1 * .8;
	float ttl2 = matExt2 * .6;
	float ttl3 = matExt3 * .4;
	float ttl4 = matExt4 * .2;
	float ttl5 = matExt5 * .0;
	float ttl = clamp(max(max(max(max(max(ttl0, ttl1),ttl2), ttl3), ttl4), ttl5) * 2., 0.0, 1.);
	// if(matExt0.a > .0)
	// 	matExt0.r = 1.0;
	// if(matExt1.a > .0)
	// 	matExt1.r = 0.8;
	// if(matExt2.a > .0)
	// 	matExt2.r = 0.6;
	// if(matExt3.a > .0)
	// 	matExt3.r = 0.4;
	// if(matExt4.a > .0)
	// 	matExt4.r = 0.2;
	// if(matExt5.a > .0)
	// 	matExt5.r = 0.0;
	float matExt = max(max(max(max(max(matExt0, matExt1),matExt2), matExt3), matExt4), matExt5);
	
	float maskOffset = matExt < 0.1 ? 0.0 : u_maskOffset;
	float mattingAdjust = clamp(matExt * u_maskContrast + maskOffset, 0.0, 1.0);
	mattingAdjust = clamp( mattingAdjust - texture2D(mattingTexture0,textureCoordinate).r, 0.0, 1.0);
	vec3 originColor = texture2D(originTexture, textureCoordinate).rgb;
	float flameMask = noiseColor.r * mattingAdjust;
	vec3 flameColor = vec3(0.0);
	if(flameMask > 0.8)
		flameColor = vec3(1.0);
	else if(flameMask > 0.65)
		flameColor = mix(originColor, u_flameColor0, 0.7);
	else if(flameMask > 0.4)
		flameColor = mix(originColor, u_flameColor1, 0.5);
	else
		flameColor = mix(originColor, u_flameColor0, mattingAdjust * 0.5) ;
	// vec3 flameColorGrad = mix(u_flameColor1, u_flameColor0, ttl);
	// vec3 flameColor = mix(originColor, flameColorGrad, flameMask);
	// gl_FragColor.rgb = mix(flameColor, originColor, originMat);
	gl_FragColor.rgb = mix(originColor, flameColor, u_init);
	// gl_FragColor.rgb  = flameColor.rgb;
	gl_FragColor.a = 1.0;
}
