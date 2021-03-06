%% collapsed Gibbs sampler on DP mixture of 2d gaussians
%PMTKauthor Yee Whye Teh
%PMTKurl http://www.gatsby.ucl.ac.uk/~ywteh/teaching/npbayes/mlss2007.zip
%PMTKmodified Kevin Murphy
% Originally called dpm_demp2d

global base
base = [pwd '/'];
addpath(genpath([base 'matlab']));
addpath(genpath([base 'util']));
addpath(genpath([base 'graphics']));

dd = 2; % dims
KK = 1; % num clusters
%trueK = 5;
NN = 1668; % numData
aa = 15; % alpha = 1
s0 = 3;
ss = 1;
numiter = 800;

hh.dd = dd;
hh.ss = s0^2/ss^2;
hh.vv = 1.001; % 5; 1.001
hh.VV = [1 0;0 1];
hh.uu = [500; 1500];

setSeed(0);
  % construct data
%  truez = ceil((1:NN)/NN*trueK);
%  mu = randn(dd,trueK)*s0;
%  yy = mu(:,truez) + randn(dd,NN)*ss;
%  xx = num2cell(yy,1);

% extract/transform data
data2d = data(:, 3:4)';
celldata = num2cell(data2d, 1);
xx = celldata';

seeds = [2];
for trial=1:numel(seeds)
  seed = seeds(trial);
  setSeed(seed);
  
  % initialize component assignment
  zz = ceil(rand(1,NN)*KK);
  
  % initialize DP mixture
  dpm = dpm_init(KK,aa,Gaussian(hh),xx,zz);
  
  % initialize records
  record.KK = zeros(1,numiter);
  
  % initialize colors to be used for plotting
  %cc = colormap;
  %cc = cc(randperm(size(cc,1)),:);
  %cc = cc(rem(1:NN,size(cc,1))+1,:);
  [colors, colorMap] = pmtkColors();
  cc = cat(1, colors{:});
  
  Ns = [10 50 100 200 300 400 500 600]; % times to stop, plot and roll
  cnt = 1;
  tic;
  for iter = 1:numiter
    disp(iter)
    % pretty pictures
    if iter==Ns(cnt)
      figure
      dpm_demo2d_plot(dpm,cc);
      %axis([min(yy(:))-1 max(yy(:))+1  min(yy(:))-1 max(yy(:))+1]);
      title(['iter# ' num2str(iter)]);
      cnt = cnt+1;
      printPmtkFigure(sprintf('dpmGauss2dSeed%dIter%d', seed,iter))
      drawnow
    end
    
    % gibbs iteration
    dpm = dpm_gibbs(dpm,1);
    
    % record keeping
    record.KK(iter) = sum(dpm.nn>0);
  end
  toc;
  maxK = max(record.KK);
  burnin = 50;
  %postK = normalize(histc(record.KK(burnin:end),1:maxK));
  %figure; 
  %bar(postK)
  %printPmtkFigure(sprintf('dpmGauss2dSeed%dPostK', seed))
  %drawnow
end