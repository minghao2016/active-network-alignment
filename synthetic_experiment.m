function filename = synthetic_experiment(n_reps, job_id, solver, dir_id)
% SYNTHETIC_EXPERIMENT Run the experiment on preferential attachment graphs
% (Fig. 3).
%
% Input:
% 	n_reps -- Number of times the experiment is run with a random initialization.
% 	job_id -- Job ID number appended to the name of the output directory
% 		  (set it to, e.g., 0 unless you run a batch job).
% 	solver -- Should be either 0 (for Natalie) or 1 (for NetAlignMP++).
% 	dir_id -- ID number for the experiment appended to the output directory.
%
% Author: Eric Malmi (eric.malmi@gmail.com)

addpath('netalign/matlab');

if nargin < 4
    dir_id = 0;
end
if nargin < 3
    solver = 1;
end
if nargin < 2
    job_id = 0;
end
if nargin < 1
    n_reps = 1;
end

% Set random seed.
rng(now() + job_id);

subdir = strcat('experiment_results/run', int2str(dir_id));
mkdir(subdir);
filename = strcat(subdir, '/res', int2str(job_id), '_solver', ...
    int2str(solver), '.mat');

% Problem parameters.
n = 1000;
p_keep_edge = 0.4;
density_multiplier = 1.5;
n_duplicates = 30;
data_getter = @(repetion_idx) get_synthetic_problem(n, 2, p_keep_edge, ...
    density_multiplier, n_duplicates);

% Solver parameters.
k = 30;
a = 1;
b = 1;
gamma = 0.1;
stepm = 20;
dtype = 2;
verbose = false;
max_iters = 300;

% Experiment parameters
method_names = {'TopMatchings', 'LCCL', 'Margin', ... %'Degree', 'MinDegree', ...
                'Betweenness', 'Random', 'TopMatchings10Batch', ...
                'Margin10Batch'};
query_counts = cell(length(method_names), 1);
for i = 1:length(method_names)
    if strfind(method_names{i}, 'Batch')
        query_counts{i} = 0:10:990;
    else
        query_counts{i} = 0:990;
    end
end

[accs, ts, query_ts, cum_accs, align_ts] = run_experiment( ...
    method_names, query_counts, n_reps, n, data_getter, solver, a, b, ...
    gamma, stepm, dtype, max_iters, verbose, k);
mean_query_ts = mean(query_ts, 3)
mean_ts = mean(ts, 3)
mean_cum_accs = mean(cum_accs, 3)
mean_accs = mean(accs, 3)

save(filename);
fprintf('Wrote workspace to: %s\n', filename);
exit;
