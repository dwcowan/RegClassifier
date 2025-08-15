classdef EmbeddingView < reg.mvc.BaseView
    %EMBEDDINGVIEW Stub view for rendering embedding outputs.
    %   Expects DATA as a numeric matrix or reg.service.EmbeddingOutput.
    %   Rendering is limited to printing vector dimensions or persisting
    %   via callbacks; all computation remains within services.

    properties
        DisplayedEmbeddings

        % Optional callback executed after display ------------------------
        OnDisplayCallback
    end

    methods
        function display(obj, data)
            %DISPLAY Store embedding data for inspection.
            %   DISPLAY(obj, DATA) retains embedding vectors and reports
            %   their dimensions. In production this might serialise
            %   embeddings or send them to a visualiser.

            obj.DisplayedEmbeddings = data;
            vecs = [];
            if isa(data, 'reg.service.EmbeddingOutput')
                vecs = data.Vectors;
            elseif isnumeric(data)
                vecs = data;
            end
            if ~isempty(vecs)
                fprintf('Embeddings: %d-by-%d matrix\n', size(vecs,1), size(vecs,2));
            end
            if ~isempty(obj.OnDisplayCallback)
                obj.OnDisplayCallback(data);
            end
        end
    end
end
