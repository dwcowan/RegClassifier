classdef (Abstract) DocumentRepository
    %DOCUMENTREPOSITORY Interface for document persistence.
    methods (Abstract)
        save(obj, documents)
        documents = load(obj, ids)
        result = query(obj, varargin)
    end
end
