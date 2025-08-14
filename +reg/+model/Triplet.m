classdef Triplet
    %TRIPLET Represents an anchor, positive, negative indices for contrastive learning.
    properties
        Anchor
        Positive
        Negative
    end
    methods
        function obj = Triplet(anchor, positive, negative)
            if nargin > 0
                obj.Anchor = anchor;
                obj.Positive = positive;
                obj.Negative = negative;
            end
        end
    end
end
