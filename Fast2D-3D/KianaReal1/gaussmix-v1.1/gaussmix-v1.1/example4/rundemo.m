clear all;

if exist('GaussianMixture')~=2
   pathtool;
   error('the directory containing the Cluster program must be added to the search path');
end

disp('generating data...');
mkdata;
clear all;
pixels = load('data');
input('press <Enter> to continue...');
disp(' ');

% [mtrs, omtr] = GaussianMixture(pixels, initK, finalK, verbose, ConditionNumber)
% - pixels is a NxM matrix, containing N training vectors, each of M-dimensional
% - start with initK=20 initial clusters
% - finalK=0 means estimate the optimal order
% - verbose=true displays clustering information
% - ConditionNumber=1e5 controls the ratio of mean to minimum diagonal elements
%   of the estimated covariance matrices. 
% - mtrs is an array of structures, each containing the cluster parameters of the
%   mixture of a particular order
% - omtr is a structure containing the cluster parameters of the mixture with
%   the estimated optimal order
disp('perform classification with Gaussian mixture model in original coordinates...');
disp('estimating optimal order and clustering data...');
[mixture,omtr] = GaussianMixture(pixels, 20, 0, true, 1e5);
disp(sprintf('\toptimal order K*: %d', omtr.K));
for i=1:omtr.K
   disp(sprintf('\tCluster %d:', i));
   disp(sprintf('\t\tpi: %f', omtr.cluster(i).pb));
   disp([sprintf('\t\tmean: '), mat2str(omtr.cluster(i).mu',6)]);
   disp([sprintf('\t\tcovar: '), mat2str(omtr.cluster(i).R,6)]);
end
input('press <Enter> to continue...');
disp(' ');

% with omtr containing the optimal clustering with order K*, the following
% split omtr into K* classes, each containing one of the subclusters of
% omtr
disp('split the optimal clustering into classes each containing a subcluster...');
mtrs = SplitClasses(omtr);

disp('performing maximum likelihood classification...');
disp('for each test vector, the following calculates the log-likelihood given each of the classes, and classify');
disp(' ');
likelihood=zeros(size(pixels,1), length(mtrs));
for k=1:length(mtrs)
   likelihood(:,k) = GMClassLikelihood(mtrs(k), pixels);
end
class=ones(size(pixels,1),1);
for k=1:length(mtrs)
   class(find(likelihood(:,k)==max(likelihood,[],2)))=k;
end

color = ['bo';'rx';'gd'];
figure
hold on
for i=1:size(class,1)
    plot(pixels(i,1),pixels(i,2),color(class(i),:));
end
hold off
title('Gaussian mixture classification in original coordinates')
xlabel('first component')
ylabel('second component')

input('press <Enter> to continue...');
disp(' ');
% [mtrs, omtr] = GaussianMixtureWithDecorrelation(pixels, initK, finalK, verbose, ConditionNumber)
% - pixels is a NxM matrix, containing N training vectors, each of M-dimensional
% - start with initK=20 initial clusters
% - finalK=0 means estimate the optimal order
% - verbose=true displays clustering information
% - ConditionNumber=1e5 controls the ratio of mean to minimum diagonal elements
%   of the estimated covariance matrices. 
% - mtrs is an array of structures, each containing the cluster parameters of the
%   mixture of a particular order
% - omtr is a structure containing the cluster parameters of the mixture with
%   the estimated optimal order
disp('perform classification with Gaussian mixture model in decorrelated coordinates...');
[mixture_decor,omtr_decor] = GaussianMixtureWithDecorrelation(pixels, 20, 0, true, 1e5);
disp(sprintf('\toptimal order K*: %d', omtr_decor.K));
for i=1:omtr_decor.K
   disp(sprintf('\tCluster %d:', i));
   disp(sprintf('\t\tpi: %f', omtr_decor.cluster(i).pb));
   disp([sprintf('\t\tmean: '), mat2str(omtr_decor.cluster(i).mu',6)]);
   disp([sprintf('\t\tcovar: '), mat2str(omtr_decor.cluster(i).R,6)]);
end
input('press <Enter> to continue...');
disp(' ');

% with omtr containing the optimal clustering with order K*, the following
% split omtr into K* classes, each containing one of the subclusters of
% omtr
disp('split the optimal clustering into classes each containing a subcluster...');
mtrs_decor = SplitClasses(omtr_decor);

disp('performing maximum likelihood classification...');
disp('for each test vector, the following calculates the log-likelihood given each of the classes, and classify');
disp(' ');
likelihood_decor=zeros(size(pixels,1), length(mtrs_decor));
for k=1:length(mtrs)
   likelihood_decor(:,k) = GMClassLikelihood(mtrs_decor(k), pixels);
end
class_decor=ones(size(pixels,1),1);
for k=1:length(mtrs)
   class_decor(find(likelihood_decor(:,k)==max(likelihood_decor,[],2)))=k;
end

color = ['bo';'rx';'gd'];
figure
hold on
for i=1:size(class,1)
    plot(pixels(i,1),pixels(i,2),color(class(i),:));
end
hold off
title('Gaussian mixture classification in original coordinates')
xlabel('first component')
ylabel('second component')
