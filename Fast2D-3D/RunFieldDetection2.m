addpath([cd '\gaussmix-v1.1\']);

rootin = [cd '\Test\'];
rootinData = [cd '\'];
st = 1; 
endi = 20;
STP = 10; %define a frame processing step for processing speed
R = 0.25;
bandWidth = 25;
thr_size = 0.8; %mainly require great dominance, which is often field. The bigger the safer (with reason)
thr_imodel = -150; %%the smaller the threshold, the safer we are (with reason) i.e. less chnace of classifying a non-field as field
DetectMainPitch(rootin,rootinData,st,endi,STP,R,bandWidth,thr_size,thr_imodel)