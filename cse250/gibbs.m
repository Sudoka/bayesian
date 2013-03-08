% Gibbs sampling.
%
% Arguments:
%   y_init: The initial y value to use.
%   weights: The weights of each feature function.
%   ffValues: A cell matrix where the rows and columns correspond to tags.
%     The elements of that cell matrix is a sparse matrix, where the rows
%     are feature functions and the columns are indices into the word.
%   ffIndices: An array where the ith entry is the feature function number
%     belonging to the ith row in ffValues.
%   The number of iterations to use when sampling.
function y = gibbs(yInit, weights, ffValues, ffIndices, num_iterations)
%   tags = 'SBIO';
%   yInitNew = zeros(1, numel(yInit));
%   for c = 1:numel(yInit)
%     yInitNew(c) = find(strcmp(tags,yInit(c)));
%   end
%   y = yInitNew;
  y = yInit;
  tagSet = [1 2 3 4];
  numTags = 4;
  
  for iteration = 1:num_iterations
    % For each element y_i in the y vector, pick a new y_i and replace.
    for i = 1:numel(y)
      % Probability distribution function, stores the upper bound of the
      % interval for each element.
      cdf = ones(1, numTags);
      
        % Compute denominator
        vSum = 0;
        for vPrime = 1:numTags
          y_temp = y;
          y_temp(i) = vPrime;
          pSum = 0;
          for jIndex = 1:numel(ffIndices)
            j = ffIndices(jIndex);
            fjSum = 0;
            for currentChar = 1:numel(y)
              if currentChar == 1
                yp = 1;
              else
                yp = y_temp(currentChar-1);
              end
              yc = y_temp(currentChar);
              
              value = full(ffValues{yp, yc}(jIndex, currentChar));
              fjSum = fjSum + ffValues{yp, yc}(jIndex, currentChar);
              if value == 1
                %fprintf('denom hit: {%d, %d}(%d, %d) = %d\n', yp, yc, jIndex, currentChar, value);
              end
            end
            pSum = pSum + weights(j) * fjSum;
          end
          
          vSum = vSum + exp(pSum);
        end
        denominator = vSum;
      
      % Compute the probability that y_i = tag, for each tag.
      prevCdfValue = 0;
      for tag = 1:numTags-1
        p_i = 0;
        y(i) = tag;
        
        % Compute p_i.
        % Compute numerator.
        pSum = 0;
        for jIndex = 1:numel(ffIndices)
          j = ffIndices(jIndex);
          fjSum = 0;
          for currentChar = 1:numel(y)
            if currentChar == 1
              yp = 1;
            else
              yp = y(currentChar-1);
            end
            yc = y(currentChar);

            value = full(ffValues{yp, yc}(jIndex, currentChar));
            fjSum = fjSum + value;
            if value == 1
              %fprintf('num hit: {%d, %d}(%d, %d) = %d\n', yp, yc, jIndex, currentChar, value);
            end
          end
          pSum = pSum + weights(j) * fjSum;
        end
        numerator = exp(pSum);
        
        p_i = numerator / denominator;
        %fprintf('%f / %f = %f\n', numerator, denominator, p_i);
        cdf(tag) = prevCdfValue + p_i;
        prevCdfValue = cdf(tag);
      end
      
      %cdf
      intervals = tagSet(cdf >= rand);
      y(i) = intervals(1);
    end
  end
end