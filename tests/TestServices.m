classdef TestServices < fixtures.RegTestCase
    %TESTSERVICES Unit tests for service layer classes.
    %   Tests service classes in +reg/+service package for correct
    %   behavior, dependency injection, and error handling.

    methods (Test)
        function testConfigServiceInstantiation(tc)
            %TESTCONFIGSERVICEINSTANTIATION Test ConfigService creation.
            %   Verifies that ConfigService can be instantiated with and without a model.
            % Default instantiation
            svc1 = reg.service.ConfigService();
            tc.verifyNotEmpty(svc1, ...
                'ConfigService should instantiate with defaults');
            tc.verifyClass(svc1.ConfigModel, 'reg.model.ConfigModel', ...
                'Default ConfigModel should be created');

            % Instantiation with provided model
            mockModel = reg.model.ConfigModel();
            svc2 = reg.service.ConfigService(mockModel);
            tc.verifyEqual(svc2.ConfigModel, mockModel, ...
                'ConfigService should accept provided model');
        end

        function testConfigServiceGetConfig(tc)
            %TESTCONFIGSERVICEGETCONFIG Test configuration retrieval.
            %   Verifies that getConfig returns valid configuration struct.
            svc = reg.service.ConfigService();
            cfg = svc.getConfig();

            tc.verifyClass(cfg, 'struct', ...
                'getConfig should return a struct');
            tc.verifyTrue(isfield(cfg, 'labels'), ...
                'Config should have labels field');
            tc.verifyTrue(isfield(cfg, 'input_dir'), ...
                'Config should have input_dir field');
        end

        function testEmbeddingServiceInstantiation(tc)
            %TESTEMBEDDINGSERVICEINSTANTIATION Test EmbeddingService creation.
            %   Verifies that EmbeddingService handles dependency injection.
            % Default instantiation
            svc1 = reg.service.EmbeddingService();
            tc.verifyNotEmpty(svc1, ...
                'EmbeddingService should instantiate with defaults');

            % Instantiation with dependencies
            cfgSvc = reg.service.ConfigService();
            embRepo = reg.repository.DatabaseEmbeddingRepository();
            searchRepo = reg.repository.ElasticSearchIndexRepository();
            svc2 = reg.service.EmbeddingService(cfgSvc, embRepo, searchRepo);

            tc.verifyEqual(svc2.ConfigService, cfgSvc, ...
                'EmbeddingService should accept ConfigService dependency');
            tc.verifyEqual(svc2.EmbeddingRepo, embRepo, ...
                'EmbeddingService should accept EmbeddingRepo dependency');
            tc.verifyEqual(svc2.SearchRepo, searchRepo, ...
                'EmbeddingService should accept SearchRepo dependency');
        end

        function testEmbeddingServicePrepare(tc)
            %TESTEMBEDDINGSERVICEPREPARE Test EmbeddingInput preparation.
            %   Verifies that prepare wraps features in EmbeddingInput.
            svc = reg.service.EmbeddingService();
            features = randn(10, 50);  % sparse features

            input = svc.prepare(features);

            tc.verifyClass(input, 'reg.service.EmbeddingInput', ...
                'prepare should return EmbeddingInput object');
            tc.verifyEqual(input.features, features, ...
                'EmbeddingInput should contain the provided features');
        end

        function testEmbeddingServiceEmbedStub(tc)
            %TESTEMBEDDINGSERVICEEMBEDSTUB Test embed stub throws error.
            %   Verifies that embed method is properly stubbed.
            svc = reg.service.EmbeddingService();
            input = reg.service.EmbeddingInput(randn(5, 10));

            tc.verifyError(@() svc.embed(input), 'reg:service:NotImplemented', ...
                'embed should throw NotImplemented error');
        end

        function testIngestionServiceInstantiation(tc)
            %TESTINGESTIONSERVICEINSTANTIATION Test IngestionService creation.
            %   Verifies that IngestionService handles dependency injection.
            % Default instantiation
            svc1 = reg.service.IngestionService();
            tc.verifyNotEmpty(svc1, ...
                'IngestionService should instantiate with defaults');

            % Instantiation with dependencies
            pdfModel = reg.model.PDFIngestModel();
            chunkModel = reg.model.TextChunkModel();
            featModel = reg.model.FeatureModel();
            docRepo = reg.repository.FileSystemDocumentRepository();

            svc2 = reg.service.IngestionService(pdfModel, chunkModel, featModel, docRepo);

            tc.verifyEqual(svc2.PDFModel, pdfModel, ...
                'IngestionService should accept PDFModel dependency');
            tc.verifyEqual(svc2.ChunkModel, chunkModel, ...
                'IngestionService should accept ChunkModel dependency');
            tc.verifyEqual(svc2.FeatureModel, featModel, ...
                'IngestionService should accept FeatureModel dependency');
            tc.verifyEqual(svc2.DocumentRepo, docRepo, ...
                'IngestionService should accept DocumentRepo dependency');
        end

        function testIngestionServiceWithoutRepo(tc)
            %TESTINGESTIONSERVICEWITHOUTREPO Test IngestionService without repository.
            %   Verifies that IngestionService works without repository dependency.
            pdfModel = reg.model.PDFIngestModel();
            chunkModel = reg.model.TextChunkModel();
            featModel = reg.model.FeatureModel();

            svc = reg.service.IngestionService(pdfModel, chunkModel, featModel);

            tc.verifyEmpty(svc.DocumentRepo, ...
                'DocumentRepo should be empty when not provided');
        end

        function testEvaluationServiceInstantiation(tc)
            %TESTEVALUATIONSERVICEINSTANTIATION Test EvaluationService creation.
            %   Verifies that EvaluationService can be instantiated.
            svc = reg.service.EvaluationService();
            tc.verifyNotEmpty(svc, ...
                'EvaluationService should instantiate successfully');
        end

        function testDiffServiceInstantiation(tc)
            %TESTDIFFSERVICEINSTANTIATION Test DiffService creation.
            %   Verifies that DiffService can be instantiated.
            svc = reg.service.DiffService();
            tc.verifyNotEmpty(svc, ...
                'DiffService should instantiate successfully');
        end

        function testServiceValueObjects(tc)
            %TESTSERVICEVALUEOBJECTS Test value object creation.
            %   Verifies that service value objects can be instantiated.
            % EmbeddingInput
            features = randn(5, 10);
            embInput = reg.service.EmbeddingInput(features);
            tc.verifyEqual(embInput.features, features, ...
                'EmbeddingInput should store features');

            % EmbeddingOutput
            embeddings = randn(5, 20);
            embOutput = reg.service.EmbeddingOutput(embeddings);
            tc.verifyEqual(embOutput.embeddings, embeddings, ...
                'EmbeddingOutput should store embeddings');

            % IngestionOutput
            docsT = table(["doc1"], ["text1"], 'VariableNames', {'doc_id', 'text'});
            chunksT = table(["chunk1"], ["doc1"], ["chunk text"], ...
                'VariableNames', {'chunk_id', 'doc_id', 'text'});
            features = randn(1, 10);
            ingOutput = reg.service.IngestionOutput(docsT, chunksT, features);
            tc.verifyEqual(ingOutput.documents, docsT, ...
                'IngestionOutput should store documents');
            tc.verifyEqual(ingOutput.chunks, chunksT, ...
                'IngestionOutput should store chunks');
            tc.verifyEqual(ingOutput.features, features, ...
                'IngestionOutput should store features');
        end

        function testConfigServiceMultipleCalls(tc)
            %TESTCONFIGSERVICEMULTIPLECALLS Test repeated config retrieval.
            %   Verifies that getConfig can be called multiple times.
            svc = reg.service.ConfigService();

            cfg1 = svc.getConfig();
            cfg2 = svc.getConfig();

            tc.verifyEqual(cfg1.labels, cfg2.labels, ...
                'Multiple getConfig calls should return consistent labels');
            tc.verifyEqual(cfg1.input_dir, cfg2.input_dir, ...
                'Multiple getConfig calls should return consistent input_dir');
        end

        function testEmbeddingInputValidation(tc)
            %TESTEMBEDDINGINPUTVALIDATION Test EmbeddingInput with various inputs.
            %   Verifies that EmbeddingInput handles different feature matrices.
            % Dense features
            denseFeatures = randn(10, 50);
            input1 = reg.service.EmbeddingInput(denseFeatures);
            tc.verifyEqual(size(input1.features), [10, 50], ...
                'EmbeddingInput should store dense features correctly');

            % Sparse features
            sparseFeatures = sparse(randn(10, 50));
            input2 = reg.service.EmbeddingInput(sparseFeatures);
            tc.verifyClass(input2.features, 'double', ...
                'EmbeddingInput should handle sparse features');
        end

        function testEvaluationResultValueObject(tc)
            %TESTEVALUATIONRESULTVALUEOBJECT Test EvaluationResult creation.
            %   Verifies that EvaluationResult value object works correctly.
            metrics = struct('recall', 0.85, 'mAP', 0.72);
            result = reg.service.EvaluationResult(metrics);

            tc.verifyEqual(result.metrics, metrics, ...
                'EvaluationResult should store metrics');
        end

        function testEvaluationInputValueObject(tc)
            %TESTEVALUATIONINPUTVALUEOBJECT Test EvaluationInput creation.
            %   Verifies that EvaluationInput value object works correctly.
            embeddings = randn(10, 20);
            labels = false(10, 5);
            input = reg.service.EvaluationInput(embeddings, labels);

            tc.verifyEqual(input.embeddings, embeddings, ...
                'EvaluationInput should store embeddings');
            tc.verifyEqual(input.labels, labels, ...
                'EvaluationInput should store labels');
        end
    end
end
