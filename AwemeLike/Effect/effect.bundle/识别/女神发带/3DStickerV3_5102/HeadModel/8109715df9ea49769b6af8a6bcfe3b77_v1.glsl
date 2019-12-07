attribute vec3 attPosition;
attribute vec3 attNormal;
uniform mat4 g_unif_ModelMat;
uniform mat4 g_unif_ModelViewProjMat;
uniform mat3 g_unif_NormalWorldMat;
varying vec3 g_vary_WorldPosition;
varying vec3 g_vary_WorldNormal;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.w = 1.0;
  tmpvar_1.xyz = attPosition;
  g_vary_WorldPosition = (g_unif_ModelMat * tmpvar_1).xyz;
  g_vary_WorldNormal = (g_unif_NormalWorldMat * attNormal);
  gl_Position = (g_unif_ModelViewProjMat * tmpvar_1);
}

