classdef ExampleController < reg.mvc.BaseController
    %EXAMPLECONTROLLER Orchestrates ExampleModel and ExampleView.

    methods
        function obj = ExampleController(model, view)
            obj@reg.mvc.BaseController(model, view);
        end
        function run(obj)
            data = obj.Model.load();
            result = obj.Model.process(data);
            obj.View.display(result);
        end
    end
end
