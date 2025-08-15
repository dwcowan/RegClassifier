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
            %   OUT = PROCESS(obj, RAW) returns a struct with fields
            %   ``Documents``, ``Chunks`` and ``Features`` holding the
            %   processed artifacts.
            [features, ~] = obj.FeatureModel.process(raw.FeatRaw);
            out = struct('Documents', raw.Docs, ...
                        'Chunks', raw.Chunks, ...
                        'Features', features);
            reg.model.Document.save(raw.Docs);
        end
    end
end
