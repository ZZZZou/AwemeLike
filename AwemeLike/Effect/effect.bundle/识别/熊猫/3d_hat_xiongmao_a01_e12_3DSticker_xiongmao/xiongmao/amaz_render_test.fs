#extension GL_OES_standard_derivatives : enable // android compile error oes texture
//
precision mediump float;

// material
uniform vec3 ambient;           //Emission Color
uniform vec3 diffuse;           //if no diffuseMap, using diffuseColor
uniform vec3 specular;          //if no specularMap ,using specular .

uniform float glossy;        //if use cook torrance .it represent roughness

uniform float ka;
uniform float ke;
uniform float ks;
uniform float kd;
uniform float kr;
uniform float alpha;

// sampler
#ifdef USE_DIFFUSE_MAP
uniform sampler2D diffuseMap;
#endif

#ifdef USE_NORMAL_MAP
uniform sampler2D normalMap;
#endif

#ifdef USE_EMISSION_MAP
uniform sampler2D emissionMap;
#endif

#ifdef USE_SPECULAR_MAP
uniform sampler2D specularMap;
#endif

#ifdef USE_GLOSSINESS_MAP
uniform sampler2D glossinessMap;
#endif

#ifdef USE_OPACITY_MAP
uniform sampler2D opacityMap;
#endif

#ifdef USE_REFLECTION_MAP
uniform sampler2D reflectionMap;
#endif

#ifdef USE_Environment_MAP
uniform sampler2D environmentMap;
#endif

// varying
varying vec3      N;
varying vec3      T;
varying vec2      textureCoords;
varying vec3      fragPos;
varying vec3      fragNormal;
//in vec3      N;
//in vec3      T;
//in vec2      textureCoords;
//in vec3      fragPos;
//in vec3      fragNormal;


// uniform
uniform vec3 viewPos;

uniform float uOffset; // uv animation
uniform float vOffset;
uniform float uvColumnNum;
uniform float uvRowNum;

uniform float envRotationX;
uniform float envRotationY;

const int MAX_POINT_LIGHT = 2;
const int MAX_SPOT_LIGHT = 2;
const int MAX_DIR_LIGHT = 2;

//dir light
uniform vec3 _AE_DIRECTIONAL_LIGHTS_DIRECTION_[MAX_DIR_LIGHT];
uniform vec3 _AE_DIRECTIONAL_LIGHTS_COLOR_[MAX_DIR_LIGHT];
uniform float _AE_DIRECTIONAL_LIGHTS_INTENSITY_[MAX_DIR_LIGHT];

//point light
uniform vec3 _AE_POINT_LIGHTS_POSITION_[MAX_POINT_LIGHT];
uniform float _AE_POINT_LIGHTS_ATTENUATION_RANGE_INV_[MAX_POINT_LIGHT];
uniform vec3 _AE_POINT_LIGHTS_COLOR_[MAX_POINT_LIGHT];
uniform float _AE_POINT_LIGHTS_INTENSITY_[MAX_POINT_LIGHT];

//spot light
uniform vec3 _AE_SPOT_LIGHTS_POSITION_[MAX_SPOT_LIGHT];
uniform float _AE_SPOT_LIGHTS_ATTENUATION_RANGE_INV_[MAX_SPOT_LIGHT];
uniform vec3 _AE_SPOT_LIGHTS_COLOR_[MAX_SPOT_LIGHT];
uniform float _AE_SPOT_LIGHTS_INTENSITY_[MAX_SPOT_LIGHT];
uniform float _AE_SPOT_LIGHTS_INNER_ANGLE_COS_[MAX_SPOT_LIGHT];
uniform float _AE_SPOT_LIGHTS_OUTER_ANGLE_COS_[MAX_SPOT_LIGHT];
uniform vec3 _AE_SPOT_LIGHTS_DIRECTION_[MAX_SPOT_LIGHT];

// ambient light
uniform vec3 ambientLight;

// function

highp vec3 calNormalizeValue(highp vec3 value)
{
    highp float sqrt_sum = length(value);
    highp vec3 res;
    res.x = (value.x)/sqrt_sum;
    res.y = (value.y)/sqrt_sum;
    res.z = (value.z)/sqrt_sum;
    
    return res;
}

vec2 getUVFromEvMap(vec3 direction)
{
    direction = normalize(direction);
    float x = direction.x;
    float y = direction.y;
    float z = direction.z;
    
    float p = acos(direction.y);
    float h = atan(direction.x, direction.z);
    
    float pi = 3.1415926535898;
    float inversePi = 0.31830988618379;

    h = 1.0 * pi + h;
    
    float v = p * inversePi;
    float u = h * inversePi * 0.5;
    
    return vec2(u, v);
}

vec3 rotateEvMap(vec3 v, float h, float p)
{
    float ca = cos(h);
    float sa = sin(h);
    v = vec3(v.x*ca+v.z*sa, v.y, v.z*ca-v.x*sa);
    
    ca = cos(p);
    sa = sin(p);
    
    v = vec3(v.x, ca*v.y+sa*v.z, ca*v.z-sa*v.y);
    return v;
}

vec3 calNormalMap(vec3 texNormal,vec3 N,vec3 T)
{
    vec3 normal = normalize(N);
    vec3 tangent = normalize(T);
    
    tangent = normalize(tangent - dot(tangent, normal) * normal);
    //vec3 bitangent = normalize(cross(tangent, normal));
    vec3 bitangent = normalize(cross(normal,tangent));
    texNormal = 2.0 * texNormal - vec3(1.0, 1.0, 1.0);
    
    vec3 newNormal;
    mat3 TBN = mat3(tangent, bitangent, normal);
    newNormal = TBN * texNormal;
    newNormal = normalize(newNormal);
    return newNormal;
}


void blinPhongShading(vec3 Ln,
                      vec3 Vn,
                      vec3 Nn,
                      float glossiness,
                      out vec3 DiffuseContrib,
                      out vec3 SpecularContrib)
{
    float inversePi = 0.31830988618379;
    vec3 Hn = normalize(Ln+Vn);
    float ldn = dot(Nn, Ln);
    ldn = max(ldn, 0.0);
    float ndh = max(dot(Nn, Hn), 0.0);
    
    float specPow = exp2(glossiness*11.0 + 2.0);
    DiffuseContrib = vec3(ldn);
    float specNorm = (specPow + 8.0) / 8.0;
    SpecularContrib = vec3(specNorm * pow(ndh, specPow) * ldn);
    
    //DiffuseContrib *= inversePi;
    //pecularContrib *= inversePi;
}

void calPointLight(vec3 lightPos,
                   vec3 eyePos,
                   vec3 fragPos,
                   vec3 Nn,
                   float glossiness,
                   float radius,
                   out vec3   DiffuseContrib,
                   out vec3   SpecularContrib)
{
    vec3 Ln = calNormalizeValue(lightPos - fragPos);
    vec3 Vn = normalize(eyePos - fragPos);
    float distance = length(lightPos - fragPos);
    float inverseRadius = 1.0 / radius;
    //float attenuation  = 1 - max(1.0 - pow(pow(distance * inverseRadius, 4.0),2.0), 0.0) / (pow(distance, 2.0) + 1.0);
    float attenuation = 1.0;
    
    blinPhongShading(Ln, Vn, Nn, glossiness, DiffuseContrib, SpecularContrib);
    DiffuseContrib *= attenuation;
    SpecularContrib *= attenuation;
}

void calSpotLight( vec3 lightPos,
                  vec3 eyePos,
                  vec3 fragPos,
                  vec3 direction,
                  vec3 Nn,
                  float glossiness,
                  float innerAngle,
                  float outAngle,
                  float radius,
                  out vec3   DiffuseContrib,
                  out vec3   SpecularContrib)
{
    vec3 Ln = normalize(lightPos - fragPos);
    vec3 Vn = normalize(eyePos - fragPos);
    float distance = length(lightPos - fragPos);
    float inverseRadius = 1.0 / radius;
    //    float attenuation  = max(1.0 - pow(pow(distance * inverseRadius, 4.0),2.0), 0.0) / (pow(distance, 2.0) + 1.0);
    float attenuation = 1.0;
    
    blinPhongShading(Ln, Vn, Nn, glossiness, DiffuseContrib, SpecularContrib);
    
    float theta = dot(-Ln, normalize(direction));
    float epsilon = innerAngle - outAngle;
    float intensity = clamp((theta - outAngle) / epsilon, 0.0, 1.0);
    
    DiffuseContrib = DiffuseContrib * attenuation * intensity;
    SpecularContrib = SpecularContrib * attenuation * intensity;
}

void calDirLight(vec3 Ln,
                 vec3 eyePos,
                 vec3 fragPos,
                 vec3  Nn,
                 float glossiness,
                 out vec3   DiffuseContrib,
                 out vec3   SpecularContrib)
{
    vec3 Vn = normalize(eyePos - fragPos);
    blinPhongShading(Ln, Vn, Nn, glossiness, DiffuseContrib, SpecularContrib);
}


// main
void main()
{
    float uOffsetStep = 1.0 / uvColumnNum;
    float vOffsetStep = 1.0 / uvRowNum;
    
    vec2 processedTextureCoords = textureCoords;
    processedTextureCoords = vec2(textureCoords.x / uvColumnNum + uOffsetStep * uOffset,
                                  textureCoords.y / uvRowNum + vOffsetStep * vOffset);
    vec3 veckr = vec3(kr);
    
    vec3 Vn = normalize(viewPos - fragPos);
    vec3 Nn = normalize(fragNormal);
    
    float alpha = alpha;
    vec3 difColor = diffuse;
#ifdef USE_DIFFUSE_MAP
    vec4 diffuseColor = texture2D(diffuseMap, processedTextureCoords);
    difColor *= diffuseColor.rgb;
    alpha *= diffuseColor.a;
#endif
    
#ifdef USE_NORMAL_MAP
    vec3 normal = texture2D(normalMap, textureCoords).xyz;
    Nn = calNormalMap(normal,N,T);
#endif
    
    vec3 emissive = ambient * ke;
#ifdef USE_EMISSION_MAP
    emissive *= texture2D(emissionMap,textureCoords).xyz;
#endif
    
    vec3 specColor = specular;
#ifdef USE_SPECULAR_MAP
    specColor *= texture2D(specularMap,textureCoords).rgb;
#endif
    
    float shineValue = glossy * 0.5;
#ifdef USE_GLOSSINESS_MAP
    shineValue = texture2D(glossinessMap,textureCoords).r * 0.5;
#endif
    
#ifdef USE_OPACITY_MAP
    alpha *= texture2D(opacityMap,textureCoords).r;
#endif
    
#ifdef USE_REFLECTION_MAP
    veckr = texture2D(reflectionMap,textureCoords).rgb * veckr;
#endif
    
    vec3 reflColor = vec3(0.0);
#ifdef USE_Environment_MAP
    vec3 R = reflect(-Vn,Nn);
    R = rotateEvMap(R, envRotationX, envRotationY);
    vec2 uv = getUVFromEvMap(R);
//    uv.y = 1.0 - uv.y;
    reflColor = texture2D(environmentMap,uv).rgb * veckr;
#endif
    
    vec3 diffContrib = vec3(0.0, 0.0, 0.0);
    vec3 specContrib = vec3(0.0, 0.0, 0.0);
    
    vec3 tmpDiffContrib = vec3(0.0);
    vec3 tmpSpecContrib = vec3(0.0);
    
#ifdef USE_POINT_LIGHT_0
    tmpDiffContrib = vec3(0.0);
    tmpSpecContrib = vec3(0.0);
    calPointLight(_AE_POINT_LIGHTS_POSITION_[0],
                  viewPos,
                  fragPos,
                  Nn,
                  shineValue,
                  _AE_POINT_LIGHTS_ATTENUATION_RANGE_INV_[0],
                  tmpDiffContrib,
                  tmpSpecContrib);
    
    diffContrib += _AE_POINT_LIGHTS_COLOR_[0] * tmpDiffContrib * _AE_POINT_LIGHTS_INTENSITY_[0] * kd;
    specContrib += _AE_POINT_LIGHTS_COLOR_[0] * tmpSpecContrib * _AE_POINT_LIGHTS_INTENSITY_[0] * ks;
#endif
    
    
#ifdef USE_POINT_LIGHT_1
    tmpDiffContrib = vec3(0.0);
    tmpSpecContrib = vec3(0.0);
    calPointLight(_AE_POINT_LIGHTS_POSITION_[1],
                  viewPos,
                  fragPos,
                  Nn,
                  shineValue,
                  _AE_POINT_LIGHTS_ATTENUATION_RANGE_INV_[1],
                  tmpDiffContrib,
                  tmpSpecContrib);
    
    diffContrib += _AE_POINT_LIGHTS_COLOR_[1] * tmpDiffContrib * _AE_POINT_LIGHTS_INTENSITY_[1] * kd;
    specContrib += _AE_POINT_LIGHTS_COLOR_[1] * tmpSpecContrib * _AE_POINT_LIGHTS_INTENSITY_[1] * ks;
#endif
    
#ifdef USE_SPOT_LIGHT_0
    tmpDiffContrib = vec3(0.0);
    tmpSpecContrib = vec3(0.0);
    calSpotLight(_AE_SPOT_LIGHTS_POSITION_[0],
                 viewPos,
                 fragPos,
                 -_AE_SPOT_LIGHTS_DIRECTION_[0],
                 Nn,
                 shineValue,
                 _AE_SPOT_LIGHTS_INNER_ANGLE_COS_[0],
                 _AE_SPOT_LIGHTS_OUTER_ANGLE_COS_[0],
                 _AE_SPOT_LIGHTS_ATTENUATION_RANGE_INV_[0],
                 tmpDiffContrib,
                 tmpSpecContrib);
    
    diffContrib += _AE_SPOT_LIGHTS_COLOR_[0] * tmpDiffContrib * _AE_SPOT_LIGHTS_INTENSITY_[0] * kd;
    specContrib += _AE_SPOT_LIGHTS_COLOR_[0] * tmpSpecContrib * _AE_SPOT_LIGHTS_INTENSITY_[0] * ks;
#endif
    
#ifdef USE_SPOT_LIGHT_1
    tmpDiffContrib = vec3(0.0);
    tmpSpecContrib = vec3(0.0);
    calSpotLight(_AE_SPOT_LIGHTS_POSITION_[1],
                 viewPos,
                 fragPos,
                 -_AE_SPOT_LIGHTS_DIRECTION_[1],
                 Nn,
                 shineValue,
                 _AE_SPOT_LIGHTS_INNER_ANGLE_COS_[1],
                 _AE_SPOT_LIGHTS_OUTER_ANGLE_COS_[1],
                 _AE_SPOT_LIGHTS_ATTENUATION_RANGE_INV_[1],
                 tmpDiffContrib,
                 tmpSpecContrib);
    
    diffContrib += _AE_SPOT_LIGHTS_COLOR_[1] * tmpDiffContrib * _AE_SPOT_LIGHTS_INTENSITY_[1] * kd;
    specContrib += _AE_SPOT_LIGHTS_COLOR_[1] * tmpSpecContrib * _AE_SPOT_LIGHTS_INTENSITY_[1] * ks;
#endif
    
#ifdef USE_DIR_LIGHT_0
    tmpDiffContrib = vec3(0.0);
    tmpSpecContrib = vec3(0.0);
    calDirLight(-_AE_DIRECTIONAL_LIGHTS_DIRECTION_[0],
                viewPos,
                fragPos,
                Nn,
                shineValue,
                tmpDiffContrib,
                tmpSpecContrib);
    diffContrib += _AE_DIRECTIONAL_LIGHTS_COLOR_[0]*tmpDiffContrib * _AE_DIRECTIONAL_LIGHTS_INTENSITY_[0] * kd;
    specContrib += _AE_DIRECTIONAL_LIGHTS_COLOR_[0]*tmpSpecContrib * _AE_DIRECTIONAL_LIGHTS_INTENSITY_[0] * ks;
#endif
    
#ifdef USE_DIR_LIGHT_1
    tmpDiffContrib = vec3(0.0);
    tmpSpecContrib = vec3(0.0);
    calDirLight(-_AE_DIRECTIONAL_LIGHTS_DIRECTION_[1],
                viewPos,
                fragPos,
                Nn,
                shineValue,
                tmpDiffContrib,
                tmpSpecContrib);
    diffContrib += _AE_DIRECTIONAL_LIGHTS_COLOR_[1]*tmpDiffContrib * _AE_DIRECTIONAL_LIGHTS_INTENSITY_[0] * kd;
    specContrib += _AE_DIRECTIONAL_LIGHTS_COLOR_[1]*tmpSpecContrib * _AE_DIRECTIONAL_LIGHTS_INTENSITY_[0] * ks;
#endif
    
    vec3 ambContrib = vec3(0.0);
#ifdef USE_AMBIENT_LIGHT
    ambContrib = ambientLight * ka;
#endif
    
    vec3 specularFactor = specColor * specContrib;
    vec3 reflectFactor  = specColor * reflColor;
    vec3 diffuseFactor  = difColor * diffContrib;
    vec3 ambientFactor  = difColor * ambContrib;
    
    //FragColor = vec4(specContrib, 1.0);
    //FragColor = vec4(diffContrib + specContrib, 1.0);
    //    FragColor = vec4(specularFactor + reflectFactor + diffuseFactor + ambientFactor, alpha);
    gl_FragColor = vec4(specularFactor + reflectFactor + diffuseFactor + ambientFactor, alpha);
}
