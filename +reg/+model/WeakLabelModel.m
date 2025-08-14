classdef WeakLabelModel < reg.mvc.BaseModel
    %WEAKLABELMODEL Stub model generating weak supervision labels.

    properties
        % Configuration for weak labeling
        config
    end

    methods
        function obj = WeakLabelModel(config)
            %WEAKLABELMODEL Construct weak labeling model.
            %   OBJ = WEAKLABELMODEL(config) stores rules configuration.
            %   Equivalent to initialization in `weak_rules`.
            if nargin > 0
                obj.config = config;
            end
        end

        function chunksT = load(~, varargin) %#ok<INUSD>
            %LOAD Retrieve chunks for weak labeling.
            %   CHUNKST = LOAD(obj) gathers text segments to label.
            %   Equivalent to `weak_rules` input preparation.
            error("reg:model:NotImplemented", ...
                "WeakLabelModel.load is not implemented.");
        end
        function [Yweak, Yboot] = process(~, chunksT) %#ok<INUSD>
            %PROCESS Generate weak labels and bootstrapped sets.
            %   [YWEAK, YBOOT] = PROCESS(obj, chunksT) returns matrices of
            %   labels. Equivalent to `weak_rules`.
            error("reg:model:NotImplemented", ...
                "WeakLabelModel.process is not implemented.");
        end
    end
end
