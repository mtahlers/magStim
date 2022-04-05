% minimalistic example for retrieving data from the
% vector magnetometer. The actually used COM-port and COM-port name depend
% on OS and the USB device enumeration of the OS. In Windows it can be looked
% up in the device manager. When connected, it will appear under "Ports
% (COM & LTP)" as "USB Serial Port".
%
% Send 'ON' to the magnetometer to make it output the measured raw data.
% Send 'OF' to the magnetometer to stop the data transmission. Data is
% output as space-delimted triplet in ASCII. Data ranges from -2^15 to
% 2^15-1, i.e. from -32768 to 32767.

%% make and configure serial port
baudrate = 38400;
comPort = 'COM3';
ser = serialport(comPort, baudrate);
configureTerminator(ser, 'CR/LF');
configureCallback(ser, 'terminator', @bavCb)

%% Start data tranmission
disp('Starting data transmission. Press any key to abort.')
pause(1)
writeline(ser, 'ON') % start data transmission by magnetometer
pause() % wait for keypress
writeline(ser, 'OF') % stop data transmission by magnetometer
clear ser
disp('Data transmisson stopped.')

%% This callback recieves data, called once per triplet 
function bavCb(obj, ~)
    data = readline(obj);
    disp(data)
    
    % store/save data
    % ...
end

