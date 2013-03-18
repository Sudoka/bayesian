% data: m x n matrix of speech sounds, where each sound m has n formants
% categories: 12 x 1 vector of vowel phoneme categories
function output = gibbsPhonemes (data)
  numData = size(data, 1);
  % init each phoneme category randomly
  c = ones(size(data, 1), 1);
  % init means: d x numcategories matrix
  mu_0 = [500; 1500];
  % init cov matrices: d x d x numcategories
  sigma_0 = [1 0;0 1];
  % init pi: numcategories x 1
  alpha = 1;
  % pis = dirichlet_sample(alpha, 1);
  % init v
  v_0 = 1.001;
  % dims
  d = 2;
  
  cluster.mu = mu_0;
  cluster.sigma = sigma_0;
  cluster.v = v_0;
  cluster.d = d;
  cluster.alpha = alpha;
  cluster.n = numData;
  cluster.p = dirichlet_sample(alpha, 1);
  
  % init dp for cluster 1?
  
  cluster_star = cluster;
  cluster_star.n = 0;
  
  models = num2cell([cluster cluster_star]);
  
  for i = 1:600
    % for each phoneme in data set
    for j = 1:numData
      % remove c
        
      cond_dist = zeros(1,numel(models));
      % resample p(c | x_i) = p(x_i | c) * p(c)
      for k = 1:numel(models)
        % calculate prior
        if (k == numel(models))
          prior_k = alpha / (numData + alpha);
        else
          prior_k = sum(c == k) / (numData + alpha);
        end
        % calculate likelihood
        % sigma_post = IW(sigma_prior, v_0)
        % TODO: inv wishart log prob
        sigma_post = invWishartSample(struct('Sigma', models{k}.sigma, 'dof', models{k}.v));
        sigma = invWishartLogprob(sigma_post, models{k}.v, models{k}.sigma);
        % mu_post = N(mu_prior, sigma_post / v_0)
        mu_post = gaussSample(models{k}.mu, sigma_post / models{k}.v); % update v_0 somewhere?
        mu = gaussLogprob(mu_post, sigma_post/models{k}.v, models{k}.mu);
        % p(x_i|mu_post, sigma_post)
        p_xi = models{k}.p * gaussProb(data(j,:), mu_post', sigma_post);
        % get likelihood
        likelihood = p_xi * mu * sigma;
        
        % add it to the conditional dist
        cond_dist(k) = likelihood * prior_k;
      end
      
      % normalize
      norm_cond_dist = cond_dist ./ sum(cond_dist);
      for cIdx = 2:numel(k)
        norm_cond_dist(cIdx) = norm_cond_dist(cIdx) + norm_cond_dist(cIdx-1);
      end
      
      % resample category -> c
      die = find(norm_cond_dist > rand);
      c(j) = die(1); % replace this
      
      % add c back
      
      % resampling...like z_i?
      
      % resample pi ~ Dir(alpha + # points in cluster c)
      models{k}.p = dirichlet_sample(alpha + models{c(j)}.n);
      % resample sigma_c ~ IW(sigma_prior, v)
      models{k}.sigma = invWishartSample(struct('Sigma', sigma_post, 'dof', models{k}.v));
      % resample mu_c | sigma_c ~ N(mu_prior, sigma_c / v)
      models{k}.mu = gaussSample(mu_post, sigma_post / models{k}.v);
    end
  end
end