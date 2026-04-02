%% HAUPTSKRIPT: KOMBINIERTE ANALYSE (KNIE & HÜFTE)
clear; close all; clc;

% 1. Datei festlegen
dateiname = 'OBR_NV_run_section.mvnx';  

try
    %% 2. Analysen aufrufen
    %% Knie-Analyse
    dataKnie = Kneeflexion(dateiname); 
    
    %% Hüft-Analyse
    dataHuefte = Hipflexion(dateiname);


    %% Becken-Analyse
    dataBecken = Pelvisrotation(dateiname);

   


    %% 4. Zusammenfassung Konsole
    fprintf('\n=== ANALYSE ERFOLGREICH ===\n');
    fprintf('Datei: %s\n', excelName);
    fprintf('Hüfte Rechts: Max %.1f° / Min %.1f°\n', dataHuefte.maxR, dataHuefte.minR);
    fprintf('Knie Rechts:  ROM %.1f°\n', dataKnie.ROM_right);

catch ME
    fprintf('Fehler: %s\n', ME.message);
end