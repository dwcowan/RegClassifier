classdef Pair
    %PAIR Represents a pair of indices and label for contrastive learning.
    properties
        A
        B
        Label
    end
    methods
        function obj = Pair(a, b, label)
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
