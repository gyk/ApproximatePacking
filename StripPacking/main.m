dataRoot = '.\benchmarksSPP\';
fileNames = dir(dataRoot);
fileNames = {fileNames.name};
fileNames = fileNames(3:end);

for f = fileNames
	f = f{:};
	disp(f);
	stripPacking(fullfile(dataRoot, f));
	pause;
end
