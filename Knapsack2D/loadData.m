function [binSize, itemsSizes, profits] = loadData(dataPath)
	fid = fopen(dataPath);
	dimension = fscanf(fid, '%d', 1);
	assert(dimension == 2);
	nItemTypes = fscanf(fid, '%d', 1);
	nItem = fscanf(fid, '%d', 1);
	binSize = fscanf(fid, '%f%f', 2)';
	itemsData = textscan(fid, '%f%f%f%f');
	fclose(fid);

	itemsSizes = [itemsData{1} itemsData{2}];
	assert(size(itemsSizes, 1) == nItemTypes);
	repeat = itemsData{3};
	profits = itemsData{4};

	% Sets the profit of an item the same as its area 
	% if it is equal to 0.
	profits = profits + prod(itemsSizes, 2) .* (profits == 0);

	% repeats each row
	aux(cumsum(repeat)) = 1;
	rows = cumsum(aux) - aux + 1;
	itemsSizes = itemsSizes(rows, :);
	profits = profits(rows, :);
	assert(size(itemsSizes, 1) == nItem);
end
