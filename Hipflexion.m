function [results] = Hiplexion(filename)
% HUEFTFLEXION Berechnet Hüftwinkel aus MVNX-Orientierungsdaten (Quaternionen)

    %% 1. Daten laden
    tree = load_mvnx(filename);

    %% 2. Basisdaten & FrameRate
    frameRateRaw = tree.metaData.subject_frameRate;
    if iscell(frameRateRaw), frameRate = str2double(frameRateRaw{1});
    else, frameRate = str2double(frameRateRaw); end
    timeStep = 1/frameRate;

    %% 3. Orientierungsdaten (Quaternionen) extrahieren
    pelvis = 1; rightUpper = 16; leftUpper = 20;

    qP = extractData(tree.segmentData(pelvis).orientation);
    qRU = extractData(tree.segmentData(rightUpper).orientation);
    qLU = extractData(tree.segmentData(leftUpper).orientation);

    nFrames = size(qP, 1);
    time = (0:nFrames-1) * timeStep;
    hipRight = zeros(nFrames,1);
    hipLeft  = zeros(nFrames,1);

    %% 4. Berechnung via Rotationsmatrizen
    for i = 1:nFrames
        R_p = quat2rotm_manual(qP(i,:));
        
        % Rechts
        R_uR = quat2rotm_manual(qRU(i,:));
        R_relR = R_p' * R_uR;
        hipRight(i) = atan2d(R_relR(3,2), R_relR(3,3));
        
        % Links
        R_uL = quat2rotm_manual(qLU(i,:));
        R_relL = R_p' * R_uL;
        hipLeft(i) = atan2d(R_relL(3,2), R_relL(3,3));
    end

    %% 5. Ergebnisse strukturieren
    results.time = time;
    results.hipRight = hipRight;
    results.hipLeft = hipLeft;
    results.maxR = max(hipRight);
    results.minR = min(hipRight);
    results.maxL = max(hipLeft);
    results.minL = min(hipLeft);

    %% 6. Plot
    figure('Name',['Hüftflexion: ' filename],'Color','w');
    plot(time, hipRight,'r','LineWidth',1.5); hold on;
    plot(time, hipLeft,'b','LineWidth',1.5);
    grid on; xlabel('Zeit [s]'); ylabel('Winkel [°]');
    legend('Rechts','Links'); title(['Hüftflexion / Extension - ' filename]);
end

%% --- HILFSFUNKTIONEN ---
function d = extractData(in)
    if iscell(in), d = cell2mat(in); else, d = in; end
end

function R = quat2rotm_manual(q)
    w = q(1); x = q(2); y = q(3); z = q(4);
    R = [1-2*(y^2+z^2), 2*(x*y - z*w), 2*(x*z + y*w);
         2*(x*y + z*w), 1-2*(x^2+z^2), 2*(y*z - x*w);
         2*(x*z - y*w), 2*(y*z + x*w), 1-2*(x^2 + y^2)];
end