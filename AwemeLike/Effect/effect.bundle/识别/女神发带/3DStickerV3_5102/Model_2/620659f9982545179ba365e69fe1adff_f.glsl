
    precision highp float;
    precision highp sampler2D;
uniform sampler2D u_AlbedoTex;
uniform highp vec3 u_Albedo;
uniform highp float u_Alpha;
uniform highp float u_UVTiling;
varying highp vec2 g_vary_Texcoord;
void main ()
{
  vec3 final_color_1;
  highp vec2 tmpvar_2;
  tmpvar_2.x = g_vary_Texcoord.x;
  tmpvar_2.y = (1.0 - g_vary_Texcoord.y);
  vec4 tmpvar_3;
  tmpvar_3 = texture2D (u_AlbedoTex, (tmpvar_2 * u_UVTiling));
  final_color_1 = pow ((tmpvar_3.xyz * u_Albedo), vec3(2.2, 2.2, 2.2));
  vec4 tmpvar_4;
  tmpvar_4.xyz = final_color_1;
  tmpvar_4.w = (tmpvar_3.w * u_Alpha);
  vec4 tmpvar_5;
  vec4 color_6;
  color_6.w = tmpvar_4.w;
  color_6.xyz = pow (final_color_1, vec3(0.4545454, 0.4545454, 0.4545454));
  color_6.xyz = clamp (color_6.xyz, vec3(0.0, 0.0, 0.0), vec3(1.0, 1.0, 1.0));
  tmpvar_5 = color_6;
  gl_FragColor = tmpvar_5;
}

