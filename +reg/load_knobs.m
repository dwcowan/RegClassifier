function K = load_knobs(jsonPath)
%LOAD_KNOBS Load knobs from a JSON file (default 'knobs.json' at project root)
if nargin<1, jsonPath = "knobs.json"; end
if isfile(jsonPath)
    try
        raw = fileread(jsonPath);
        K = jsondecode(raw);
    catch ME
        warning("Failed to parse knobs.json: %s", ME.message);
        K = struct();
    end
else
    K = struct();
end
end
