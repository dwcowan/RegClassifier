classdef EmbeddingView < reg.mvc.BaseView
    %EMBEDDINGVIEW Stub view for rendering embedding outputs.
    %   Expects DATA as a numeric matrix or a struct containing a field
    %   ``Vectors``. Rendering is limited to printing vector dimensions or
    %   persisting via callbacks; all computation remains within services.

    properties
        DisplayedEmbeddings

        % Optional callback executed after display ------------------------
        OnDisplayCallback
    end

    methods
        function display(~, data) %#ok<INUSD>
            %DISPLAY Present embedding data.
            %   DISPLAY(~, DATA) would report vector dimensions or forward
            %   embeddings to downstream visualisation tools.

            arguments
                ~
                data {mustBeA(data,{"double","struct"})}
            end

            % Pseudocode:
            %   if struct, extract embedding vectors
            %   else treat DATA as a numeric matrix of vectors
            %   render or summarise vector information
            error("reg:view:NotImplemented", ...
                "EmbeddingView.display is not implemented.");
        end
    end
end
