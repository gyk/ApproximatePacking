function [stripWidth, heightLB, itemsSizes] = loadData(dataPath)
	fid = fopen(dataPath);
	stripWidth = fscanf(fid, '%d', 1);
	heightLB = fscanf(fid, '%d', 1);  % lower bound of strip height
	nItem = fscanf(fid, '%d', 1);
	itemsData = textscan(fid, '%f%f');
	fclose(fid);
	itemsSizes = [itemsData{1} itemsData{2}];
	assert(size(itemsSizes, 1) == nItem);
end
