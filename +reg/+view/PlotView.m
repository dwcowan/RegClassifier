classdef PlotView < reg.mvc.BaseView
    %PLOTVIEW Stub view for displaying plot artefacts like PNGs or figures.
    %   Expects DATA struct containing plot file paths or chart handles.

    properties
        DisplayedPlots

        % Optional callback executed after display ------------------------
        OnDisplayCallback
    end

    methods
        function display(obj, data)
            %DISPLAY Store plot references and optionally print paths.
            %   DISPLAY(obj, DATA) captures plot artefacts for verification.
            %   A real implementation might embed images into reports or
            %   open figures interactively.

            obj.DisplayedPlots = data;
            if isstruct(data)
                fns = fieldnames(data);
                for i = 1:numel(fns)
                    val = data.(fns{i});
                    if ischar(val) || isstring(val)
                        fprintf('Plot saved to %s\n', string(val));
                    end
                end
            end
            if ~isempty(obj.OnDisplayCallback)
                obj.OnDisplayCallback(data);
            end
        end
    end
end
