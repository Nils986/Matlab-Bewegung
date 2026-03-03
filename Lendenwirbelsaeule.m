%% ==========================================================
%  Lendenwirbelsäulen-Streckung aus MVNX Daten
%% ==========================================================

clear; clc; close all;

%% ===============================
% Datei laden
%% ===============================

filename = 'NV_Knie_data.mvnx';
tree = load_mvnx(filename);

frameRate = 30;
dt = 1/frameRate;

%% ===============================
% Segmente laden
% Typisch:
% 1 = Pelvis
% 2 = Thorax
%% ===============================

pelvisID = 1;
thoraxID = 2;

qPelvis = tree.segmentData(pelvisID).orientation;
qThorax = tree.segmentData(thoraxID).orientation;

if iscell(qPelvis)
    qPelvis = cell2mat(qPelvis);
end

if iscell(qThorax)
    qThorax = cell2mat(qThorax);
end

nFrames = size(qPelvis,1);
time = (0:nFrames-1)/frameRate;

%% ===============================
% LWS Streckung berechnen
%% ===============================

lws = zeros(nFrames,1);

for i=1:nFrames
    
    R_pelvis = quatToRotMat(qPelvis(i,:));
    R_thorax = quatToRotMat(qThorax(i,:));
    
    % Relative Rotation Thorax zu Becken
    R_rel = R_pelvis' * R_thorax;
    
    % Sagittale Ebene = Flexion / Extension
    lws(i) = atan2d(R_rel(3,2), R_rel(3,3));
end

%% Winkel stabilisieren
lws = mod(lws+180,360)-180;

%% ===============================
% Plot
%% ===============================

figure('Color','w')

plot(time,lws,'LineWidth',2)

xlabel('Zeit [s]')
ylabel('LWS Winkel [°]')
title('Lendenwirbelsäulen-Streckung beim Laufen')

grid on

%% ===============================
% Statistik
%% ===============================

fprintf('\nLWS Analyse\n')
fprintf('Mittelwert LWS: %.2f°\n',mean(lws))
fprintf('Std Abweichung: %.2f°\n',std(lws))

%% ==========================================================
% Quaternion → Rotationsmatrix
%% ==========================================================

function R = quatToRotMat(q)

w=q(1); x=q(2); y=q(3); z=q(4);

R = [1-2*y^2-2*z^2, 2*x*y-2*z*w,   2*x*z+2*y*w;
     2*x*y+2*z*w,   1-2*x^2-2*z^2, 2*y*z-2*x*w;
     2*x*z-2*y*w,   2*y*z+2*x*w,   1-2*x^2-2*y^2];

end