% data: m x n matrix of speech sounds, where each sound m has n formants
% categories: 12 x 1 vector of vowel phoneme categories
function output = gibbsPhonemes (data, categories)
  numData = size(data, 1);
  % init each phoneme category randomly
  c = ones(size(data, 1), 1);
  % init means: d x numcategories matrix
  mus = [500; 1500];
  % init cov matrices: d x d x numcategories
  sigmas = zeros(2, 2, 1);
  sigmas(:,:,1) = [1 0;0 1];
  % init pi: numcategories x 1
  alpha = 1;
  pis = dirichlet_sample(alpha, 1);
  % init v
  v_0 = 1.001;
  
  for i = 1:600
    % for each phoneme in data set
    for j = 1:numData
      cond_dist = zeros(numel(categories) + 1, 1);
      % resample p(c | x_i) = p(x_i | c) * p(c)
      for k = 1:numel(categories)
        % calculate prior
        prior_k = sum(c == k) / (numData + alpha);
        
        % calculate likelihood
        % sigma_post = IW(sigma_prior, v_0)
        sigma_post = invWishartSample(struct('Sigma', sigmas(:,:,k), 'dof', v_0));
        % mu_post = N(mu_prior, sigma_post / v_0)
        mu_post = gaussProb(mus(:,k), sigma_post / v_0); % update v_0 somewhere?
        % p(x_i|mu_post, sigma_post)
        p_xi = pis(k) * gaussProb(data(j,:), mu_post', sigma_post);
        % get likelihood
        likelihood = p_xi * mu_post * sigma_post;
        
        % numerator
        numerator = likelihood * prior_k;
        
        % add it to the conditional dist
      end
      % prior of new category
      % prior_newk = alpha / (numData + alpha);
      
      % add it to the conditional dist
      
      % resample pi ~ Dir(alpha + # points in cluster c)
        
      % resample sigma_c ~ IW(sigma_prior, v)
      
      % resample mu_c | sigma_c ~ N(mu_prior, sigma_c / v)
    end
  end
end