
epsilon = 0.5;
% fileNames = dir('.\benchmarksOPP');
% fileNames = {fileNames.name};
% fileNames = fileNames(3:end);

fileNames = { ...
	'ngcut1.txt';
	'ngcut2.txt';
	'ngcut3.txt';
	'ngcut4.txt';
	'ngcut5.txt';
	'ngcut6.txt';
	'ngcut7.txt';
	'ngcut8.txt';
	'ngcut9.txt';
	'ngcut10.txt';
	'ngcut11.txt';
	'ngcut12.txt';
	'hccut2.txt';
	'hccut3.txt';
	'hccut4.txt';
	'hccut5.txt';
	'CHL2.txt';
	'CHL2s.txt';
	'A1.txt';
	'A1s.txt';
	'A2.txt';
	'A2s.txt';
	'cgcut1.txt';
	'cgcut2.txt';
	'cgcut3.txt';
	'gcut1.txt';
	'gcut2.txt';
	'gcut3.txt';
	'gcut4.txt';
	'gcut5.txt';
	'gcut6.txt';
	'gcut7.txt';
	'gcut8.txt';
	'gcut9.txt';
	'gcut10.txt';
	'gcut11.txt';
	'gcut12.txt';
	'okp1.txt';
	'okp3.txt';
	'okp4.txt';
	'okp2.txt';
	'okp5.txt';
}';

for f = fileNames
	f = f{:};
	disp(f);
	knapsack2D(['.\benchmarksOPP\' f], epsilon);
	pause;
end

