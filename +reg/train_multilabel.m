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
    % Use stratified partition to handle class imbalance in binary labels
    cp = cvpartition(y, 'KFold', kfold, 'Stratify', true);
    models{j} = fitclinear(X, y, 'Learner','logistic', ...
        'ObservationsIn','rows', 'CVPartition', cp, 'ClassNames',[false true]);
end
end
