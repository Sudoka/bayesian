function weights = contrastiveDivergence2 (x, y, ffs, alpha, N)
   poss_tags = {'S', 'B', 'I', 'O'};
   tags = 'SBIO';
   weights = rand(N, 1);
   for epoch = 1:1
       for a = alpha
           for w = 1:size(x,1)
               w
               ffIndices = ffs{w,2}{1,1};
               ffValues = ffs{w,1};
               % calculate y*
               label = y{w};
               newLabel = zeros(numel(label), 1);
               for c = 1:numel(label)
                newLabel(c) = find(tags == label(c));
               end
               label = newLabel;
               
               y_star = gibbs(label, weights, ffValues, ffIndices, 1);
               % weight update
               for j = 1:numel(ffIndices)
                   weights(ffIndices(j)) = weights(ffIndices(j)) + a*(F2(x,label,j,w) - F2(x,y_star,j,w));
               end
           end
       end
   end

    function out = F2(x, y, j, w)
        fjSum = 0;
        for currentChar = 1:numel(y)
            if currentChar == 1
                yp = 1;
            else
                yp = y(currentChar-1);
            end
            yc = y(currentChar);
            fjSum = fjSum + full(ffValues{yp,yc}(j, currentChar));
        end
        out = fjSum;
    end

end