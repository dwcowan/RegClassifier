classdef projectionHeadControllerClass
    %PROJECTIONHEADCONTROLLERCLASS Manages projection head training and usage.

    methods (Access=public)
        function head = trainHead(~, embeddingMat, labelMat, numEpochs, learningRate)
            %TRAINHEAD Instantiate and fit projection head.
            %   head = trainHead(obj, embeddingMat, labelMat, numEpochs, learningRate)
            %   embeddingMat (double Mat): Embeddings.
            %   labelMat (double Mat): Labels.
            %   numEpochs (double): Training epochs.
            %   learningRate (double): Step size.
            %   head (projectionHeadClass): Fitted head.
            %
            %   Side effects: none.
            inputDim = size(embeddingMat, 2);
            outputDim = size(labelMat, 2);
            head = model.projectionHeadClass(inputDim, outputDim);
            head.fit(embeddingMat, labelMat, numEpochs, learningRate);
        end

        function embeddingMatTrans = applyHead(~, projectionHead, embeddingMat)
            %APPLYHEAD Apply projection head to embeddings.
            %   embeddingMatTrans = applyHead(obj, projectionHead, embeddingMat)
            %   projectionHead (projectionHeadClass): Head to apply.
            %   embeddingMat (double Mat): Embeddings.
            %   embeddingMatTrans (double Mat): Transformed embeddings.
            %
            %   Side effects: none.
            embeddingMatTrans = projectionHead.transform(embeddingMat);
        end
    end
end
