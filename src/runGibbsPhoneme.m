global base
base = [pwd '/'];
addpath(genpath([base 'BasicModels']));
addpath(genpath([base 'lightspeed']));

load('parseddata');
X = data(:, 3:4);

output = gibbsPhonemes(X);