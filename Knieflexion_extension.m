%% =======================
%% MVNX Daten laden
%% =======================
filename = 'NV_Knie_data.mvnx';  % Datei anpassen
tree = load_mvnx(filename);

%% =======================
%% frameRate
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
%% Segmentnummern (Positionen)
%% =======================
% Diese Segmentnummern müssen mit deiner MVNX Datei übereinstimmen
rightUpper = 16;   % Rechtes Oberbein
rightLower = 17;   % Rechtes Unterschenkel
leftUpper  = 20;   % Linkes Oberbein
leftLower  = 21;   % Linkes Unterschenkel

%% =======================
%% Positionen der Segmente
%% =======================
posRU = tree.segmentData(rightUpper).position; % nFrames x 3
posRL = tree.segmentData(rightLower).position;
posLU = tree.segmentData(leftUpper).position;
posLL = tree.segmentData(leftLower).position;

% Sicherstellen, dass Positionsdaten korrekt sind
if iscell(posRU), posRU = cell2mat(posRU); end
if iscell(posRL), posRL = cell2mat(posRL); end
if iscell(posLU), posLU = cell2mat(posLU); end
if iscell(posLL), posLL = cell2mat(posLL); end

nFrames = size(posRU,1);
time = (0:nFrames-1)*timeStep;

%% =======================
%% Kniewinkel berechnen (Sagittalebene: x-z)
%% =======================
kneeRight = zeros(nFrames,1);
kneeLeft  = zeros(nFrames,1);

for i = 1:nFrames
    % Rechtes Knie: Vektoren Ober- und Unterschenkel
    vThigh = posRU(i,:) - posRL(i,:);  % Oberbein -> Unterschenkel
    vShank = posRL(i,:) - posRL(max(i-1,1),:); % Unterschenkel Bewegungsvektor
    
    % Projektion auf Sagittalebene (x-z)
    vThighSag = [vThigh(1), vThigh(3)];
    vShankSag = [0 -1]; % angenommene Referenz für gestrecktes Bein
    
    % Winkel zwischen Ober- und Unterschenkel
    kneeRight(i) = acosd(dot(vThighSag,vShankSag)/(norm(vThighSag)*norm(vShankSag)));
    
    % Linkes Knie
    vThighL = posLU(i,:) - posLL(i,:);
    vShankL = posLL(i,:) - posLL(max(i-1,1),:);
    vThighSagL = [vThighL(1), vThighL(3)];
    kneeLeft(i) = acosd(dot(vThighSagL,vShankSag)/(norm(vThighSagL)*norm(vShankSag)));
end

%% =======================
%% Flexion / Extension
%% =======================
flexRight = max(kneeRight,0);
flexLeft  = max(kneeLeft,0);

extRight = min(kneeRight,0);
extLeft  = min(kneeLeft,0);

%% =======================
%% Plot Flexion & Extension
%% =======================
figure('Name','Knie Flexion & Extension','Color','w'); hold on
plot(time, flexRight,'r','LineWidth',1.5)
plot(time, flexLeft,'b','LineWidth',1.5)
plot(time, extRight,'r--','LineWidth',1.5)
plot(time, extLeft,'b--','LineWidth',1.5)

xlabel('Zeit [s]')
ylabel('Winkel [°]')
legend('Rechtes Knie Flexion','Linkes Knie Flexion','Rechtes Knie Extension','Linkes Knie Extension')
title('Knie Flexion & Extension aus Segmentpositionen beim Gehen')
grid on

%% =======================
%% ROM ausgeben
%% =======================
ROM_right = max(kneeRight)-min(kneeRight);
ROM_left  = max(kneeLeft)-min(kneeLeft);
disp(['ROM Rechtes Knie: ' num2str(ROM_right) '°'])
disp(['ROM Linkes Knie: ' num2str(ROM_left) '°'])