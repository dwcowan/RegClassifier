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

        function plotTrends(~, data) %#ok<INUSD>
            %PLOTTRENDS Visualise training metric trends.
            %   PLOTTRENDS(DATA) should plot accuracy and loss against
            %   training epochs using the fields of the supplied ``data``
            %   struct.

            arguments
                ~
                data struct
            end

            % Pseudocode:
            %   plot(data.epochs, [data.accuracy, data.loss])
            %   legend("Accuracy", "Loss")
            %   xlabel("Epoch")
            %   ylabel("Metric value")
            error("reg:view:NotImplemented", ...
                "PlotView.plotTrends is not implemented.");
        end
    end
end
