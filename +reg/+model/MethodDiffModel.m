classdef MethodDiffModel < reg.mvc.BaseModel
  %METHODDIFFMODEL Compare Top-K retrievals across encoder variants.
  %   Wraps the `reg.diff_methods` function exposing `load` and `process`
  %   hooks for controllers.

  methods
    function params = load(~, queries, chunksT, config)
      %LOAD Prepare parameters for method comparison.
      %   PARAMS = LOAD(obj, queries, chunksT, config) stores the query
      %   strings, chunk table and configuration struct. CONFIG may be
      %   omitted and defaults to an empty struct.
      if nargin < 4
        config = struct();
      end
      params = struct('queries', queries, 'chunksT', chunksT, ...
        'config', config);
    end

    function result = process(~, params)
      %PROCESS Execute method diffing and return results.
      %   RESULT = PROCESS(obj, params) delegates to `reg.diff_methods`
      %   using the previously loaded parameters and returns the
      %   comparison struct.
      result = reg.diff_methods(params.queries, params.chunksT, ...
        params.config);
    end
  end
end
