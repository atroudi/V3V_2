
Runfiles = dir('/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/*');   Runfiles= char(Runfiles.name);

for repeat=4:size(Runfiles,1)
  
  i=1;
  fid=fopen(['/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/', deblank(Runfiles(repeat,:)),'/',num2str(i),'.txt']);
  
  while fid ~= -1
      
          A = fscanf(fid,'%f\n');
          
          fid1=fopen(['/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/', deblank(Runfiles(repeat,:)),'/',num2str(i),'_int.txt'],'w');
          fprintf(fid1,'%u\n',single(round(A*255)));
          
          fclose('all');
          
          i=i+1;
          fid=fopen(['/Users/kiana/Desktop/2D_3D/Fast2D-3D/Database/', deblank(Runfiles(repeat,:)),'/',num2str(i),'.txt']);   
  end
end
  