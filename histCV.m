function indx = histCV(mtrx)
vctr = reshape(mtrx,1,numel(mtrx)); % Reshape the frame as a row vector
indx = zeros(1,256); % Initialize the histogram vector
for cnt=1:length(vctr) % Scan for all intensities
    indx(vctr(cnt)+1) = indx(vctr(cnt)+1) + 1; % Count for each intensity
end
