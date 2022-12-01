% ------------------------------Holm-Bonferroni-Test-----------------------
%  Date: 29/12/2020 
% Coder: Yixin WANG
%
% [1] Caraffini, Fabio, and Giovanni Iacca. 2020. "The SOS Platform: Designing, Tuning and Statistically Benchmarking Optimisation 
%     Algorithms" Mathematics 8, no. 5: 785. https://doi.org/10.3390/math8050785
% [2] Carrasco, Jacinto, Salvador Garc¨ªa, M. M. Rueda, Swagatam Das, and Francisco Herrera. "Recent trends in the use of statistical
%     tests for comparing swarm and evolutionary computing algorithms: Practical guidelines and a critical review." Swarm and 
%     Evolutionary Computation 54 (2020): 100665.
% [3] Caraffini, Fabio, Giovanni Iacca, and Anil Yaman. "Improving (1+ 1) covariance matrix adaptation evolution strategy: A simple 
%     yet efficient approach." In AIP Conference Proceedings, vol. 2070, no. 1, p. 020004. AIP Publishing LLC, 2019.
% -------------------------------------------------------------------------

NP; % the number of benchmarks
NA;  % the number of benchmarks
Result = zeros(independentLength, NA);
FinalAverOut = zeros(NP, NA);
for i = 1:NP
    % Fetch Data   
    for k = 1:NA
        filename=fullfile('Your file diretor',fileName{k});
        % Result: independentLength * NA
        Result(:,k)=load(filename1); % read the results
    end
    % Each column of Result records all the independent experimental results of one algorithm over ith benchmark
    
    % Each row of FinalAverOut records the average performance of all used algorithms over ith benchmark 
    FinalAverOut(i,:) = mean(Result);  % NP * NA
end

[AlgsRank, CompR, zi, pi, Adjusted_Pvalue, Hypothesis] = holm_bonferroni(NP, NA, FinalAverOut);


function [AlgsRank, CompR, zi, pi, Adjusted_Pvalue, Hypothesis] = holm_bonferroni(NP, NA, FinalAverOut)

    ranktable = zeros(NP,NA);%the NA algorithms ranking over NP benchmarks
    alpha  = 0.05; %alpha is the significance level    
    
    %%  ----------- Holm¨CBonferroni test begining ------------
    % For minimum optimization, the lower cost the better perfromance.
    % Assign the rank for all used algorithms over all benchmarks
    [~, index] = sort(FinalAverOut, 2, 'descend');  % NP * NA, return the index
    for a = 1:NP
        ranktable(a, index(a, :)) = 1:1:7;
    end  % ranktable
    
    R = mean(ranktable);  % 1 * NA, average ranking
    
    R0 = R(1);  % Your own algorithm is placed in first column
    
    [CompR, AlgsRank] = sort(R(2:NA), 'descend');
    AlgsRank = AlgsRank + 1; % AlgsRank is the comparision algorithms ranking as shown in the result table
    
    zi = (CompR-R0) ./ sqrt(NA*(NA+1)/(6*NP));  % Statistics value
    pi = normcdf(zi);
    Adjusted_Pvalue = alpha./(1:1:NA-1);  % NA-1 comparison algorithms, the alpha is the significance level
    
    % If the p_value of each comprision algorithms is greater than the
    % Adjusted_Pvalue, we have no sufficient reason to reject the
    % Null-hypothesis. When the first 'Rejected' occurs, we finished the
    % calculation process and the subseqent outcomes are 'Rejected'.

    % save the value 0-1 which represent rejecting the Null-Hypothesis or accepting
    Hypothesis = (pi >= Adjusted_Pvalue)';
    Rejected = find(Hypothesis == 0);
    firstRejected = Rejected(1);
    Hypothesis(firstRejected : end) = 0;
    
    
    fprintf('  TABLE*** Holm-Bonferroni test result£¨reference£ºYour Algorithm£¬Rank£º%.3f£©  \n', R0);
    fprintf('  i--------Optimizer--------Rank--------Zi--------pi--------alpha/i--------Hypothesis  \n');
    for i = 1:NA-1
        fprintf('  %d        %d               %.3f        %.3f    %.3f     %.3f            %d  \n', ...
            i, AlgsRank(i), CompR(i), zi(i), pi(i), Adjusted_Pvalue(i), Hypothesis(i));
    end
    % -------------------------------------------------------------------------
    
end

