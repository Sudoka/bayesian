% data: m x n matrix of speech sounds, where each sound m has n formants
% categories: 12 x 1 vector of vowel phoneme categories
function output = gibbsPhonemes (data, categories)
  % init each phoneme category randomly
  cat_assignments = zeros(size(data, 1), 1);
  % init means: d x numcategories matrix
  % init cov matrices: d x d x numcategories
  % init pi: numcategories x 1
  for i = 1:600
    % for each speech sound in data set
    for sound = size(data, 1)
      % for each category
      for category = numel(categories)
        % calculate p(c | w_ij) = p(w_ij | c) * p(c)
        
      end
      % resample category c
    end
  end
end