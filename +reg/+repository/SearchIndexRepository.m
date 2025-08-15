classdef (Abstract) SearchIndexRepository
    %SEARCHINDEXREPOSITORY Interface for search index persistence.
    methods (Abstract)
        save(obj, index)
        index = load(obj, ids)
        result = query(obj, varargin)
    end
end
