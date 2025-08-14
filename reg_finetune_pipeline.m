%REG_FINETUNE_PIPELINE Example entry point for encoder fine-tuning using MVC.
%   Instantiates FineTuneController with stub models and kicks off run().
function reg_finetune_pipeline()
    pdfModel = reg.model.PDFIngestModel();
    chunkModel = reg.model.TextChunkModel();
    weakModel = reg.model.WeakLabelModel();
    dataModel = reg.model.FineTuneDataModel();
    encoderModel = reg.model.EncoderFineTuneModel();
    evalModel = reg.model.EvaluationModel();
    view = reg.view.MetricsView();
    controller = reg.controller.FineTuneController(pdfModel, chunkModel, weakModel, ...
        dataModel, encoderModel, evalModel, view);
    controller.run();
end
