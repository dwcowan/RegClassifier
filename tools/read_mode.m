function mode = read_mode()
%READ_MODE Return repo mode from contexts/mode.json (default 'clean-room').
    repoRoot = fileparts(mfilename('fullpath')); repoRoot = fileparts(repoRoot);
    modeFile = fullfile(repoRoot, 'contexts', 'mode.json');
    mode = "clean-room";
    try
        if isfile(modeFile)
            data = jsondecode(fileread(modeFile));
            if isfield(data,'mode')
                mode = string(data.mode);
            end
        end
    catch
        % default remains 'clean-room'
    end
end
