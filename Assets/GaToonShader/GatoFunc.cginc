// hsv‚ðrgb‚É•ÏŠ·‚·‚é
// https://techblog.kayac.com/unity_advent_calendar_2018_15
float3 hsv2rgb(float3 hsv) 
{
	float h = hsv.x;
	float s = hsv.y;
	float v = hsv.z;

	float4 color = 1;

	h *= 6.0;
	float j = floor(h);
	float f = h - j;
	float aa = v * (1-s);
	float bb = v * (1-(s*f));
	float cc = v * (1-(s*(1-f)));
	if (j < 1) 
	{
		color.r = v;
		color.g = cc;
		color.b = aa;
	} 
	else if (j < 2) 
	{
		color.r = bb;
		color.g = v;
		color.b = aa;
	} 
	else if (j < 3) 
	{
		color.r = aa;
		color.g = v;
		color.b = cc;
	} 
	else if (j < 4) 
	{
		color.r = aa;
		color.g = bb;
		color.b = v;
	} 
	else if (j < 5) 
	{
		color.r = cc;
		color.g = aa;
		color.b = v;
	}
	else
	{
		color.r = v;
		color.g = aa;
		color.b = bb;
	}

	return color;
}

float rand(float2 co){
    return frac(sin(dot(co.xy, float2(12.9898,78.233))) * 43758.5453);
}