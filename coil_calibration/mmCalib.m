% magnetometer calibration example based on the MATLAB-internal MAGCAL
% function. 

%% load example data
% v_raw [Nx3] is the aquired magnetometer raw data
% b_ref is a scalar containing the magnetic field magnitude the calibration
% data was gathered in (typically the local magnetic field strength)

load('mmRawData.mat', 'v_raw', 'b_ref')

%% get calibration paramters
[W_inv, v_bias, radius_raw] = magcal(v_raw);
g_mag = b_ref/radius_raw;

% alternative to matlab's built-in magcal:
% https://www.st.com/resource/en/design_tip/dt0059-ellipsoid-or-sphere-fitting-for-sensor-calibration-stmicroelectronics.pdf

if true
    % save calibration parameters, if wanted  
    save('mmCalibParams.mat', 'v_bias', 'W_inv', 'g_mag')
end

%% apply calibration
% this is how the calibration parameters v_bias, W_inv, and g_mag are
% applied to magnetometer raw data to obtain the calibrated magnetic field
% data B_amb

B_amb = (v_raw - v_bias) * W_inv * g_mag;

%% plot the data for demonstration
figure('color', 'w')
subplot(1, 2, 1)
plot3(v_raw(:, 1), v_raw(:, 2), v_raw(:, 3))
box on
axis equal
title('raw data')
subplot(1, 2, 2)
plot3(B_amb(:, 1), B_amb(:, 2), B_amb(:, 3))
box on
axis equal
title('calibrated data')