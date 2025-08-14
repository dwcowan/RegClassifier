classdef Pair
    %PAIR Represents a pair of indices and label for contrastive learning.
    properties
        A
        B
        Label
    end
    methods
        function obj = Pair(a, b, label)
            %PAIR Construct a contrastive pair.
            %   OBJ = PAIR(a, b, label) creates a pair of indices A and B
            %   with optional label. Returns a reg.model.Pair instance.
            %   Equivalent to pair creation in `build_pairs`.
            if nargin > 0
                obj.A = a;
                obj.B = b;
                if nargin > 2
                    obj.Label = label;
                end
            end
        end
    end
end
