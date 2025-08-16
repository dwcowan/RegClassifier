classdef DiffView < reg.mvc.BaseView
    %DIFFVIEW Stub view for presenting diff results between corpora or methods.
    %   Expects DATA representing domain differences such as tables, structs
    %   or file paths. Controllers like CorpusController forward diff results
    %   here for rendering or persistence.

    properties
        DiffResult

        % Optional callback executed after display ------------------------
        OnDisplayCallback
    end

    methods
        function display(~, data) %#ok<INUSD>
            %DISPLAY Present diff data.
            %   DISPLAY(~, DATA) would render differences between corpora
            %   or methods, for example by printing tables or writing patch
            %   files to disk.

            arguments
                ~
                data struct
            end

            % Pseudocode:
            %   iterate over diff entries in ``data``
            %   render each difference to the desired medium
            error("reg:view:NotImplemented", ...
                "DiffView.display is not implemented.");
        end
    end
end
