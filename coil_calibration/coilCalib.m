% Demonstration of the coil calibration technique.  

%% load example data
% v_bias, W_inv, and g_mag are the magnetometer calibration parameters (see mmCalib.m)
% v_raw, u, mag_pos are the coil. 
% u [3xN] are the N voltage triplets that led to N magnetic vectors v_raw [3xN]
% inside the setup. In this case, U describes a zero-centered sphere
% with radius 1V.

load('mmCalibParams.mat', 'v_bias', 'W_inv', 'g_mag')
load('coilCalibDataRaw.mat', 'v_raw', 'u', 'mag_pos')

%% Apply magnetometer calibration
% Translate magnetometer raw data to physical units 

B_amb = (v_raw - v_bias) * W_inv * g_mag;

%% Plot the data

% plot
figure('color', 'w')
subplot(1, 2, 1)
plot3(u(:, 1), u(:, 2), u(:, 3), '.')
box on
axis equal
title('control voltages')
subplot(1, 2, 2)

plot3(B_amb(:, 1), B_amb(:, 2), B_amb(:, 3), '.')
box on
axis equal
title('resulting magnetic field')

%% Get calibration parameters

[D, c] = getCoilCalibrationParams(u', B_amb');

%% Apply calibration
% For the sake of demonstration, let's now take the B_amb triplets, and 
% pretend we are looking for the voltages that lead to these Bs in the
% setup. We should thus obtain the control voltages that were applied for
% calibration. Since the measured magnetic vectors are noisy, the derived
% controle voltages will also be noisy in this case.

U_ = D \ (B_amb' - c); 

%% Plot data of applied calibration 
figure('color', 'w')
hold on
plot3(U_(1, :), U_(2, :), U_(3, :), 'b.')
alpha(.5)
plot3(u(:, 1), u(:, 2), u(:, 3), '+', 'MarkerSize', 20)
box on
axis equal
legend('resulting control voltages', 'initially applied voltages')
view([32 32])