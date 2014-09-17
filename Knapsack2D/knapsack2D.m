function [] = knapsack2D(dataPath, epsilon)
	[binSize, itemsSizes, profits] = loadData(dataPath);
	bin.size = binSize;
	items.sizes = itemsSizes;
	items.areas = prod(items.sizes, 2);
	items.profits = profits;

	[packed] = knapsackFPTAS(prod(bin.size), items.areas, profits, epsilon);
	packed1D = sliceItems(items, packed);
	binDoubled.size = bin.size .* [1 2];
	sb = Steinberg(binDoubled, packed1D);
	result = sb.solve();

	categories = classifyItems(result(:, 2), packed1D.sizes(:, 2), binDoubled.size(2));
	for i = [3 2 1]
		profitSum(i) = sum(packed1D.profits(categories == i));
	end
	[largestProfit, i] = max(profitSum);
	itemsPacked = sliceItems(packed1D, categories == i);

	positions = result(categories == i, :);

	if i == 2
		positions(:, 2) = positions(:, 2) - bin.size(2);
	elseif i == 3
		positions(:, 2) = 0;
	end

	fprintf(['\nThe result of (3 + epsilon) approximation algorithm ', ...
		'(epsilon = %f):\n'], epsilon);

	for j = 1:length(itemsPacked.profits)
		fprintf(['Item %d (size = (%d, %d), profit = %.3f) ', ...
					'packed at (%.3f, %.3f)\n'], ...
			j, itemsPacked.sizes(j, 1), itemsPacked.sizes(j, 2), ...
				itemsPacked.profits(j), positions(j, 1), positions(j, 2));
	end

	fprintf('The total profit is %.3f\n', largestProfit);
	fprintf('================================\n\n');
	drawPacked(bin.size, positions, itemsPacked.sizes);
end

function categories = classifyItems(xs, widths, binWidth)
% Classifies each item according to its position in the container.
% Input:
%   xs: n-by-1 array of X coordinates;
%   widths: n-by-1 array of widths;
%   binWidth: the width of the container
% Output:
%   categories: n-by-1 array, where 
%     1: the items completely contained in the left half;
%     2: completely contained in the right half;
%     3: otherwise.
	mid = binWidth / 2;
	categories = (xs < mid) + (xs + widths > mid) * 2;
end
