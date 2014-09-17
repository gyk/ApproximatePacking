function [] = drawPacked(binRect, positions, sizes)
	clf;
	hold on;
	binRect = fliplr(binRect);
	rectangle('Position', [0 0 binRect], 'EdgeColor', 'k');

	n = size(positions, 1);
	cmap = jet(n);
	for i = 1:n
		if any(positions(i, :) == Inf)
			continue;
		end

		rectangle('Position', [positions(i, [2 1]), sizes(i, [2 1])], ...
			'EdgeColor', 'k', 'FaceColor', cmap(i, :));
	end

	hold off;
	axis equal;
	axis([0 binRect(1) 0 binRect(2)]);

	intervals = [1 2 5 10 20 25 50 100];
	intv = intervals(find(intervals >= max(binRect) / 40, 1));

	set(gca, 'XTick', 0:intv:binRect(1));
	set(gca, 'YTick', 0:intv:binRect(2));
	set(gca, 'XColor', [0.5 0.5 0.5]);
	set(gca, 'YColor', [0.5 0.5 0.5]);

	grid on;
end