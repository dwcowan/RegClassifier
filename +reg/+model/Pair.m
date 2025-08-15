classdef Pair
    %PAIR Data container for a sample index pair with optional label.
    %   Mirrors the pair structures produced by `reg.build_pairs` and consumed
    %   by projection head training.
    %
    %   Example:
    %       p = reg.model.Pair(10, 20, 1);
    %       disp(p.Label);   % -> 1
    %
    properties
        % A — integer index of the first sample
        A
        % B — integer index of the second sample
        B
        % Label — optional numeric relationship label (e.g., 1 for positive)
        Label
    end
    methods
        function obj = Pair(a, b, label)
            %PAIR Construct a contrastive pair.
            %   OBJ = PAIR(a, b, label) creates a pair of indices A and B
            %   with optional label. Equivalent to pair creation in
            %   `build_pairs`.
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
