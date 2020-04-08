function outputVector = saturateVector(inputVector,satLevel)
stIndx = (inputVector > satLevel); % Find intensities greater than saturation level
outputVector = inputVector; % Backup the input vector
outputVector(stIndx) = satLevel; % Set saturation level instead of high values