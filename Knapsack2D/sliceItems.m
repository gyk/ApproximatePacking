function [itemsNew] = sliceItems(items, indices, included)
	if ~exist('included', 'var')
		included = true;
	end

	if islogical(indices)
		belongTo = indices;
	else
		belongTo = false(size(items.sizes, 1), 1);
		belongTo(indices) = true;
	end

	if ~included
		belongTo = ~belongTo;
	end

	itemsNew.sizes = items.sizes(belongTo, :);
	itemsNew.areas = items.areas(belongTo);
	itemsNew.n = length(itemsNew.areas);

	if isfield(items, 'id')
		itemsNew.id = items.id(belongTo);
	end

	if isfield(items, 'profits')
		itemsNew.profits = items.profits(belongTo, :);
	end
end