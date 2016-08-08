
init
%% Configure model Rathinam2003
modelName = 'Rathinam2003';
modelStopTime = 20;
trajectoryCount = 1e3;

%% Uncomment for Besozzi2012 model
% modelName = 'Besozzi2012';
% modelStopTime = 25;
% trajectoryCount = 1e3;
% warning: symbolic jacobian computation not possible for Besozzi!

%% Uncomment for Wang2010 model
% modelName = 'Wang2010';
% modelStopTime = 150;
% trajectoryCount = 1e3;

%% Configure simulation
useSymbolicJacobian = false; 
timeIntervals = 10;
opts = mlOptions('SYM_JAC', useSymbolicJacobian);

%% Prepare paths/model
modelDir = fullfile('models', modelName);
sbmlPath = fullfile(modelDir, [modelName '.xml']);
sbmlModel = TranslateSBML(sbmlPath);
mexName = ['ml' modelName];
mexFuncPath = fullfile(modelDir, [mexName '.' mexext]);
if (~exist(mexFuncPath,'file'))
    mlPrepareModel(modelDir, mexName, sbmlModel, opts);
end

%% Run simulation
X0 = [sbmlModel.species.initialAmount];
theta = [sbmlModel.parameter.value];
tic
[ Trajectories, Time, R, IntG, simStats ] = mlSimulate( str2func(mexName), modelStopTime, timeIntervals, X0, theta, opts, trajectoryCount);
toc

%% Plot means / std of matLeap, Stochkit-SSA and Stochkit-TauLeaping
methodNames = {'matLeap'};
methodData = cell(0,2);
methodData(1,:) = {Time, Trajectories};

% Stochkit Tau
tauPath = fullfile(modelDir, [modelName '_SKTAU.mat']);
if (exist(tauPath,'file'))
    methodNames{end+1} = 'SKTAU';
    tauFile = load(tauPath);
    methodData(end+1,:) = {tauFile.Time, tauFile.Trajectories};
end

% Stochkit SSA
ssaPath = fullfile(modelDir, [modelName '_SSA.mat']);
if (exist(ssaPath,'file'))
    methodNames{end+1} = 'SSA';
    ssaFile = load(ssaPath);
    methodData(end+1,:) = {ssaFile.Time, ssaFile.Trajectories};
end

SpeciesNo = length(sbmlModel.species);
methodColors = {'b','k','g'};
rowNo = ceil(sqrt(SpeciesNo));
colNo = ceil(sqrt(SpeciesNo));
for sIdx = 1:SpeciesNo
    for meIdx = 1:3
        subplot(rowNo, colNo, sIdx);
        curTime = methodData{meIdx,1};
        curData = squeeze(methodData{meIdx,2}(:,sIdx,:));
        hSEB=shadedErrorBar(curTime', curData', {@mean,@std}, methodColors{meIdx},1);
        hSEB.mainLine.DisplayName = methodNames{meIdx};
        hold on;
        title(sbmlModel.species(sIdx).name, 'Interpreter', 'none');
    end
    if (sIdx == 1)
        legend(findobj(gca, '-regexp', 'DisplayName', '[^'']'));
    end
    hold off;
end
