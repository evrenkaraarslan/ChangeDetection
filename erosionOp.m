function outputImage = erosionOp(inputImage,eroKernel)
[kH,kW] = size(eroKernel);
hlfH = floor(kH/2);
hlfW = floor(kW/2);
[rws,cls] = size(inputImage);
outputImage = false(rws,cls);
for cln = (hlfW + 1) : (cls - hlfW)
	for row = (hlfH + 1) : (rws - hlfH)
		nbrhood = inputImage(row-hlfH:row+hlfH,cln-hlfW:cln+hlfW);
		outputImage(row, cln) = min(nbrhood(eroKernel));
	end
end