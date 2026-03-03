%% ==========================================================
%  Hüftflexion / -extension aus MVNX
%  OHNE Aerospace Toolbox
%% ==========================================================

clear; clc;

%% =======================
% MVNX Datei laden
%% =======================
filename = 'NV_Knie_data.mvnx';   % <-- anpassen
tree = load_mvnx(filename);

%% =======================
% FrameRate
%% =======================
frameRate = tree.metaData.subject_frameRate;

if iscell(frameRate)
    frameRate = str2double(frameRate{1});
elseif ischar(frameRate) || isstring(frameRate)
    frameRate = str2double(frameRate);
elseif numel(frameRate) > 1
    frameRate = frameRate(1);
end

dt = 1/frameRate;

%% =======================
% Segment IDs
%% =======================
pelvis     = 1;
rightThigh = 16;
leftThigh  = 20;

%% =======================
% Quaternionen laden
%% =======================
qPelvis = tree.segmentData(pelvis).orientation;
qRThigh = tree.segmentData(rightThigh).orientation;
qLThigh = tree.segmentData(leftThigh).orientation;

if iscell(qPelvis), qPelvis = cell2mat(qPelvis); end
if iscell(qRThigh), qRThigh = cell2mat(qRThigh); end
if iscell(qLThigh), qLThigh = cell2mat(qLThigh); end

nFrames = size(qPelvis,1);
time = (0:nFrames-1)*dt;

%% =======================
% Hüftwinkel berechnen
%% =======================
hipRight = zeros(nFrames,1);
hipLeft  = zeros(nFrames,1);

for i = 1:nFrames
    
    % Relative Rotation: Pelvis^-1 * Thigh
    qRelR = quatMultiply(quatInverse(qPelvis(i,:)), qRThigh(i,:));
    qRelL = quatMultiply(quatInverse(qPelvis(i,:)), qLThigh(i,:));
    
    % Rotationsmatrix
    Rr = quatToRotMat(qRelR);
    Rl = quatToRotMat(qRelL);
    
    % Sagittalebene (Flex/Ext)
    hipRight(i) = atan2d(Rr(3,2), Rr(3,3));
    hipLeft(i)  = atan2d(Rl(3,2), Rl(3,3));
end

%% Unwrap
hipRight = rad2deg(unwrap(deg2rad(hipRight)));
hipLeft  = rad2deg(unwrap(deg2rad(hipLeft)));

%% =======================
% Plot
%% =======================
figure('Color','w');
plot(time, hipRight,'r','LineWidth',1.5); hold on
plot(time, hipLeft,'b','LineWidth',1.5);

xlabel('Zeit [s]')
ylabel('Hüftwinkel [°]')
legend('Rechts','Links')
title('Hüftflexion / -extension (relativ zum Becken)')
grid on

%% =======================
% ROM
%% =======================
ROM_right = max(hipRight) - min(hipRight);
ROM_left  = max(hipLeft) - min(hipLeft);

disp(['ROM Rechts: ' num2str(ROM_right,'%.2f') '°'])
disp(['ROM Links:  ' num2str(ROM_left,'%.2f') '°'])


%% ==========================================================
%% =============   LOKALE FUNKTIONEN   =====================
%% ==========================================================

function qInv = quatInverse(q)
    qInv = [q(1), -q(2), -q(3), -q(4)] ./ sum(q.^2);
end

function q = quatMultiply(q1,q2)
    w1=q1(1); x1=q1(2); y1=q1(3); z1=q1(4);
    w2=q2(1); x2=q2(2); y2=q2(3); z2=q2(4);
    
    w = w1*w2 - x1*x2 - y1*y2 - z1*z2;
    x = w1*x2 + x1*w2 + y1*z2 - z1*y2;
    y = w1*y2 - x1*z2 + y1*w2 + z1*x2;
    z = w1*z2 + x1*y2 - y1*x2 + z1*w2;
    
    q = [w x y z];
end

function R = quatToRotMat(q)
    w=q(1); x=q(2); y=q(3); z=q(4);
    
    R = [1-2*y^2-2*z^2, 2*x*y-2*z*w,   2*x*z+2*y*w;
         2*x*y+2*z*w,   1-2*x^2-2*z^2, 2*y*z-2*x*w;
         2*x*z-2*y*w,   2*y*z+2*x*w,   1-2*x^2-2*y^2];
end