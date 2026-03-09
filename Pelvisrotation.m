function [results] = Pelvisrotation(filename)
    %% 1. Daten laden
    tree = load_mvnx(filename);

    %% 2. Samplerate bestimmen
    frameRateRaw = tree.metaData.subject_frameRate;
    if iscell(frameRateRaw), fs = str2double(frameRateRaw{1});
    else, fs = str2double(frameRateRaw); end
    dt = 1/fs;

    %% 3. Beckendaten extrahieren
    pelvisIdx = 1;
    qP = tree.segmentData(pelvisIdx).orientation;
    if iscell(qP), qP = cell2mat(qP); end

    nFrames = size(qP, 1);
    time = (0:nFrames-1) * dt;
    rotationRaw = zeros(nFrames, 1);

    %% 4. Roh-Rotation berechnen
    for i = 1:nFrames
        R = quat2rotm_manual(qP(i,:));
        % Wir nutzen atan2 für die Rotation um die Vertikale
        rotationRaw(i) = atan2d(R(2,1), R(1,1)); 
    end

    %% 5. GLÄTTUNG & KORREKTUR (Wichtig!)
    % 'unwrap' entfernt die 360-Grad Sprünge
    % Da unwrap mit Radian arbeitet, wandeln wir kurz um und zurück
    rotationContinuous = rad2deg(unwrap(deg2rad(rotationRaw)));

    % Offset korrigieren: Alles relativ zum ersten Frame (Beginn bei 0 Grad)
    rotationFinal = rotationContinuous - rotationContinuous(1);

    %% 6. Ergebnisse
    results.time = time;
    results.pelvisRotation = rotationFinal;
    results.ROM = max(rotationFinal) - min(rotationFinal);

    %% 7. Plot
    figure('Name',['Beckenrotation korrigiert: ' filename],'Color','w');
    plot(time, rotationFinal, 'g', 'LineWidth', 1.5);
    grid on; xlabel('Zeit [s]'); ylabel('Relative Rotation [°]');
    title(['Gereinigte Beckenrotation - ' filename]);
end

function R = quat2rotm_manual(q)
    w = q(1); x = q(2); y = q(3); z = q(4);
    R = [1-2*(y^2+z^2), 2*(x*y - z*w), 2*(x*z + y*w);
         2*(x*y + z*w), 1-2*(x^2+z^2), 2*(y*z - x*w);
         2*(x*z - y*w), 2*(y*z + x*w), 1-2*(x^2 + y^2)];
end