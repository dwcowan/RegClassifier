classdef CoRetrievalMatrixModel < reg.mvc.BaseModel
    %CORETRIEVALMATRIXMODEL Compute label co-retrieval matrix.
    %   Wraps legacy reg.label_coretrieval_matrix in MVC-style model
    %   providing load and process steps for pipeline integration.

    properties (Access = private)
        LabelMatrix logical = logical([]); % stored label assignments
    end

    methods
        function [labelMatrix, order] = load(obj, chunks, labels)
            %LOAD Prepare logical label matrix.
            %   [labelMatrix, order] = LOAD(obj, chunks, labels) converts the
            %   provided label assignments to a logical matrix and stores it
            %   for subsequent processing.  "chunks" is used only for size
            %   validation.
            %
            %   Inputs
            %       chunks - table or array with N rows representing items.
            %       labels - N x L logical or numeric matrix of labels.
            %   Outputs
            %       labelMatrix - N x L logical matrix mapping chunks to labels.
            %       order       - 1 x L numeric index vector for label columns.

            % Determine number of rows in chunks for validation
            if istable(chunks)
                n = height(chunks);
            else
                n = size(chunks, 1);
            end
            labelMatrix = logical(labels);
            if size(labelMatrix,1) ~= n
                error('reg:model:CoRetrievalMatrixModel:SizeMismatch', ...
                      'Labels must have %d rows to match chunks, found %d.', ...
                      n, size(labelMatrix,1));
            end
            obj.LabelMatrix = labelMatrix;
            order = 1:size(labelMatrix,2);
        end

        function [M, order] = process(obj, embeddings, k)
            %PROCESS Compute label co-retrieval matrix.
            %   [M, order] = PROCESS(obj, embeddings, k) computes the
            %   co-retrieval matrix using stored labels and the supplied
            %   normalized embeddings.  The implementation delegates to the
            %   legacy REG.LABEL_CORETRIEVAL_MATRIX function.
            %
            %   Inputs
            %       embeddings - N x D normalized embedding vectors.
            %       k          - scalar top-K neighbour count.
            %   Outputs
            %       M     - L x L matrix where rows sum to 1.
            %       order - 1 x L numeric label index vector.

            if isempty(obj.LabelMatrix)
                error('reg:model:CoRetrievalMatrixModel:NoLabels', ...
                      'Call load() with label data before process().');
            end
            [M, order] = reg.label_coretrieval_matrix(embeddings, obj.LabelMatrix, k);
        end
    end
end

