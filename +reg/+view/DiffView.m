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
        function display(obj, data)
            %DISPLAY Store diff data for inspection.
            %   DISPLAY(obj, DATA) retains diff structures for verification.
            %   In a production setting this method might pretty-print
            %   summaries or write patch files to disk.

            obj.DiffResult = data;
            if ~isempty(obj.OnDisplayCallback)
                obj.OnDisplayCallback(data);
            end
        end
    end
end
