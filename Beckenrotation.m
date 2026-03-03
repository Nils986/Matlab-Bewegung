%% ==========================================================
%  Beckeninnenrotation relativ zum Gangzyklus
%% ==========================================================

clear; clc; close all;

%% ===============================
% Daten laden
%% ===============================

filename = 'NV_Knie_data.mvnx';
tree = load_mvnx(filename);

frameRate = 30;
dt = 1/frameRate;

qPelvis = tree.segmentData(1).orientation;

if iscell(qPelvis)
    qPelvis = cell2mat(qPelvis);
end

nFrames = size(qPelvis,1);

%% ===============================
% Referenzpose (Startlaufphase)
%% ===============================

qRef = mean(qPelvis(1:20,:),1);
qRef = qRef ./ norm(qRef);

R_ref = quatToRotMat(qRef);

%% ===============================
% Rotation berechnen
%% ===============================

yaw = zeros(nFrames,1);

for i=1:nFrames
    
    R_global = quatToRotMat(qPelvis(i,:));
    R_rel = R_ref' * R_global;
    
    yaw(i) = atan2d(R_rel(2,1),R_rel(1,1));
end

yaw = mod(yaw+180,360)-180;

%% ===============================
% Schrittzyklus erkennen (Peak Detection)
%% ===============================

stepEvents = [];

for i=2:nFrames-1
    if yaw(i) > yaw(i-1) && yaw(i) > yaw(i+1)
        stepEvents(end+1) = i; %#ok<SAGROW>
    end
end

%% ===============================
% Gangzyklus normalisieren (0-100 %)
%% ===============================

cycleMatrix = [];

for s=1:length(stepEvents)-1
    
    idx1 = stepEvents(s);
    idx2 = stepEvents(s+1);
    
    cycleData = yaw(idx1:idx2);
    
    % Zeitnormalisierung auf 101 Punkte (0-100%)
    xOld = linspace(0,100,length(cycleData));
    xNew = linspace(0,100,101);
    
    cycleMatrix(s,:) = interp1(xOld,cycleData,xNew); %#ok<SAGROW>
end

%% ===============================
% Mittelwert Gangzyklus berechnen
%% ===============================

meanCycle = mean(cycleMatrix,1,'omitnan');

%% ===============================
% Plot
%% ===============================

figure('Color','w')

subplot(2,1,1)
time = (0:nFrames-1)/frameRate;
plot(time,yaw,'LineWidth',1.5)
hold on
xline(time(stepEvents),'--')

xlabel('Zeit [s]')
ylabel('Rotation [°]')
title('Beckenrotation Zeitverlauf')
grid on

subplot(2,1,2)

plot(linspace(0,100,101),meanCycle,'LineWidth',2)

xlabel('Gangzyklus [%]')
ylabel('Beckenrotation [°]')
title('Mittlere Beckenrotation über Gangzyklus')
grid on

%% ==========================================================
% Quaternion → Rotationsmatrix
%% ==========================================================

function R = quatToRotMat(q)

w=q(1); x=q(2); y=q(3); z=q(4);

R = [1-2*y^2-2*z^2, 2*x*y-2*z*w,   2*x*z+2*y*w;
     2*x*y+2*z*w,   1-2*x^2-2*z^2, 2*y*z-2*x*w;
     2*x*z-2*y*w,   2*y*z+2*x*w,   1-2*x^2-2*y^2];

end