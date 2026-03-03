%% ==========================================================
%  COM Bewegung – Eine Aufnahme pro Laufuntergrund
%% ==========================================================

clear; clc; close all;

%% ===============================
% Datei laden (eine Aufnahme!)
%% ===============================

filename = 'NV_Knie_data.mvnx';
tree = load_mvnx(filename);

frameRate = 30;
dt = 1/frameRate;

%% ===============================
% Segmentdaten laden
%% ===============================

segments = tree.segmentData;
nSegments = length(segments);

for s = 1:nSegments
    
    p = segments(s).position;
    
    if iscell(p)
        p = cell2mat(p);
    end
    
    pos{s} = p; %#ok<SAGROW>

    if isfield(segments(s),'mass')
        mass(s) = segments(s).mass;
    else
        mass(s) = 1;
    end
    
end

nFrames = size(pos{1},1);
time = (0:nFrames-1)*dt;

%% ===============================
% COM berechnen
%% ===============================

COM = zeros(nFrames,3);
totalMass = sum(mass);

for i = 1:nFrames
    
    temp = zeros(1,3);
    
    for s = 1:nSegments
        
        temp = temp + mass(s)*pos{s}(i,1:3);
        
    end
    
    COM(i,:) = temp/totalMass;
end

%% ===============================
% COM Bewegung darstellen
%% ===============================

figure('Color','w')

plot(COM(:,1),COM(:,3),'LineWidth',2)

xlabel('Vorwärtsbewegung (m)')
ylabel('Vertikale Bewegung (m)')
title('COM Bewegung während einer Laufaufnahme')

grid on
axis equal

%% ===============================
% COM Schwankung ausgeben
%% ===============================

fprintf('\nCOM Analyse\n')
fprintf('Vertikale Schwankung: %.4f m\n',std(COM(:,3)))
fprintf('Medio-laterale Schwankung: %.4f m\n',std(COM(:,2)))