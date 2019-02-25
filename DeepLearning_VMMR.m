convnet = alexnet;
convnet.Layers % Take a look at the layers

%---Train----
%Set up training data

rootFolder = 'test_data';
categories = {'audi_a4','bmw3','bmw5_new','citroen_ax'};
imds = imageDatastore(fullfile(rootFolder, categories), 'LabelSource', 'foldernames');
imds.ReadFcn = @readFunctionTrain;

% Change the number 50 to as many training images as you would like to use
% how does increasing the number of images change the 
% accuracy of the classifier?
[trainingSet, ~] = splitEachLabel(imds, 10, 'randomize'); 


%Extract features from the training set images
featureLayer = 'fc7';
trainingFeatures = activations(convnet, trainingSet, featureLayer);
%Train the SVM classifier
classifier = fitcnb(trainingFeatures, trainingSet.Labels);


%-----Test-------
%Set up test data
rootFolder = 'test_data';
testSet = imageDatastore(fullfile(rootFolder, categories), 'LabelSource', 'foldernames');
testSet.ReadFcn = @readFunctionTrain;

%Extract features from the test set images, and test SVM classifer
testFeatures = activations(convnet, testSet, featureLayer);
predictedLabels = predict(classifier, testFeatures);

%Determine overall accuracy
confMat = confusionmat(testSet.Labels, predictedLabels);
confMat = confMat./sum(confMat,2);
mean(diag(confMat))