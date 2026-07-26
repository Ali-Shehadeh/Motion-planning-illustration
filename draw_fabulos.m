%% ============================================================
% Interactive Snake Trajectory Plot with Obstacles + Animation
% ============================================================

clear; close all; clc;

%% PARAMETERS
n_links   = 8;                        % number of snake segments
n_poses   = 6;                        % number of poses (snapshots)
seg_len   = 0.07;                     % fixed link length (m)
obstacles = [0.3 0.2 0.05;            % [x,y,r] for each obstacle
             0.6 -0.1 0.07;
             0.8 0.25 0.05];

colors = jet(n_poses);                % colormap for poses

%% PLOT SETUP
figure('Name','Snake Trajectory with Obstacles','Color','w'); hold on; grid on;
axis equal;
xlabel('x [m]'); ylabel('y [m]');
title('Trajectory of Snake Robot under OAL Control');

% Plot obstacles with radii
theta = linspace(0,2*pi,100);
for i = 1:size(obstacles,1)
    x_obs = obstacles(i,1) + obstacles(i,3)*cos(theta);
    y_obs = obstacles(i,2) + obstacles(i,3)*sin(theta);
    fill(x_obs, y_obs, 'b', 'FaceAlpha',0.3, 'EdgeColor','b');
    text(obstacles(i,1)+0.02, obstacles(i,2), sprintf('Obs%d',i));
end

% Plot start and goal
plot(0,0,'go','MarkerFaceColor','g','MarkerSize',10);
text(0.02,0,'Start');
plot(1,0,'ro','MarkerFaceColor','r','MarkerSize',10);
text(1.02,0,'Goal');

% Scene bounds
xlim([-0.2 1.2]); ylim([-0.5 0.5]);

%% INTERACTIVE INPUT LOOP
disp('Click 8 points for each snake pose (press ENTER when done with all poses)');
disp('First point = head of snake. Segments will be adjusted to length 0.07.');

snakePoses = cell(n_poses,1);

for p = 1:n_poses
    fprintf('Pose %d: select approximate polyline with mouse (%d points)...\n', p, n_links);
    
    % Collect user points
    [x_raw,y_raw] = ginput(n_links);
    pts = [x_raw(:), y_raw(:)];
    
    % Enforce constant link length
    snake_xy = zeros(n_links,2);
    snake_xy(1,:) = pts(1,:); % head
    for k = 2:n_links
        dir_vec = pts(k,:) - snake_xy(k-1,:);
        dir_vec = dir_vec / norm(dir_vec + eps); % normalize
        snake_xy(k,:) = snake_xy(k-1,:) + seg_len*dir_vec;
    end
    
    % Store pose
    snakePoses{p} = snake_xy;
    
    % Plot the snake body snapshot
    plot(snake_xy(:,1), snake_xy(:,2), '-o', ...
        'Color', colors(p,:), ...
        'MarkerFaceColor', colors(p,:), ...
        'LineWidth', 2, 'MarkerSize', 6);
end

legend({'Obstacle 1','Obstacle 2','Obstacle 3','Start','Goal'}, ...
       'Location','bestoutside');

%% ANIMATION
disp('Generating animation...');

figure('Name','Snake Animation','Color','w'); hold on; grid on; axis equal;
xlabel('x [m]'); ylabel('y [m]');
title('Snake Robot Animation');
xlim([-0.2 1.2]); ylim([-0.5 0.5]);

% Plot obstacles
for i = 1:size(obstacles,1)
    x_obs = obstacles(i,1) + obstacles(i,3)*cos(theta);
    y_obs = obstacles(i,2) + obstacles(i,3)*sin(theta);
    fill(x_obs, y_obs, 'b', 'FaceAlpha',0.3, 'EdgeColor','b');
end
plot(0,0,'go','MarkerFaceColor','g','MarkerSize',10);
plot(1,0,'ro','MarkerFaceColor','r','MarkerSize',10);

% Snake body plot handle
snakeLine = plot(nan,nan,'-o','Color','r','LineWidth',2,'MarkerFaceColor','r');

% Interpolation steps between poses
interpSteps = 20;

for p = 1:(n_poses-1)
    poseA = snakePoses{p};
    poseB = snakePoses{p+1};
    
    for alpha = linspace(0,1,interpSteps)
        snakeInterp = (1-alpha)*poseA + alpha*poseB;
        set(snakeLine,'XData',snakeInterp(:,1),'YData',snakeInterp(:,2));
        drawnow;
        pause(0.05);
    end
end

disp('Animation finished.');
