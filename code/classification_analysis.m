%% Prepare Space
clear; clc;


%% User input
% 1: non-randomized threshold
% 2: randomized threshold
% 3: noise only
typInd = 3;


%% Load and store data
% Load all data files from directory
typ = {'[^randomized]_threshold','randomized','noiseOnly'};
L = dir('data/all_betti_data_thresh*');

% Identify files by type
th = zeros(length(L),1);
ty = zeros(length(L),1);
for i = 1:length(L)
    ty(i) = ~isempty(regexp(L(i).name,typ{typInd}));
    v = regexp(L(i).name,'thresh\d+','match');
    v = v{1}(7:end);
    v = ['.' v(2:end)];
    th(i) = str2double(v);
end
th = th(logical(ty));
L = L(logical(ty));
[th,thI] = sort(th);
L = L(thI);
nT = length(L);

% Initialize data
load(['data/' L(1).name]);
BCAA = zeros([size(betti_curve_array_all), nT]);

% All
bb_a = zeros([size(bettiBar_all),nT]);                  % BettiBar
mb_a = zeros([size(muBar_all),nT]);                     % MuBar
nb_a = zeros([size(nuBar_all),nT]);                     % NuBar

% Load extra data if dataset is not from noiseOnly
if(typInd ~= 3)
    % Prenoise
    bb_pr = zeros([size(bettiBar_all_prenoise),nT]);
    mb_pr = zeros([size(muBar_all_prenoise),nT]);
    nb_pr = zeros([size(nuBar_all_prenoise),nT]);
    % Postnoise
    bb_po = zeros([size(bettiBar_all_postnoise),nT]);
    mb_po = zeros([size(muBar_all_postnoise),nT]);
    nb_po = zeros([size(nuBar_all_postnoise),nT]);
    % Blues
    bb_b = zeros([size(bettiBar_all_blues),nT]);
    mb_b = zeros([size(muBar_all_blues),nT]);
    nb_b = zeros([size(nuBar_all_blues),nT]);
    % Crossover
    bb_c = zeros([size(bettiBar_all_crossover),nT]);
    mb_c = zeros([size(muBar_all_crossover),nT]);
    nb_c = zeros([size(nuBar_all_crossover),nT]);
end

% Dimensions
d1 = size(bettiBar_all,1);
d2 = size(bettiBar_all,2);
d3 = size(bettiBar_all,3);

% Store features
for i = 1:length(L)
    load(['data/' L(i).name]);
    BCAA(:,:,:,:,i) = betti_curve_array_all;
    
    % All
    bb_a(:,:,:,i) = bettiBar_all;
    mb_a(:,:,:,i) = muBar_all;
    nb_a(:,:,:,i) = nuBar_all;
    
    if(typInd ~= 3)
        % Prenoise
        bb_pr(:,:,:,i) = bettiBar_all_prenoise;
        mb_pr(:,:,:,i) = muBar_all_prenoise;
        nb_pr(:,:,:,i) = nuBar_all_prenoise;
        % Postnoise
        bb_po(:,:,:,i) = bettiBar_all_postnoise;
        mb_po(:,:,:,i) = muBar_all_postnoise;
        nb_po(:,:,:,i) = nuBar_all_postnoise;
        % Blues
        bb_b(:,:,:,i) = bettiBar_all_blues;
        mb_b(:,:,:,i) = muBar_all_blues;
        nb_b(:,:,:,i) = nuBar_all_blues;
        % Crossover
        bb_c(:,:,:,i) = bettiBar_all_crossover;
        mb_c(:,:,:,i) = muBar_all_crossover;
        nb_c(:,:,:,i) = nuBar_all_crossover;
    end
end

% Store graph names
nm = cell(size(names_ordered));
for i = 1:length(nm)
    nmP = strsplit(names_ordered{i},'_');
    nm{i} = nmP{1};
end

% Dimensions
n = size(bb_a,1);


%% Statistical comparison
% Types of features
if(typInd==3)
    strL = {'all'};
else
    strL = {'all', 'prenoise', 'postnoise', 'blues', 'crossover'};
end

% Number of resampling repetitions
K = 100;

% Matrix of accuracies
Acc = zeros(length(strL),length(th),K);

% Iterate over feature types
for i = 1:length(strL)
    
    % Iterate over thresholds
    for j = 1:length(th)
        fI = find(th==th(j));
        if(strcmp(strL{i},'all'))
            Xtr = cat(2,bb_a(:,:,:,fI),mb_a(:,:,:,fI),nb_a(:,:,:,fI));
        elseif(strcmp(strL{i},'prenoise'))
            Xtr = cat(2,bb_pr(:,:,:,fI),mb_pr(:,:,:,fI),nb_pr(:,:,:,fI));
        elseif(strcmp(strL{i},'postnoise'))
            Xtr = cat(2,bb_po(:,:,:,fI),mb_po(:,:,:,fI),nb_po(:,:,:,fI));
        elseif(strcmp(strL{i},'blues'))
            Xtr = cat(2,bb_b(:,:,:,fI),mb_b(:,:,:,fI),nb_b(:,:,:,fI));
        elseif(strcmp(strL{i},'crossover'))
            Xtr = cat(2,bb_c(:,:,:,fI),mb_c(:,:,:,fI),nb_c(:,:,:,fI));
        end


        for k = 1:K
            % Reshape testing data
            N = 250;
            trInd = randperm(n,N);                      % Training indices
            teInd = setdiff(1:n,trInd);                 % Testing indices
            
            % Store testing data
            Xte = zeros([(n-N)*size(Xtr,3),size(Xtr,2),size(Xtr,4)]);
            for m = 1:size(Xtr,3)
                Xte((1:(n-N))+(m-1)*(n-N),:,:) = Xtr(teInd,:,m,:); 
            end

            % Compute mean and covariance for training data
            muv = zeros(size(Xtr,3),size(Xtr,2));                   % Mean
            sigmav = zeros(size(Xtr,2),size(Xtr,2),size(Xtr,3));    % CoV
            for m = 1:size(muv,1)
                muv(m,:) = mean(Xtr(trInd,:,m));
                sigmav(:,:,m) = cov(Xtr(trInd,:,m),1) + eye(size(Xtr,2))*.01;
            end
            
            % Combine models and compute predictions
            GM = gmdistribution(muv,sigmav);
            PO = posterior(GM,Xte);
            y = ones(size(Xtr,1)-N,1).*(1:size(Xtr,3)); y = y(:);
            [~,a] = max(PO(:,:),[],2);
            
            % Store classifier performance
            Acc(i,j,k) = sum(y==a)/length(a);
        end
    end
    
    % Generate confusion matrix
    C = confusionmat(y,a);
end


%% Plot
typTitle = {'threshold','randomized','noise only'};

figure(1); clf;
AccM = mean(Acc,3);
AccS = std(Acc,[],3);
errorbar(repmat(th',length(strL),1)',AccM',AccS');
xlabel('threshold');
ylabel('% classification accuracy');
title(typTitle{typInd});
legend(strL,'location','southwest');
axis([.05 .95 0 .8]);

