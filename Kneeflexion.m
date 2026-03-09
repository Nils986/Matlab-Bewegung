function [results] = processKneeData(filename)
%% PROCESSKNEEDATA Berechnet Kniewinkel aus einer MVNX-Datei
% Input:  filename - Pfad zur .mvnx Datei (String)
% Output: results  - Struct mit Zeitvektor, Winkeln und ROM

    %% 1. MVNX Daten laden
    tree = load_mvnx(filename);

    %% 2. frameRate extrahieren & aufbereiten
    % (Logik aus deinem Skript übernommen)
    frameRateRaw = tree.metaData.subject_frameRate;
    if iscell(frameRateRaw)
        frameRate = str2double(frameRateRaw{1});
    elseif isstring(frameRateRaw) || ischar(frameRateRaw)
        frameRate = str2double(frameRateRaw);
    else
        frameRate = frameRateRaw(1);
    end
    timeStep = 1/frameRate;

    %% 3. Segmentpositionen extrahieren
    % Indizes (Konstanten innerhalb der Funktion)
    rightUpper = 16; rightLower = 17;
    leftUpper  = 20; leftLower  = 21;

    posRU = extractPos(tree.segmentData(rightUpper).position);
    posRL = extractPos(tree.segmentData(rightLower).position);
    posLU = extractPos(tree.segmentData(leftUpper).position);
    posLL = extractPos(tree.segmentData(leftLower).position);

    nFrames = size(posRU,1);
    time = (0:nFrames-1) * timeStep;

    %% 4. Kniewinkel berechnen
    kneeRight = zeros(nFrames,1);
    kneeLeft  = zeros(nFrames,1);
    vShankRef = [0, -1]; % Referenzvektor Sagittalebene

    for i = 1:nFrames
        % Rechts
        vThighR = [posRU(i,1) - posRL(i,1), posRU(i,3) - posRL(i,3)];
        kneeRight(i) = acosd(dot(vThighR, vShankRef) / (norm(vThighR) * norm(vShankRef)));
        
        % Links
        vThighL = [posLU(i,1) - posLL(i,1), posLU(i,3) - posLL(i,3)];
        kneeLeft(i) = acosd(dot(vThighL, vShankRef) / (norm(vThighL) * norm(vShankRef)));
    end

    %% 5. Ergebnisse strukturieren
    results.time = time;
    results.kneeRight = kneeRight;
    results.kneeLeft = kneeLeft;
    results.ROM_right = max(kneeRight) - min(kneeRight);
    results.ROM_left  = max(kneeLeft) - min(kneeLeft);

    %% 6. Visualisierung (Optional, kann durch Flag gesteuert werden)
    plotResults(time, kneeRight, kneeLeft);
    
    % Konsolenausgabe
    fprintf('Datei: %s\n', filename);
    fprintf('ROM Rechts: %.2f° | ROM Links: %.2f°\n', results.ROM_right, results.ROM_left);
end

%% --- HILFSFUNKTIONEN (Local Functions) ---

function pos = extractPos(data)
    % Hilfsfunktion zum Umwandeln von Cell zu Matrix
    if iscell(data)
        pos = cell2mat(data);
    else
        pos = data;
    end
end

function plotResults(t, kR, kL)
    figure('Name','Knie Analyse','Color','w'); hold on
    plot(t, kR, 'r', 'LineWidth', 1.5, 'DisplayName', 'Rechts');
    plot(t, kL, 'b', 'LineWidth', 1.5, 'DisplayName', 'Links');
    grid on; xlabel('Zeit [s]'); ylabel('Winkel [°]');
    legend show; title('Knie Flexion/Extension');
end
