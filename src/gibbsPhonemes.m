function output = gibbsPhonemes (data, categories)
  % init each speech sound randomly
  for i = 1:600
    % for each speech sound in data set
    for sound = size(data, 1)
      % for each category
      for category = numel(categories)
        % calculate p(c | w_ij) = p(w_ij | c) * p(c)
        p_c = dirichlet();
      end
      % resample category c
    end
  end
end

function output = generateDirichlet ()
  
end