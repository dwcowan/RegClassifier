classdef Triplet
    %TRIPLET Data container for an anchor, positive and negative index.
    %   Mirrors the triplet structures produced by `reg.ft_build_contrastive_dataset`.
    %
    %   Example:
    %       t = reg.model.Triplet(1, 2, 3);
    %       disp(t.Anchor);   % -> 1
    %
    properties
        % Anchor — integer index of the anchor sample in the embedding matrix
        Anchor
        % Positive — integer index of the positive sample
        Positive
        % Negative — integer index of the negative sample
        Negative
    end
    methods
        function obj = Triplet(anchor, positive, negative)
            %TRIPLET Construct a contrastive triplet.
            %   OBJ = TRIPLET(anchor, positive, negative) creates a Triplet
            %   object with indices for anchor, positive and negative examples.
            %   Equivalent to triplet creation in `ft_build_contrastive_dataset`.
            if nargin > 0
                obj.Anchor = anchor;
                obj.Positive = positive;
                obj.Negative = negative;
            end
        end
    end
end
