classdef TestRepositories < fixtures.RegTestCase
    %TESTREPOSITORIES Tests for repository layer classes.
    %   Tests repository interfaces and stub implementations to verify
    %   proper error handling and API contracts.

    methods (Test)
        function testFileSystemDocumentRepositoryStubs(tc)
            %TESTFILESYSTEMDOCUMENTREPOSITORYSTUBS Test FileSystemDocumentRepository stubs.
            %   Verifies that stub methods throw NotImplemented errors.
            repo = reg.repository.FileSystemDocumentRepository();

            % Test save stub
            tc.verifyError(@() repo.save(table()), 'reg:repository:NotImplemented', ...
                'save should throw NotImplemented error');

            % Test load stub
            tc.verifyError(@() repo.load(["doc1"]), 'reg:repository:NotImplemented', ...
                'load should throw NotImplemented error');

            % Test query stub
            tc.verifyError(@() repo.query('key', 'value'), 'reg:repository:NotImplemented', ...
                'query should throw NotImplemented error');
        end

        function testFileSystemDocumentRepositoryIsA(tc)
            %TESTFILESYSTEMDOCUMENTREPOSITORYISA Test inheritance.
            %   Verifies that FileSystemDocumentRepository extends DocumentRepository.
            repo = reg.repository.FileSystemDocumentRepository();
            tc.verifyTrue(isa(repo, 'reg.repository.DocumentRepository'), ...
                'FileSystemDocumentRepository should extend DocumentRepository');
        end

        function testDatabaseEmbeddingRepositoryStubs(tc)
            %TESTDATABASEEMBEDDINGREPOSITORYSTUBS Test DatabaseEmbeddingRepository stubs.
            %   Verifies that stub methods throw NotImplemented errors.
            repo = reg.repository.DatabaseEmbeddingRepository();

            % Test save stub
            tc.verifyError(@() repo.save([]), 'reg:repository:NotImplemented', ...
                'save should throw NotImplemented error');

            % Test load stub
            tc.verifyError(@() repo.load(["emb1"]), 'reg:repository:NotImplemented', ...
                'load should throw NotImplemented error');

            % Test query stub
            tc.verifyError(@() repo.query('key', 'value'), 'reg:repository:NotImplemented', ...
                'query should throw NotImplemented error');
        end

        function testDatabaseEmbeddingRepositoryIsA(tc)
            %TESTDATABASEEMBEDDINGREPOSITORYISA Test inheritance.
            %   Verifies that DatabaseEmbeddingRepository extends EmbeddingRepository.
            repo = reg.repository.DatabaseEmbeddingRepository();
            tc.verifyTrue(isa(repo, 'reg.repository.EmbeddingRepository'), ...
                'DatabaseEmbeddingRepository should extend EmbeddingRepository');
        end

        function testElasticSearchIndexRepositoryStubs(tc)
            %TESTELASTICSEARCHINDEXREPOSITORYSTUBS Test ElasticSearchIndexRepository stubs.
            %   Verifies that stub methods throw NotImplemented errors.
            repo = reg.repository.ElasticSearchIndexRepository();

            % Test save stub
            tc.verifyError(@() repo.save([]), 'reg:repository:NotImplemented', ...
                'save should throw NotImplemented error');

            % Test load stub
            tc.verifyError(@() repo.load(["idx1"]), 'reg:repository:NotImplemented', ...
                'load should throw NotImplemented error');

            % Test search stub
            tc.verifyError(@() repo.search("query"), 'reg:repository:NotImplemented', ...
                'search should throw NotImplemented error');
        end

        function testElasticSearchIndexRepositoryIsA(tc)
            %TESTELASTICSEARCHINDEXREPOSITORYISA Test inheritance.
            %   Verifies that ElasticSearchIndexRepository extends SearchIndexRepository.
            repo = reg.repository.ElasticSearchIndexRepository();
            tc.verifyTrue(isa(repo, 'reg.repository.SearchIndexRepository'), ...
                'ElasticSearchIndexRepository should extend SearchIndexRepository');
        end

        function testRepositoryErrorMessages(tc)
            %TESTREPOSITORYERRORMESSAGES Test error message content.
            %   Verifies that error messages are descriptive and identify the method.
            repo = reg.repository.FileSystemDocumentRepository();

            try
                repo.save(table());
                tc.verifyFail('Expected NotImplemented error');
            catch ME
                tc.verifyTrue(contains(ME.message, 'FileSystemDocumentRepository'), ...
                    'Error message should identify the repository class');
                tc.verifyTrue(contains(ME.message, 'save'), ...
                    'Error message should identify the method');
                tc.verifyTrue(contains(ME.message, 'not implemented'), ...
                    'Error message should indicate method is not implemented');
            end
        end

        function testRepositoryInstantiation(tc)
            %TESTREPOSITORYINSTANTIATION Test repository instantiation.
            %   Verifies that all concrete repository classes can be instantiated.
            repos = {
                reg.repository.FileSystemDocumentRepository(), ...
                reg.repository.DatabaseEmbeddingRepository(), ...
                reg.repository.ElasticSearchIndexRepository()
            };

            for i = 1:numel(repos)
                tc.verifyNotEmpty(repos{i}, ...
                    sprintf('Repository %d should instantiate successfully', i));
                tc.verifyClass(repos{i}, 'handle', ...
                    'Repository should be a handle class');
            end
        end

        function testRepositoryMethodsExist(tc)
            %TESTREPOSITORYMETHODSEXIST Test required methods exist.
            %   Verifies that repositories implement required interface methods.
            docRepo = reg.repository.FileSystemDocumentRepository();
            tc.verifyTrue(ismethod(docRepo, 'save'), ...
                'DocumentRepository should have save method');
            tc.verifyTrue(ismethod(docRepo, 'load'), ...
                'DocumentRepository should have load method');
            tc.verifyTrue(ismethod(docRepo, 'query'), ...
                'DocumentRepository should have query method');

            embRepo = reg.repository.DatabaseEmbeddingRepository();
            tc.verifyTrue(ismethod(embRepo, 'save'), ...
                'EmbeddingRepository should have save method');
            tc.verifyTrue(ismethod(embRepo, 'load'), ...
                'EmbeddingRepository should have load method');
            tc.verifyTrue(ismethod(embRepo, 'query'), ...
                'EmbeddingRepository should have query method');

            idxRepo = reg.repository.ElasticSearchIndexRepository();
            tc.verifyTrue(ismethod(idxRepo, 'save'), ...
                'SearchIndexRepository should have save method');
            tc.verifyTrue(ismethod(idxRepo, 'load'), ...
                'SearchIndexRepository should have load method');
            tc.verifyTrue(ismethod(idxRepo, 'search'), ...
                'SearchIndexRepository should have search method');
        end
    end
end
