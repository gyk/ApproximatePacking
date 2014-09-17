function [] = stripPacking(dataPath)
	[stripWidth, heightLB, itemsSizes] = loadData(dataPath);
	items.sizes = itemsSizes;
	items.areas = prod(items.sizes, 2);
	hMax = max(items.sizes(:, 1));
	wMax = max(items.sizes(:, 2));
	areaAll = sum(items.areas);
	bin.size(2) = stripWidth;
	bin.size(1) = max(hMax, ...
		2 * areaAll/stripWidth + ...
			max(2 - stripWidth/wMax, 0) * max(hMax - areaAll/stripWidth, 0));

	sb = Steinberg(bin, items);
	fprintf('The result of 2-approximation algorithm:\n');
	result = sb.solve();

	fprintf('The total height is %.3f\n', bin.size(1));
	fprintf('The lower bound of height is %.3f\n', heightLB);
	fprintf('A(I) / OPT(I) = %.3f\n', bin.size(1) / heightLB);
	fprintf('================================\n\n');
end