clc;
clear;
close all;

%% 1. 데이터 불러오기
data = readmatrix('dataset.csv');

X = data(:, 1:end-1);   
Y = data(:, end);     

%% 2. 학습 데이터와 테스트 데이터 분리
rng(1);

cv = cvpartition(size(X, 1), 'HoldOut', 0.2);

idxTrain = training(cv);   
idxTest  = test(cv);       

X_train = X(idxTrain, :);
X_test  = X(idxTest, :);

Y_train = Y(idxTrain, :);
Y_test  = Y(idxTest, :);

%% 3. 입력 데이터 정규화
mu = mean(X_train, 1);
sigma = std(X_train, 0, 1);

sigma(sigma == 0) = 1;

X_train = (X_train - mu) ./ sigma;
X_test  = (X_test  - mu) ./ sigma;

%% 4. SOP 출력값 로그 변환
eps_val = 1e-4;

Y_train_log = log10(Y_train + eps_val);
Y_test_log = log10(Y_test + eps_val);

%% 5. DNN 회귀 모델 구조 정의
inputSize = size(X_train, 2);

layers = [
    featureInputLayer(inputSize, 'Name', 'input')

    fullyConnectedLayer(128, 'Name', 'layer1')
    reluLayer('Name', 'relu1')

    fullyConnectedLayer(64, 'Name', 'layer2')
    reluLayer('Name', 'relu2')

    fullyConnectedLayer(32, 'Name', 'layer3')
    reluLayer('Name', 'relu3')

    fullyConnectedLayer(1, 'Name', 'output')

    regressionLayer('Name', 'regression')
    ];

%% 6. 학습 옵션 설정
options = trainingOptions('adam', ...
    'InitialLearnRate', 0.001, ...
    'MiniBatchSize', 32, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', {X_test, Y_test_log}, ...
    'Plots', 'training-progress', ...
    'Verbose', true);

%% 7. 모델 학습
net = trainNetwork(X_train, Y_train_log, layers, options);

%% 8. SOP 예측
Y_pred_log = predict(net, X_test);

Y_pred = 10.^Y_pred_log - eps_val;

Y_pred = max(0, min(1, Y_pred));

%% 9. 성능 평가
mseValue = mean((Y_test - Y_pred).^2);
maeValue = mean(abs(Y_test - Y_pred));

fprintf('Test MSE: %.6f\n', mseValue);
fprintf('Test MAE: %.6f\n', maeValue);

%% 10. 학습된 모델 저장
save('final_model.mat', 'net', 'mu', 'sigma');

%% 11. 실제값과 예측값 비교 시각화
figure;
scatter(Y_test, Y_pred, 'filled');
hold on;

% y = x 기준선을 표시한다.
plot([min(Y_test), max(Y_test)], ...
     [min(Y_test), max(Y_test)], ...
     'r--', 'LineWidth', 2);

xlabel('Actual Value (True)');
ylabel('Predicted Value');
title('Actual vs Predicted');
grid on;
axis equal;

legend('Prediction', 'Ideal (y = x)');
