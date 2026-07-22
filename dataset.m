close all;
clear;
clc;

rng(1);  % 재현 가능한 실험을 위한 난수 고정

%% Simulation parameters
SimTimes = 1e5;   % Monte Carlo 시뮬레이션 반복 횟수
NumData  = 1e5;   % 생성할 데이터 샘플 수

dataset = zeros(NumData, 11);

%% Fixed parameters
dSD = 1;          % Source-Destination 거리
pathloss = 1e3;   % 경로 손실 계수
beta = 2.7;       % 경로 손실 지수

for idx = 1:NumData

    %% 1. 시스템 파라미터 랜덤 생성
    M = randi([1, 4]);      % Source 수
    N = randi([1, 4]);      % Relay 수

    dSR = 0.2 + 0.6 * rand;     % Source-Relay 거리
    dSE = 1.0 + 1.0 * rand;     % Source-Eavesdropper 거리
    dRE = 1.0 + 1.0 * rand;     % Relay-Eavesdropper 거리
    dRD = max(0.1, abs(dSD - dSR));  % Relay-Destination 거리

    %% 2. 평균 채널 이득 계산
    lSR = pathloss / (dSR ^ beta);
    lSE = pathloss / (dSE ^ beta);
    lRD = pathloss / (dRD ^ beta);
    lRE = pathloss / (dRE ^ beta);

    %% 3. 송신 전력 및 보안 전송률 임계값 설정
    PS_dB = -20 + 50 * rand;   % Source 송신 전력 [dB]
    PR_dB = -20 + 50 * rand;   % Relay 송신 전력 [dB]

    PS = 10 ^ (PS_dB / 10);
    PR = 10 ^ (PR_dB / 10);

    Rth = 0.1 + 0.9 * rand;    % 목표 보안 전송률
    gth = 2 ^ (2 * Rth);       % 보안 임계값

    %% 4. Rayleigh 채널 생성
    hSmRn = zeros(SimTimes, N, M);
    hSmE  = zeros(SimTimes, M);
    hRnD  = zeros(SimTimes, N);
    hRnE  = zeros(SimTimes, N);

    for mm = 1:M
        for nn = 1:N
            hSmRn(:, nn, mm) = random('Rayleigh', sqrt(lSR / 2), [SimTimes, 1]);
        end
        hSmE(:, mm) = random('Rayleigh', sqrt(lSE / 2), [SimTimes, 1]);
    end

    for nn = 1:N
        hRnD(:, nn) = random('Rayleigh', sqrt(lRD / 2), [SimTimes, 1]);
        hRnE(:, nn) = random('Rayleigh', sqrt(lRE / 2), [SimTimes, 1]);
    end

    %% 5. 채널 이득 및 SNR 계산
    gSmRn = abs(hSmRn) .^ 2;
    gSmE  = abs(hSmE) .^ 2;
    gRnD  = abs(hRnD) .^ 2;
    gRnE  = abs(hRnE) .^ 2;

    snrSmRn = PS * gSmRn;
    snrSmE  = PS * gSmE;
    snrRnD  = PR * gRnD;
    snrRnE  = PR * gRnE;

    snrSmRnD = zeros(SimTimes, N, M);
    snrSmRnE = zeros(SimTimes, N, M);
    snrSmRb_e2e = zeros(SimTimes, M);

    %% 6. JOSRS 및 MRC 기반 종단 간 SNR 계산
    for mm = 1:M
        for nn = 1:N
            % Source-Relay-Destination 경로의 SNR
            snrSmRnD(:, nn, mm) = min(snrSmRn(:, nn, mm), snrRnD(:, nn));

            % 도청자 측 SNR: Source-Eavesdropper + Relay-Eavesdropper
            snrSmRnE(:, nn, mm) = snrSmE(:, mm) + snrRnE(:, nn);
        end

        % 각 Source에 대해 가장 좋은 Relay 선택
        snrSmRb_e2e(:, mm) = max((1 + snrSmRnD(:, :, mm)) ./ ...
                                 (1 + snrSmRnE(:, :, mm)), [], 2);
    end

    % 전체 Source 중 가장 좋은 Source-Relay 조합 선택
    snrSbRb_e2e = max(snrSmRb_e2e, [], 2);

    %% 7. SOP 계산
    SOP_JOSRS_MRC_sim = mean(snrSbRb_e2e < gth);

    %% 8. 하나의 데이터 샘플 저장
    dataset(idx, :) = [
        M, N, PS_dB, PR_dB, Rth, ...
        dSR, dSE, dRD, dRE, gth, SOP_JOSRS_MRC_sim
    ];

end

%% 9. 데이터셋 CSV 파일로 저장
writematrix(dataset, 'dataset.csv');
disp('dataset.csv 저장 완료');
