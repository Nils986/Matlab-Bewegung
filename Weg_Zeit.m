clear; clc;

%% MVNX Datei laden
[fileName,pathName] = uigetfile('*.mvnx','MVNX Datei wählen');
mvnxFile = fullfile(pathName,fileName);

xmlData = xml2struct(mvnxFile);
frames = xmlData.mvnx.subject.frames.frame;

nFrames = length(frames);

%% Speicher
leftFoot = zeros(nFrames,3);
rightFoot = zeros(nFrames,3);
timeVec = zeros(nFrames,1);

%% Daten extrahieren
for i = 1:nFrames
    
    timeVec(i) = str2double(frames{i}.Attributes.time);
    segments = frames{i}.segment;
    
    for s = 1:length(segments)
        
        name = segments{s}.Attributes.name;
        
        if contains(name,'LeftFoot','IgnoreCase',true) || ...
           contains(name,'LeftToe','IgnoreCase',true)
            
            leftFoot(i,:) = [
                str2double(segments{s}.position.Attributes.x)
                str2double(segments{s}.position.Attributes.y)
                str2double(segments{s}.position.Attributes.z)
            ];
        end
        
        if contains(name,'RightFoot','IgnoreCase',true) || ...
           contains(name,'RightToe','IgnoreCase',true)
            
            rightFoot(i,:) = [
                str2double(segments{s}.position.Attributes.x)
                str2double(segments{s}.position.Attributes.y)
                str2double(segments{s}.position.Attributes.z)
            ];
        end
    end
end

%% Samplingrate
fs = 1/mean(diff(timeVec));

%% Klinische Filterung (Medizintechnik Standard)
fc = 6;
[b,a] = butter(4,fc/(fs/2));

leftFoot(:,3) = filtfilt(b,a,leftFoot(:,3));
rightFoot(:,3) = filtfilt(b,a,rightFoot(:,3));

%% Gangereignisse (Heel Strike Approximation)
minDist = round(fs*0.6);

[leftPeaks,leftIdx] = findpeaks(-leftFoot(:,3),...
    'MinPeakDistance',minDist);

[rightPeaks,rightIdx] = findpeaks(-rightFoot(:,3),...
    'MinPeakDistance',minDist);

%% Schrittparameter berechnen
leftStepTime = diff(timeVec(leftIdx));
rightStepTime = diff(timeVec(rightIdx));

stepTime = [leftStepTime; rightStepTime];

leftStepLen = vecnorm(diff(leftFoot(leftIdx,:)),2,2);
rightStepLen = vecnorm(diff(rightFoot(rightIdx,:)),2,2);

stepLength = [leftStepLen; rightStepLen];

stepFreq = 60 ./ stepTime;

%% Variabilität (Sehr wichtig für Bachelorarbeit!)
fprintf('\n===== Medizintechnik Ganganalyse =====\n');

fprintf('Schrittlänge Mittelwert: %.3f m\n',mean(stepLength,'omitnan'));
fprintf('Schrittlänge SD: %.3f m\n',std(stepLength,'omitnan'));

fprintf('Schrittzeit Mittelwert: %.3f s\n',mean(stepTime,'omitnan'));
fprintf('Schrittzeit SD: %.3f s\n',std(stepTime,'omitnan'));

fprintf('Schrittfrequenz Mittelwert: %.2f Schritte/min\n',mean(stepFreq,'omitnan'));

%% Plot
figure;

subplot(3,1,1)
plot(stepLength)
ylabel('Schrittlänge (m)')
title('Schrittlängenverlauf')

subplot(3,1,2)
plot(stepTime)
ylabel('Zeit (s)')
title('Schrittzeitverlauf')

subplot(3,1,3)
plot(stepFreq)
ylabel('Schritte/min')
title('Schrittfrequenzverlauf')