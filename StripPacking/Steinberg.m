classdef Steinberg < handle
% Implements the packing algorithm described in the paper "A strip-packing 
% algorithm with absolute performance bound 2." Steinberg, A. (1997). 
% SIAM Journal on Computing, 26(2), 401-409.
% 
% Usage: 
%   bin.size = [4 4];
%   items.sizes = [1 3; 1 2; 2 1; 1 1];
%   sb = Steinberg(bin, items)
%   sb.solve();

	properties
	allItems;
	wholeBin;
	result;
	end

	methods (Static)
	function [bin, items] = prepare(bin, items)
		bin.area = prod(bin.size);
		items.n = size(items.sizes, 1);
		if ~isfield(items, 'areas')
			items.areas = prod(items.sizes, 2);
		end
		items.areaAll = sum(items.areas);
		[~, items.sortedInd] = sort(items.sizes, 1, 'descend');

		% checks feasibility
		hMax = items.sizes(items.sortedInd(1, 1), 1);
		wMax = items.sizes(items.sortedInd(1, 2), 2);
		H = bin.size(1);
		W = bin.size(2);
		assert(hMax <= H + 1e-6 && wMax <= W + 1e-6);
		assert(2 * items.areaAll <= ...
			bin.area - max(2 * hMax - H, 0) * max(2 * wMax - W, 0) + 1e-6);
	end
	end

	methods
	function obj = Steinberg(bin, items)
		assert(isfield(bin, 'size'));
		assert(isfield(items, 'sizes'));
		obj.allItems = items;
		obj.allItems.id = 1:size(items.sizes, 1);
		obj.wholeBin = bin;
		obj.wholeBin.relPos = [0 0];
	end

	function [] = pack(obj, itemId, relPos, lowerLeftCorner)
		itemSize = obj.allItems.sizes(itemId, :);
		pos = relPos + lowerLeftCorner;
		fprintf('Pack item #%d of size (%d, %d) at (%.3f, %.3f)\n', ...
			itemId, itemSize(1), itemSize(2), pos(1), pos(2));

		obj.result(itemId, :) = relPos + lowerLeftCorner;

		% % TODO: remove it
		% for i = 1:obj.allItems.id(end)
		% 	if i == itemId
		% 		continue;
		% 	end

		% 	if rectint([obj.result(i, :) obj.allItems.sizes(i, :)], ...
		% 		[obj.result(itemId, :) itemSize]) > 1e-6
		% 		error('The items must not overlap.');
		% 	end
		% end
	end

	function success = checkCondition0(obj, bin, items)
		success = false;
		[itemMax, maxInd] = max(items.areas);
		if items.areaAll - bin.area / 4 < itemMax
			% _[R(i)] = _[Q]
			obj.pack(items.id(maxInd), bin.relPos, [0 0]);
			success = true;

			if items.n == 1
				return
			else
				% _[Q'] = [R(i)]_, [Q']^ = Q^
				binNew.size = bin.size;
				binNew.size(2) = binNew.size(2) - items.sizes(maxInd, 2);
				binNew.relPos = bin.relPos;
				binNew.relPos(2) = bin.relPos(2) + items.sizes(maxInd, 2);
				itemsNew = sliceItems(items, maxInd, false);
				obj.tryPacking(binNew, itemsNew);
			end
		end
	end

	function success = checkCondition1(obj, bin, items, dim)
		dim_ = 3 - dim;

		maxInd = items.sortedInd(1, dim);
		if ~(items.sizes(maxInd, dim) >= bin.size(dim) / 2)
			success = false;
			return;
		end

		success = true;

		% _[R(1)] = _[Q], _[R(i)] = ^[R(i-1)]
		lowerLeft = [0 0];
		i = 1;
		while i <= items.n
			ii = items.sortedInd(i, dim);
			if items.sizes(ii, dim) < bin.size(dim) / 2
				break;
			end

			obj.pack(items.id(ii), bin.relPos, lowerLeft);
			lowerLeft(dim_) = lowerLeft(dim_) + items.sizes(ii, dim_);
			i = i + 1;
		end

		restHeight = bin.size(dim_) - lowerLeft(dim_);
		restInd = items.sortedInd(i:end, dim);
		nRest = size(restInd, 1);

		if nRest == 0
			return
		end

		% sorting
		query = true(items.n, 1);
		doneInd = items.sortedInd(1:i-1, dim);
		query(doneInd) = false;
		remain = query(items.sortedInd(:, dim_));
		restInd_ = items.sortedInd(remain, dim_);
		assert(length(restInd) == length(restInd_));

		% [R(1)]^ = [Q]^, [R(j)]^ = ^[R(j-1)]
		upperRight = bin.size;
		i = 1;
		while i <= nRest
			ii = restInd_(i);
			if items.sizes(ii, dim_) <= restHeight
				break;
			end

			obj.pack(items.id(ii), ...
				bin.relPos, upperRight - items.sizes(ii, :));
			upperRight(dim) = upperRight(dim) - items.sizes(ii, dim);
			i = i + 1;
		end

		if i > nRest  % no items left
			return;
		end

		binNew.size(dim) = upperRight(dim);
		binNew.size(dim_) = restHeight;
		binNew.relPos = bin.relPos + lowerLeft;
		itemsNew = sliceItems(items, restInd_(i:end));
		obj.tryPacking(binNew, itemsNew);
	end

	function success = checkCondition2(obj, bin, items, dim)
		dim_ = 3 - dim;
		success = false;
		if items.n == 1
			return;
		end

		satisfiedInd = find(all(bsxfun(@ge, items.sizes, bin.size / 4), 2));

		for i = 1:length(satisfiedInd)-1
			ii = satisfiedInd(i);
			for j = i+1:length(satisfiedInd)
				jj = satisfiedInd(j);
				[largerSideLen, indLarger] = max(items.sizes([ii jj], dim));
				if 2 * (items.areaAll - items.areas(ii) - items.areas(jj)) <= ...
					(bin.size(dim) - largerSideLen) * bin.size(dim_)
					success = true;
					break;
				end
			end

			if success
				break;
			end
		end

		if ~success
			return
		end

		if indLarger == 2  % items.sizes(jj, dim) is larger
			t = ii; ii = jj; jj = t;
		end

		% _[R(i)] = _[Q], _[R(k)] = ^[R(i)]
		lowerLeft = [0 0];
		obj.pack(items.id(ii), bin.relPos, lowerLeft);
		lowerLeft(dim_) = lowerLeft(dim_) + items.sizes(ii, dim_);
		obj.pack(items.id(jj), bin.relPos, lowerLeft);

		if items.n == 2
			return;  % solved
		end

		% _[Q'] = [R(i)]_, [Q']^ = [Q]^
		binNew.relPos = bin.relPos;
		binNew.relPos(dim) = binNew.relPos(dim) + largerSideLen;
		binNew.size = bin.size;
		binNew.size(dim) = binNew.size(dim) - largerSideLen;

		itemsNew = sliceItems(items, [ii, jj], false);
		obj.tryPacking(binNew, itemsNew);
	end

	function success = checkCondition3(obj, bin, items, dim)
		dim_ = 3 - dim;
		success = false;
		if items.n == 1
			return;
		end

		cumSum = 0;
		for i = 1:(items.n-1)
			i0 = items.sortedInd(i, dim);
			i1 = items.sortedInd(i+1, dim);
			cumSum = cumSum + items.areas(i0);
			if items.areaAll - bin.area / 4 <=  cumSum && ...
				cumSum <= 3 / 8 * bin.area && ...
					items.sizes(i1, dim) <= bin.size(dim) / 4
				success = true;	
				break;
			end
		end

		if ~success
			return;
		end

		% cuts the container into two rectangles
		bin1.size(dim) = max(bin.size(dim) / 2, ...
			2 * cumSum / bin.size(dim_));
		bin2.size(dim) = bin.size(dim) - bin1.size(dim);
		bin1.size(dim_) = bin.size(dim_);
		bin2.size(dim_) = bin.size(dim_);

		bin1.relPos = bin.relPos;
		bin2.relPos(dim) = bin.relPos(dim) + bin1.size(dim);
		bin2.relPos(dim_) = bin.relPos(dim_);

		items1 = sliceItems(items, items.sortedInd(1:i, dim));
		items2 = sliceItems(items, items.sortedInd(i+1:end, dim));

		obj.tryPacking(bin1, items1);
		obj.tryPacking(bin2, items2);
	end

	function [] = tryPacking(obj, bin, items)
		[bin, items] = obj.prepare(bin, items);

		for dim = [2 1]
			if obj.checkCondition1(bin, items, dim)
				return;
			end
			assert(items.sizes(items.sortedInd(1, dim), dim) <= bin.size(dim) / 2);
		end

		if obj.checkCondition0(bin, items)
			return;
		end

		for dim = [2 1]
			if obj.checkCondition3(bin, items, dim)
				return;
			end

			if obj.checkCondition2(bin, items, dim)
				return;
			end
		end

		error('This should not happen.');
	end

	function result = solve(obj, draw)
	% Output:
	%   result: n-by-2 array of [y x].
		if ~exist('draw', 'var')
			draw = true;
		end

		fprintf('Packing using Steinberg''s algorithm:\n');
		obj.result = inf(obj.allItems.id(end), 2);
		obj.tryPacking(obj.wholeBin, obj.allItems);
		result = obj.result;

		if draw
			drawPacked(obj.wholeBin.size, obj.result, obj.allItems.sizes);
			fprintf(['Intermediate result has been drawn. \n', ...
				'Press any key to continue...\n']);
			shg;  % bring figure window to front
			pause;
		end
	end
	end
end
