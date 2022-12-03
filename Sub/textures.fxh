#define merge_strings(a,b) a##b 

texture diffuseTexture : MATERIALTEXTURE <>;
sampler diffuseSampler = sampler_state 
{
	texture = < diffuseTexture >;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	MIPFILTER = ANISOTROPIC;
	ADDRESSU = WRAP;
	ADDRESSV = WRAP;
};

texture LightTexture : MATERIALSPHEREMAP<>;
sampler LightSampler = sampler_state 
{
	texture = < LightTexture >;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	MIPFILTER = ANISOTROPIC;
	ADDRESSU = WRAP;
	ADDRESSV = WRAP;
};

texture ShadowTexture : MATERIALTOONTEXTURE<>;
sampler ShadowSampler = sampler_state 
{
	texture = < ShadowTexture >;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	MIPFILTER = ANISOTROPIC;
	ADDRESSU = WRAP;
	ADDRESSV = WRAP;
};

texture ToonTexture : TEXTURE < string ResourceName = merge_strings("Default/", Toon_Tex); >;
sampler ToonSampler = sampler_state 
{
	texture = < ToonTexture >;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	MIPFILTER = ANISOTROPIC;
	ADDRESSU = CLAMP;
	ADDRESSV = CLAMP;
};

texture RimTexture : TEXTURE < string ResourceName = merge_strings("Default/", Rim_Tex); >;
sampler RimSampler = sampler_state 
{
	texture = < RimTexture >;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	MIPFILTER = ANISOTROPIC;
	ADDRESSU = CLAMP;
	ADDRESSV = CLAMP;
};
#ifdef RimMask_Tex
texture RimMaskTexture : TEXTURE < string ResourceName = merge_strings("Mask/", RimMask_Tex); >;
sampler RimMaskSampler = sampler_state 
{
	texture = < RimMaskTexture >;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	MIPFILTER = ANISOTROPIC;
	ADDRESSU = CLAMP;
	ADDRESSV = CLAMP;
};
#endif

#ifdef EdgeMask_Tex
texture EdgeMaskTexture : TEXTURE < string ResourceName = merge_strings("Mask/", EdgeMask_Tex); >;
sampler EdgeMaskSampler = sampler_state 
{
	texture = < EdgeMaskTexture >;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	MIPFILTER = ANISOTROPIC;
	ADDRESSU = WRAP;
	ADDRESSV = WRAP;
};
#endif