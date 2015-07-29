clear Query

for n=1:8

Query(:,:,:,n)=imread(['/Users/kiana/Dropbox (QCRI-DS)/2D-3D/Testing/SceneClassifier/left_view images/',num2str(n),'.png']);
%Query = Query(:,1:size(Query,2)/2,:);
%imwrite(Query,['/Users/kiana/Dropbox (QCRI-DS)/2D-3D/Testing/StereoCreator/left_view images/',num2str(n),'.png'],'png');
%stereo= tilt(Query, 30);
%imwrite(stereo,['/Users/kiana/Dropbox (QCRI-DS)/2D-3D/Testing/StereoCreator/stereo output images (max_disp 30)/',num2str(n),'.png'],'png');

end

[CLASS, masks] = GetSceneClassification_WithoutCuts(Query,pwd,1);

CLASS

for n=1:8
  imwrite(masks(:,:,n),['/Users/kiana/Dropbox (QCRI-DS)/2D-3D/Testing/SceneClassifier/Info (resize_factor 1)/',num2str(n),'.png'],'png');  
end