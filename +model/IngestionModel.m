classdef IngestionModel < reg.mvc.BaseModel
    %INGESTIONMODEL Coordinate document ingestion and feature extraction.

    properties
        PDFModel  reg.model.PDFIngestModel
        ChunkModel reg.model.TextChunkModel
        FeatureModel reg.model.FeatureModel
    end

    methods
        function obj = IngestionModel(pdfModel, chunkModel, featModel)
            if nargin > 0
                obj.PDFModel = pdfModel;
                obj.ChunkModel = chunkModel;
                obj.FeatureModel = featModel;
            end
        end

        function raw = load(obj, cfg)
            %LOAD Run ingestion workflow returning intermediate results.
            files = obj.PDFModel.load(cfg);
            docsT = obj.PDFModel.process(files);

            chunksRaw = obj.ChunkModel.load(docsT);
            chunksT = obj.ChunkModel.process(chunksRaw);

            featRaw = obj.FeatureModel.load(chunksT);
            raw = struct('Docs', docsT, 'Chunks', chunksT, 'FeatRaw', featRaw);
        end

        function out = process(obj, raw)
            %PROCESS Finalise features and optionally persist documents.
            [features, ~] = obj.FeatureModel.process(raw.FeatRaw);
            out = reg.service.IngestionOutput(raw.Docs, raw.Chunks, features);
            reg.model.Document.save(raw.Docs);
        end
    end
end
