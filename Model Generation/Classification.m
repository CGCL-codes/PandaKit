function net = Classification(XTrain, YTrain, XTest, YTest)
%Train and test classification model
%Input: Train data, Train data label, Test data, Test data label
%Output: Trained neural networks

%     numObservations = numel(XTrain);
%     for i=1:numObservations
%         sequence = XTrain{i};
%         sequenceLengths(i) = size(sequence,2);
%     end
%     
%     [sequenceLengths,idx] = sort(sequenceLengths);
%     XTrain = XTrain(idx);
%     YTrain = YTrain(idx);
%     
%     figure;
%     bar(sequenceLengths);
%     ylim([0 30]);
%     xlabel("Sequence");
%     ylabel("Length");
%     title("Sorted Data");

    inputSize = length(XTrain(:,1));
    numHiddenUnits = 100;
    numClasses = numel(unique(YTrain));

    layers = [ ...                  %Combining different layers according to different situation
        sequenceInputLayer(inputSize)
        bilstmLayer(numHiddenUnits,'OutputMode','last')
        fullyConnectedLayer(numClasses)
        softmaxLayer
        classificationLayer];
    
    maxEpochs = 100;
    miniBatchSize = 27;

    options = trainingOptions('adam', ...           %Modifing parameters according to your requirement
        'ExecutionEnvironment','cpu', ...
        'GradientThreshold',1, ...
        'MaxEpochs',maxEpochs, ...
        'MiniBatchSize',miniBatchSize, ...
        'SequenceLength','longest', ...
        'Shuffle','never', ...
        'Verbose',0, ...
        'Plots','training-progress');
    
    net = trainNetwork(XTrain,YTrain,layers,options);
    
    miniBatchSize = 27;
    YPred = classify(net,XTest, ...
        'MiniBatchSize',miniBatchSize, ...
        'SequenceLength','longest');
    
    acc = sum(YPred == YTest)./numel(YTest);
end

