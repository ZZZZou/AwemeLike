// microfacet模型

// attribute
attribute vec3 attPosition;
attribute vec3 attNormal;
attribute vec3 attTangent;
attribute vec2 attUV;
attribute vec4 attBoneIds;
attribute vec4 attWeights;

// uniform
const int MAX_BONES = 50;
uniform mat4 bonesMat[MAX_BONES];
uniform mat4 mvpMat;
uniform mat4 modelMat;
uniform mat3 normalMat;

// varying
varying vec3 N;
varying vec3 T;
varying vec2 textureCoords;
varying vec3 fragNormal;
varying vec3 fragPos;


// main
void main()
{
#ifdef USE_BONE_ANIMATION
        mat4 boneTransform = bonesMat[int(attBoneIds.x)] * attWeights.x;
        boneTransform += bonesMat[int(attBoneIds.y)] * attWeights.y;
        boneTransform += bonesMat[int(attBoneIds.z)] * attWeights.z;
        boneTransform += bonesMat[int(attBoneIds.w)] * attWeights.w;
        
        gl_Position = mvpMat * boneTransform * vec4(attPosition, 1.0);
        
        fragPos = (modelMat * boneTransform * vec4(attPosition, 1.0)).xyz;	// 在世界坐标系中指定
        mat4 boneNormalMatrix = modelMat * boneTransform;
        fragNormal = (boneNormalMatrix * vec4(attNormal, 0.0)).xyz;	// 计算法向量经过模型变换后值
        
#else
        gl_Position = mvpMat * vec4(attPosition, 1.0);
        fragPos = (modelMat * vec4(attPosition, 1.0)).xyz;	// 在世界坐标系中指定
        fragNormal = normalMat * attNormal;	// 计算法向量经过模型变换后值
#endif
    textureCoords   = attUV;
    
    textureCoords.y = 1.0 - textureCoords.y;
    T = (modelMat * vec4(attTangent, 0.0)).xyz;
    N = fragNormal;
}
