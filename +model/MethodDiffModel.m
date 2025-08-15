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

    function result = process(~, params) %#ok<INUSD>
      %PROCESS Execute method diffing and return results.
      %   RESULT = PROCESS(obj, params) should compare retrieval results
      %   across multiple embedding methods.
      %   Legacy Reference
      %       Equivalent to `reg.diff_methods`.
      %   Pseudocode:
      %       1. Embed queries using baseline and alternative encoders
      %       2. Retrieve Top-K results for each method
      %       3. Return struct summarising differences
      error("reg:model:NotImplemented", ...
        "MethodDiffModel.process is not implemented.");
    end
  end
end
