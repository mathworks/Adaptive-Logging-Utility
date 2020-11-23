% Copyright 2020 The MathWorks, Inc.

devel.Env.setMode('PROD');
devel.Log.setLevel('WARN');

A = [1 4 7 10; 2 5 8 11; 3 6 9 12];
B = reshape(A,2,6);
devel.Log.info("B = ["+num2str(B(:)')+"]");

A = magic(3);
B = A.';
devel.Log.fatal(@()(sum(sum(B))==45), "Incorrect total");

B(1,1) = 0;
devel.Log.fatal(@()(sum(sum(B))==45), "Incorrect total");

devel.Env.setMode('DEV');
devel.Log.fatal(@()(sum(sum(B))==45), "Incorrect total");
