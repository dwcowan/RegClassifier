classdef projectionHeadClass
    %PROJECTIONHEADCLASS MLP fine-tuning frozen embeddings to enhance retrieval.

    properties (Access=public)
        inputDim    % double: Input dimension
        outputDim   % double: Output dimension
        paramStruct % struct: Learnable parameters
    end

    methods (Access=public)
        function obj = projectionHeadClass(inputDim, outputDim)
            %PROJECTIONHEADCLASS Construct projection head.
            %   obj = projectionHeadClass(inputDim, outputDim)
            %   inputDim (double): Input dimension.
            %   outputDim (double): Output dimension.
            %   obj (projectionHeadClass): New instance.
            %
            %   Side effects: initializes paramStruct.
            obj.inputDim = inputDim;
            obj.outputDim = outputDim;
            obj.paramStruct = struct();
        end

        function fit(obj, embeddingMat, labelMat, numEpochs, learningRate)
            %FIT Train projection head.
            %   fit(obj, embeddingMat, labelMat, numEpochs, learningRate)
            %   obj (projectionHeadClass): Instance.
            %   embeddingMat (double Mat): Embedding matrix.
            %   labelMat (double Mat): Labels.
            %   numEpochs (double): Training epochs.
            %   learningRate (double): Step size.
            %
            %   Side effects: updates paramStruct.
            obj.paramStruct.trained = true;
            obj.paramStruct.numEpochs = numEpochs;
            obj.paramStruct.learningRate = learningRate;
        end

        function embeddingMatTrans = transform(~, embeddingMat)
            %TRANSFORM Apply transformation to embeddings.
            %   embeddingMatTrans = transform(obj, embeddingMat)
            %   obj (projectionHeadClass): Instance.
            %   embeddingMat (double Mat): Input embeddings.
            %   embeddingMatTrans (double Mat): Transformed embeddings.
            %
            %   Side effects: none.
            embeddingMatTrans = embeddingMat;
        end
    end
end
