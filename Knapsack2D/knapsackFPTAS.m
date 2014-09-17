function [packed] = knapsackFPTAS(capacity, weights, profits, epsilon)
	n = length(weights);
	if epsilon > 0
		pMax = max(profits);
		k = epsilon * pMax / n;
		profits = floor(profits / k);
	end

	m = zeros(n, capacity);
	chosen = zeros(n, capacity, 'int8');

	m(1, weights(1):end) = profits(1);
	chosen(1, weights(1):end) = 1;

	% Matlab is 1-based, so handles subscript 0 explicitly.
	for i = 2:n
		for j = 1:capacity
			if j > weights(i)
				choice = [m(i-1, j-weights(i)) + profits(i); % included
					m(i-1, j)]; % or not
			elseif j == weights(i)
				choice = [profits(i); m(i-1, j)];
			else
				choice = [-1; m(i-1, j)];
			end
			[m(i, j), chosen(i, j)] = max(choice);
		end
	end
	chosen = chosen == 1;

	packed = false(n, 1);
	cap = capacity;
	for s = n:-1:1
		packed(s) = chosen(s, cap);
		if packed(s)
			cap = cap - weights(s);
			if cap == 0
				break;
			end
		end
	end

end

