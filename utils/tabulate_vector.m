function tabulated_results = tabulate_vector(vec)
% Tabulate a given vector of numbers, returning the unique values, the
% count, and the percentage of counts
% Unlike MATLAB's tabulate function, this will not add 0 counts between
% values 1 and max(input) for those values which do not appear in input
% Parekh, Pravesh
% June 19, 2017
% MBIAL

% Proceed only if input is a vector
if isvector(vec)
    values = unique(vec);
    num_values = length(values);
    counts = zeros(num_values,1);
    
    % Loop over each value to calculate counts
    for val = 1:num_values
        counts(val) = sum(vec == values(val));
    end
    
    % Percentages
    percentages = 100*counts./sum(counts);
    
    tabulated_results = [values counts percentages];
else
    error('Input should be a vector of numbers');
end