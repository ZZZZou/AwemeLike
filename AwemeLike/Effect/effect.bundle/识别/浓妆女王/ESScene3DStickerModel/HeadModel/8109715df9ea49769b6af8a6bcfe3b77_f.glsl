
    precision highp float;
    precision highp sampler2D;
uniform vec3 _AE_DIRECTIONAL_LIGHTS_DIRECTION_[1];
uniform vec3 _AE_DIRECTIONAL_LIGHTS_COLOR_[1];
uniform float _AE_DIRECTIONAL_LIGHTS_INTENSITY_[1];
uniform highp mat4 _AE_DIRECTIONAL_LIGHT0_SHADOW_MATRIX_;
uniform highp float _AE_DIRECTIONAL_LIGHT0_SHADOW_ENABLED_;
uniform highp float _AE_DIRECTIONAL_LIGHT0_SHADOW_BIAS_;
uniform highp float _AE_DIRECTIONAL_LIGHT0_SHADOW_STRENGTH_;
uniform highp float _AE_DIRECTIONAL_LIGHT0_SHADOW_SOFT_;
uniform highp float _AE_DIRECTIONAL_LIGHT0_SHADOW_SOFTNESS_;
uniform sampler2D _AE_DIRECTIONAL_LIGHT0_SHADOW_TEXTURE_;
uniform highp vec2 _AE_DIRECTIONAL_LIGHT0_SHADOW_TEXTURE_SIZE_;
uniform highp vec3 u_Albedo;
uniform highp float u_Alpha;
varying highp vec3 g_vary_WorldPosition;
varying highp vec3 g_vary_WorldNormal;
void main ()
{
  vec3 final_color_1;
  vec3 tmpvar_2[1];
  vec3 tmpvar_3[1];
  float tmpvar_4[1];
  highp vec3 tmpvar_5;
  tmpvar_5 = normalize(g_vary_WorldNormal);
  float tmpvar_6;
  tmpvar_6 = u_Alpha;
  vec3 tmpvar_7[1];
  vec3 tmpvar_8[1];
  float tmpvar_9[1];
  tmpvar_7[0]=tmpvar_2[0];
  tmpvar_8[0]=tmpvar_3[0];
  tmpvar_9[0]=tmpvar_4[0];
  tmpvar_7[0] = normalize(-(_AE_DIRECTIONAL_LIGHTS_DIRECTION_[0]));
  tmpvar_8[0] = _AE_DIRECTIONAL_LIGHTS_COLOR_[0];
  tmpvar_9[0] = _AE_DIRECTIONAL_LIGHTS_INTENSITY_[0];
  highp vec3 l_10;
  l_10 = tmpvar_7[0];
  float tmpvar_11;
  float shadow_factor_12;
  highp float bias_13;
  highp vec3 shadow_coord_14;
  if ((_AE_DIRECTIONAL_LIGHT0_SHADOW_ENABLED_ < 1.0)) {
    tmpvar_11 = 1.0;
  } else {
    highp float tmpvar_15;
    tmpvar_15 = max (dot (tmpvar_5, l_10), 0.0);
    highp vec4 tmpvar_16;
    tmpvar_16.w = 1.0;
    tmpvar_16.xyz = g_vary_WorldPosition;
    highp vec4 tmpvar_17;
    tmpvar_17 = (_AE_DIRECTIONAL_LIGHT0_SHADOW_MATRIX_ * tmpvar_16);
    highp vec3 tmpvar_18;
    tmpvar_18 = (tmpvar_17.xyz / tmpvar_17.w);
    shadow_coord_14 = tmpvar_18;
    if ((((
      (((tmpvar_18.x < 0.0) || (1.0 < tmpvar_18.x)) || (tmpvar_18.y < 0.0))
     || 
      (1.0 < tmpvar_18.y)
    ) || (tmpvar_18.z < 0.0)) || (1.0 < tmpvar_18.z))) {
      tmpvar_11 = 1.0;
    } else {
      highp float tmpvar_19;
      tmpvar_19 = (1.570796 - (sign(tmpvar_15) * (1.570796 - 
        (sqrt((1.0 - abs(tmpvar_15))) * (1.570796 + (abs(tmpvar_15) * (-0.2146018 + 
          (abs(tmpvar_15) * (0.08656672 + (abs(tmpvar_15) * -0.03102955)))
        ))))
      )));
      highp float tmpvar_20;
      tmpvar_20 = clamp ((_AE_DIRECTIONAL_LIGHT0_SHADOW_BIAS_ * (
        sin(tmpvar_19)
       / 
        cos(tmpvar_19)
      )), 0.0, 1.0);
      bias_13 = tmpvar_20;
      shadow_factor_12 = 0.0;
      if ((0.0 < _AE_DIRECTIONAL_LIGHT0_SHADOW_SOFT_)) {
        highp vec2 inv_tex_size_22;
        float shadow_sum_23;
        vec2 sample_offsets_24[9];
        sample_offsets_24[0] = vec2(-1.0, -1.0);
        sample_offsets_24[1] = vec2(0.0, -1.0);
        sample_offsets_24[2] = vec2(1.0, -1.0);
        sample_offsets_24[3] = vec2(-1.0, 0.0);
        sample_offsets_24[4] = vec2(0.0, 0.0);
        sample_offsets_24[5] = vec2(1.0, 0.0);
        sample_offsets_24[6] = vec2(-1.0, 1.0);
        sample_offsets_24[7] = vec2(0.0, 1.0);
        sample_offsets_24[8] = vec2(1.0, 1.0);
        shadow_sum_23 = 0.0;
        inv_tex_size_22 = (1.0/(_AE_DIRECTIONAL_LIGHT0_SHADOW_TEXTURE_SIZE_));
        for (highp int i_21 = 0; i_21 < 9; i_21++) {
          shadow_sum_23 = (shadow_sum_23 + float((shadow_coord_14.z < 
            (dot (texture2D (_AE_DIRECTIONAL_LIGHT0_SHADOW_TEXTURE_, (shadow_coord_14.xy + (
              (sample_offsets_24[i_21] * _AE_DIRECTIONAL_LIGHT0_SHADOW_SOFTNESS_)
             * inv_tex_size_22))), vec4(5.960464e-08, 1.525879e-05, 0.00390625, 1.0)) + bias_13)
          )));
        };
        shadow_factor_12 = (shadow_sum_23 / 9.0);
      } else {
        shadow_factor_12 = float((tmpvar_18.z < (
          dot (texture2D (_AE_DIRECTIONAL_LIGHT0_SHADOW_TEXTURE_, tmpvar_18.xy), vec4(5.960464e-08, 1.525879e-05, 0.00390625, 1.0))
         + tmpvar_20)));
      };
      if ((shadow_factor_12 < 1.0)) {
        shadow_factor_12 = mix (1.0, shadow_factor_12, _AE_DIRECTIONAL_LIGHT0_SHADOW_STRENGTH_);
      };
      tmpvar_11 = shadow_factor_12;
    };
  };
  tmpvar_2[0]=tmpvar_7[0];
  tmpvar_3[0]=tmpvar_8[0];
  tmpvar_4[0]=tmpvar_9[0];
  final_color_1 = (((
    ((clamp ((
      (dot (tmpvar_5, tmpvar_7[0]) * 0.5)
     + 0.5), 0.0, 1.0) * (u_Albedo - (u_Albedo * vec3(0.5, 0.5, 0.5)))) * tmpvar_9[0])
   * tmpvar_8[0]) * vec3(tmpvar_11)) + vec3(0.05, 0.05, 0.05));
  vec4 tmpvar_25;
  tmpvar_25.xyz = final_color_1;
  tmpvar_25.w = tmpvar_6;
  vec4 color_26;
  color_26.w = tmpvar_25.w;
  color_26.xyz = pow (final_color_1, vec3(0.4545454, 0.4545454, 0.4545454));
  color_26.xyz = clamp (color_26.xyz, vec3(0.0, 0.0, 0.0), vec3(1.0, 1.0, 1.0));
  gl_FragColor = color_26;
}

