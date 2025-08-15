classdef IngestionService
    %INGESTIONSERVICE Coordinate document ingestion and feature extraction.
    %   Composes lower level models for PDF ingestion, text chunking and
    %   feature computation. Exposes a single `ingest` method returning an
    %   `reg.service.IngestionOutput` value object so that upstream
    %   controllers do not depend on concrete model implementations.

    properties
        PDFModel  reg.model.PDFIngestModel
        ChunkModel reg.model.TextChunkModel
        FeatureModel reg.model.FeatureModel
        DocumentRepo reg.repository.DocumentRepository
    end

    methods
        function obj = IngestionService(pdfModel, chunkModel, featModel, docRepo)
            if nargin > 0
                obj.PDFModel = pdfModel;
                obj.ChunkModel = chunkModel;
                obj.FeatureModel = featModel;
            end
            if nargin > 3
                obj.DocumentRepo = docRepo;
            end
        end

        function out = ingest(obj, cfg)
            %INGEST Run ingestion workflow returning `IngestionOutput`.
            files = obj.PDFModel.load(cfg);
            docsT = obj.PDFModel.process(files);

            chunksRaw = obj.ChunkModel.load(docsT);
            chunksT = obj.ChunkModel.process(chunksRaw);

            featRaw = obj.FeatureModel.load(chunksT);
            [features, ~] = obj.FeatureModel.process(featRaw);

            out = reg.service.IngestionOutput(docsT, chunksT, features);
            if ~isempty(obj.DocumentRepo)
                obj.DocumentRepo.save(docsT);
            end
        end
    end
end

