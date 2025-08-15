classdef ExampleController < reg.mvc.BaseController
    %EXAMPLECONTROLLER Minimal controller demonstrating BaseController usage.
    %   Used in tests to exercise stub behavior.
    methods
        function obj = ExampleController(model, view)
            %EXAMPLECONTROLLER Construct example controller wiring model and view.
            obj@reg.mvc.BaseController(model, view);
        end
    end
end
