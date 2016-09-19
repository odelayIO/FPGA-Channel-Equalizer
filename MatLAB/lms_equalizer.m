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
% *  Description : FPGA Model of LMS Time-Domain Equalizer
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


function [y] = lms_equalizer(x,d)

train_len = length(d);
numTaps = 5;
mu2 = 2^-6;
mu1 = 2^-2;
STEP_ADJ = 32;
leakage = 1-mu2*0.10;

% fill the pipe_x up with symbols
for j = 1:numTaps
  pipe_x(j) = x(j);
  w(j) = (0+0*i);
end

% LMS Adaptation
y(numTaps)=(0+0*i);
for n = numTaps : train_len
  
  pipe_x = x(n-numTaps+1:n);

  % select part of the training input
  y(n)=(0+0*i);
  for j = 1:numTaps
    y(n) = y(n)*leakage + w(j)*pipe_x(j);
  end

  % compute the error
  e(n) = d(n) - y(n);

  % update the coef
  for j = 1:numTaps
    if(n>STEP_ADJ)
      w(j) = w(j) + conj(pipe_x(j))*(mu2*e(n));
    else
      w(j) = w(j) + conj(pipe_x(j))*(mu1*e(n));
    end
  end
  coef1(n) = w(1);
  coef2(n) = w(2);
  coef3(n) = w(3);
  coef4(n) = w(4);
  coef5(n) = w(5);
end

% equalize the signal 
for n = numTaps : length(x)
  
  pipe_x = x(n-numTaps+1:n);
  
  % select part of the training input
  y(n) = (0+0*i);
  for j = 1:numTaps
    y(n) = y(n)*leakage + w(j)*pipe_x(j);
  end
end

y = y(train_len+1:end);

if( 1 )
  t = 1:length(coef1);
  figure(100)
  subplot(5,1,1)
  plot(t,real(coef1),t,imag(coef1));
  legend('Real','Imag')

  title('Coef - 1')
  subplot(5,1,2)
  plot(t,real(coef2),t,imag(coef2));
  title('Coef - 2')
  legend('Real','Imag')

  subplot(5,1,3)
  plot(t,real(coef3),t,imag(coef3));
  title('Coef - 3')
  legend('Real','Imag')

  subplot(5,1,4)
  plot(t,real(coef4),t,imag(coef4));
  title('Coef - 4')
  legend('Real','Imag')

  subplot(5,1,5)
  plot(t,real(coef5),t,imag(coef5));
  title('Coef - 5')
  legend('Real','Imag')
end
