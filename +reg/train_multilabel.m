function models = train_multilabel(X, Yboot, kfold)
%TRAIN_MULTILABEL One-vs-rest logistic models with CV calibration
labelsK = size(Yboot,2);
models = cell(labelsK,1);
parfor j = 1:labelsK
    y = logical(Yboot(:,j));
    if nnz(y) < 3
        models{j} = [];
        continue
    end
    models{j} = fitclinear(X, y, 'Learner','logistic', ...
        'ObservationsIn','rows', 'KFold', kfold, 'ClassNames',[false true]);
end
end
