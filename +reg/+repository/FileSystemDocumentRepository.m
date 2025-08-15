classdef FileSystemDocumentRepository < reg.repository.DocumentRepository
    %FILESYSTEMDOCUMENTREPOSITORY Stub file system implementation.
    methods
        function save(~, documents) %#ok<INUSD>
            error("reg:repository:NotImplemented", ...
                "FileSystemDocumentRepository.save is not implemented.");
        end
        function documents = load(~, ids) %#ok<INUSD>
            error("reg:repository:NotImplemented", ...
                "FileSystemDocumentRepository.load is not implemented.");
        end
        function result = query(~, varargin) %#ok<INUSD>
            error("reg:repository:NotImplemented", ...
                "FileSystemDocumentRepository.query is not implemented.");
        end
    end
end
