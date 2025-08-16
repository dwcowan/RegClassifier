classdef PlotView < reg.mvc.BaseView
    %PLOTVIEW Stub view for displaying plot artefacts like PNGs or figures.
    %   Expects DATA struct containing plot file paths or chart handles.

    properties
        DisplayedPlots

        % Optional callback executed after display ------------------------
        OnDisplayCallback
    end

    methods
        function display(~, data) %#ok<INUSD>
            %DISPLAY Present plot artefacts.
            %   DISPLAY(~, DATA) would embed plots into reports or open
            %   figures for inspection.

            arguments
                ~
                data struct
            end

            % Pseudocode:
            %   loop over fields in DATA referencing plot artefacts
            %   render or save each plot as required
            error("reg:view:NotImplemented", ...
                "PlotView.display is not implemented.");
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
