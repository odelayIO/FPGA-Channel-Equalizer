% ******************************************************************************************
% ******************************************************************************************
% *  
% *  The MIT License (MIT)
% *  
% *  Copyright (c) 2016 http://odelay.io 
% *  
% *  Permission is hereby granted, free of charge, to any person obtaining a copy
% *  of this software and associated documentation files (the "Software"), to deal
% *  in the Software without restriction, including without limitation the rights
% *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% *  copies of the Software, and to permit persons to whom the Software is
% *  furnished to do so, subject to the following conditions:
% *  
% *  The above copyright notice and this permission notice shall be included in all
% *  copies or substantial portions of the Software.
% *  
% *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% *  SOFTWARE.
% *  
% *  Contact : <everett@odelay.io>
% *  
% *  Description : Polls TriggerSensors and transmits data to serial port.
% *
% *  Version History:
% *  
% *      Date        Description
% *    -----------   -----------------------------------------------------------------------
% *     10JAN2010     Original Creation
% *
% *
% ******************************************************************************************
% ******************************************************************************************

clear all
close all

M = 4;
numOfSym = 1024;
trainSize = 256;
coef = [0.3 -0.5 0.7 0.2 0.3];
bypass_ch = 0;
bypass_awgn = 0;
SNR = 20;

% create the constellation points
pt = sqrt(2)/2;
sym0=complex(pt,pt); sym1=complex(-pt,pt);
sym2=complex(pt,-pt); sym3=complex(-pt,-pt);

% random integers between 0-3
txBits = randi(M,numOfSym,1);

% now modulate the bits
p = find(txBits==1); datSig(p)=sym0;
p = find(txBits==2); datSig(p)=sym1;
p = find(txBits==3); datSig(p)=sym2;
p = find(txBits==4); datSig(p)=sym3;

% create the training sequence
trainBits = randi(M,trainSize,1);
p = find(trainBits==1); trainSig(p)=sym0;
p = find(trainBits==2); trainSig(p)=sym1;
p = find(trainBits==3); trainSig(p)=sym2;
p = find(trainBits==4); trainSig(p)=sym3;

% combine the training sequence and data signal
datSig = [trainSig datSig];

% add the ISI
if(bypass_ch == 0)
  l = length(coef);
  for i = 1:length(datSig)-l
    isiSig(i) = sum(datSig(i:i+l-1).*coef);
  end
else
  isiSig = datSig;
end


% Adding noise to input data
len = length(isiSig);
sigma2s = var(isiSig); % Sigma squared of Signal
sigma2n = sigma2s/SNR; % Sigma squared of Noise, SNR is input parameter
sigma2n = 1/SNR;
nI = sqrt(sigma2n/2) * randn(1, len);  % I component of noise
nQ = sqrt(sigma2n/2) * randn(1, len); % Q component of noise
n = nI + sqrt(-1)*nQ; % Noise value
if(bypass_awgn == 0)
  isiSig = isiSig + n; % Final output signal with noise
else
  isiSig = isiSig;
end


figure
plot(isiSig,'b*');
title('Unequalized Signal')
axis([-1.4 1.4 -1.4 1.4])

equSig = lms_equalizer(isiSig, trainSig);

figure
plot(equSig,'r*')
title('Equalized Signal')
axis([-1.4 1.4 -1.4 1.4])


