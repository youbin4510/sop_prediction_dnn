# sop_prediction_dnn
Deep learning-based SOP prediction model for cooperative communication networks

# 딥러닝 기반 SOP 예측 모델

## 연구 개요
본 연구는 멀티 유저·멀티 릴레이 협력 통신 네트워크에서 물리계측 보안 성능 지표인 SOP(Secrecy Outage Probability)를 딥러닝 모델로 예측하는 것을 목표로 한다.
기존 Monte Carlo 시뮬레이션은 높은 정확도를 제공하지만, 반복 계산이 필요하여 시간이 오래 걸리다는 한계가 있다. 본 연구에서는 시뮬레이션 데이터를 기반으로 딥러닝 모델을 학습시켜 SOP를 빠르게 예측하는 접근을 수행하였다.

## 연구 목표
- 협력 통신 네트워크의 SOP 예측
- 시뮬레이션 기반 데이터셋 생성
- 딥러닝 회귀 모델 구성
- Monte Carlo 시뮬레이션 결과와 딥러닝 예측 결과 비교
- 반복 시뮬레이션 계산 부담을 줄이는 AI 기반 예측

## 시스템 개요
본 연구에서는 다수의 소스 사용자와 다수의 릴레이가 존재하는 협력 통신 네트워크를 고려하였다.
도청자가 존재하는 환경에서 보안 성능을 평가하기 위해 SOP를 성능 지쵸로 사용하였다.

입력 변수로는 사용자 수, 릴레이 수, 송신 전력, 릴레이 전력, 목표 보안 전송률, 거리 정보 등을 사용하였고 출력값으로 SOP를 예측하도록 딥러닝 모델을 학습하였다.

## 사용 기술
- MATLAB
- MATLAB Deep Learning Toolbox
- Statistics and Machine Learning Toolbox
- Monte Carlo Simulation

## 모델 구조
딥러닝 모델은 회귀 기반 DNN 구조로 구성하였다.
- 입력층: 시스템 파라미터 입력
- 은닉층: Fully Connected Layer 기반 특징 학습
- 출력층: SOP 예측값 출력
- 손실 함수: Mean Squared Error
- 최적화 알고리즘: Adam

## 프로젝트 상태
기본 모델 구현 및 실험 완료

## 데이터셋 생성
SOP 예측 모델 학습을 위해 MATLAB 기반 Monte Carlo 시뮬레이션을 데이터셋을 생성하였다.
각 데이터 샘플은 무작위로 설정된 시스템 파라미터를 기반으로 구성하였다.

- Source 수
- Relay 수
- Source 송신 전력
- Relay 송신 전력
- Source-Relay 거리
- Source-Eavesdropper 거리
- Relay-Destination 거리
- Relay-Eavesdropper 거리
- 보안 임계값
- SOP 값

생성된 데이터셋의 마지막 열은 SOP 정답값이며, 나머지 열은 DNN 모델의 입력 변수로 사용하였다.

데이터셋 생성 코드는 'dataset.m' 파일에 구현하였다.

## DNN 기반 SOP 예측 모델
생성된 SOP 데이터셋을 이용하여 MATLAB 기반 DNN 회귀 모델을 학습하였다.
모델은 시스템 파라미터를 입력으로 사용하고 출력값으로 SOP를 예측하도록 구성하였다. 데이터는 HoldOut 방식으로 학습 데이터와 테스트 데이터로 분리하였으며, 입력 데이터는 평균과 표준편차를 이용해 정규화하였다.
SOP 값은 작은 범위에 몰릴 수 있기 때문에 학습 과정에서는 'log10(SOP + eps)' 변환을 적용하였다. 예측 후에는 다시 원래 SOP 범위로 복원하고 SOP가 확률값임을 고려하여 0과 1 사이로 제한하였다.

### 모델 구조
- 입력층: 시스템 파라미터 입력
- 은닉층 1: Fully Connected Layer, 128 nodes
- 은닉층 2: Fully Connected Layer, 64 nodes
- 은닉층 3: Fully Connected Layer, 32 nodes
- 출력층: SOP 예측값
- 활성화 함수: ReLU
- 손실 함수: Regression Loss
- 최적화 알고리즘: Adam

### 성능 평가
모델 성능은 테스트 데이터에 대해 다음 지표로 평가하였다.
- MSE: Mean Squared Error
- MAE: Mean Absolute Error

또한 실제 SOP 값과 예측 SOP 값을 산점도로 시각화하여 모델의 예측 경향을 확인하였다.

모델 학습 코드는 'sop_predict_model.m' 파일에 구현하였다.

## 실험 결과
테스트 데이터에 대해 모델 성능을 평가한 결과는 다음과 같다.
- Test MSE: 0.000146
- Test MAE: 0.008146

또한 실제 SOP 값과 예측 SOP 값을 비교한 산점도를 통해 예측값이 실제값과 유사한 경향을 보이는 것을 확인하였다.
<img width="1233" height="823" alt="image" src="https://github.com/user-attachments/assets/723eedc3-4b90-4c24-b853-c217a846e00f" />
