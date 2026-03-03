%% =======================
%% MVNX Daten laden
%% =======================
filename = 'NV_Knie_data.mvnx';  % Datei anpassen
tree = load_mvnx(filename);

%% =======================
%% Basisdaten auslesen
%% =======================
frameRate = tree.metaData.subject_frameRate;
if iscell(frameRate)
    frameRate = str2double(frameRate{1});
elseif isstring(frameRate) || ischar(frameRate)
    frameRate = str2double(frameRate);
elseif numel(frameRate) > 1
    frameRate = frameRate(1);
end
timeStep = 1/frameRate;

%% =======================
%% Segmentnummern für Hüfte
%% =======================
pelvis       = 1;   % Becken
rightUpper   = 16;  % Right Upper Leg (Femur)
leftUpper    = 20;  % Left Upper Leg (Femur)

%% =======================
%% Quaternionen aus Segmentdaten
%% =======================
q_pelvis     = tree.segmentData(pelvis).orientation;
q_rightUpper = tree.segmentData(rightUpper).orientation;
q_leftUpper  = tree.segmentData(leftUpper).orientation;

% Cell in Matrix umwandeln falls nötig
if iscell(q_pelvis),     q_pelvis     = cell2mat(q_pelvis);     end
if iscell(q_rightUpper), q_rightUpper = cell2mat(q_rightUpper); end
if iscell(q_leftUpper),  q_leftUpper  = cell2mat(q_leftUpper);  end

nFrames = size(q_pelvis,1);
time = (0:nFrames-1) * timeStep;

hipRight = zeros(nFrames,1);
hipLeft  = zeros(nFrames,1);

%% =======================
%% Hüftflexion berechnen
%% =======================
for i = 1:nFrames
    % Rechts
    R_p = quat2rotm_manual(q_pelvis(i,:));
    R_u = quat2rotm_manual(q_rightUpper(i,:));
    R_rel = R_p' * R_u;
    hipRight(i) = atan2d(R_rel(3,2), R_rel(3,3));
    
    % Links
    R_uL = quat2rotm_manual(q_leftUpper(i,:));
    R_relL = R_p' * R_uL;
    hipLeft(i) = atan2d(R_relL(3,2), R_relL(3,3));
end

%% =======================
%% Plot beider Hüften
%% =======================
figure('Name','Hüftflexion beider Beine','Color','w')
plot(time, hipRight,'r','LineWidth',1.5)
hold on
plot(time, hipLeft,'b','LineWidth',1.5)
xlabel('Zeit [s]')
ylabel('Hüftflexion [°]')
legend('Rechtes Bein','Linkes Bein')
title('Hüftflexion / Extension')
grid on

%% =======================
%% Max/Min Werte ausgeben
%% =======================
fprintf('\nRechtes Hüftgelenk: Max = %.2f°, Min = %.2f°\n', max(hipRight), min(hipRight));
fprintf('Linkes Hüftgelenk:   Max = %.2f°, Min = %.2f°\n', max(hipLeft), min(hipLeft));

%% =======================
%% Funktion: Quaternion -> Rotationsmatrix
%% =======================
function R = quat2rotm_manual(q)
    % q = [w x y z]
    w = q(1); x = q(2); y = q(3); z = q(4);
    R = [1-2*(y^2+z^2), 2*(x*y - z*w), 2*(x*z + y*w);
         2*(x*y + z*w), 1-2*(x^2+z^2), 2*(y*z - x*w);
         2*(x*z - y*w), 2*(y*z + x*w), 1-2*(x^2 + y^2)];
end