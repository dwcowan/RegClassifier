classdef Triplet
    %TRIPLET Represents an anchor, positive, negative indices for contrastive learning.
    properties
        Anchor
        Positive
        Negative
    end
    methods
        function obj = Triplet(anchor, positive, negative)
            %TRIPLET Construct a contrastive triplet.
            %   OBJ = TRIPLET(anchor, positive, negative) creates a
            %   Triplet object with indices for anchor, positive and
            %   negative examples. Equivalent to triplet creation in
            %   `ft_build_contrastive_dataset`.
            if nargin > 0
                obj.Anchor = anchor;
                obj.Positive = positive;
                obj.Negative = negative;
            end
        end
    end
end
