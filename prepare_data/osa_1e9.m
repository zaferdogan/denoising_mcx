%% generating data sets used in OSA

clear all

% Top-level Dir
topFolderName='../data/osa';
if ~exist('../data/osa/', 'dir')  mkdir(topFolderName); end

N = 10; % run N times simulation for each test, 

x = 100;
y = 100;
z = 100;


time = zeros(N,5);
pho_cnt = [1e9];  % use 1e9 (as the ground truth)
volume = uint8(ones(x,y,z));

[~, simNum] = size(pho_cnt);

for k=1:simNum
	% Generate new random seed for Monte Carlo simulation
	rand_seed = randi([1 2^31-1], 1, N);
	
	if (length(unique(rand_seed)) < length(rand_seed)) ~= 0
		error('There are repeated random seeds!')
	end

	dir_phn = sprintf('./%s/%1.0e', topFolderName, pho_cnt(k));
    if ~exist(dir_phn, 'dir')  mkdir(dir_phn); end

	for tid =1:N
        %
        % for each photon volume simulation, run N tests
        %
        dir_phn_test = sprintf('%s/%d', dir_phn, tid);
        if ~exist(dir_phn_test, 'dir')  mkdir(dir_phn_test); end


        clear cfg
        cfg.nphoton=pho_cnt(k);
        cfg.vol= volume;
        cfg.srcpos=[50 50 1];
        cfg.srcdir=[0 0 1];
        cfg.gpuid=1;
        % cfg.gpuid='11'; % use two GPUs together
        cfg.autopilot=1;
        %
        % configure optical properties here 
        %
        cfg.prop=[0 0 1 1;0.005 1 0 1.37];
        cfg.tstart=0;
        cfg.tend=5e-8;
        cfg.tstep=5e-8;
        cfg.seed = rand_seed(tid); % each random seed will have different pattern 

        % calculate the flux distribution with the given config
        [flux,detpos]=mcxlab(cfg);

        image3D=flux.data;

        %%% export each image in 3D volume



        %------
        % x-axis
        %------
        
        dir_x = sprintf('%s/x', dir_phn_test);
        if ~exist(dir_x, 'dir')  mkdir(dir_x); end
    
        for imageID=1:x
            fname = sprintf('%s/osa_phn%1.0e_test%d_img%d.mat', dir_x, pho_cnt(k), tid, imageID);
            fprintf('Generating %s\n (x-axis)',fname);
            currentImage = squeeze(image3D(imageID,:,:));
            feval('save', fname, 'currentImage');
        end

        %------
        % y-axis
        %------
        dir_y = sprintf('%s/y', dir_phn_test);
        if ~exist(dir_y, 'dir')  mkdir(dir_y); end

        for imageID=1:y
            fname = sprintf('%s/osa_phn%1.0e_test%d_img%d.mat', dir_y, pho_cnt(k), tid, imageID);
            fprintf('Generating %s\n (y-axis)',fname);
            currentImage = squeeze(image3D(:,imageID,:));
            feval('save', fname, 'currentImage');
        end


        %------
        % z-axis
        %------
        dir_z = sprintf('%s/z', dir_phn_test);
        if ~exist(dir_z, 'dir')  mkdir(dir_z); end

        for imageID=1:z
            fname = sprintf('%s/osa_phn%1.0e_test%d_img%d.mat', dir_z, pho_cnt(k), tid, imageID);
            fprintf('Generating %s\n (z-axis)',fname);
            currentImage = squeeze(image3D(:,:,imageID));
            feval('save', fname, 'currentImage');
        end

		%break
	end
	%break
end
