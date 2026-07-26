%% ============================================================
% Interactive Snake Poses with Fixed Link Lengths
%   - Dragging the first joint moves the entire pose
%   - Dragging other joints rotates downstream links
% ============================================================

function interactive_snake_fixed_links()
    %% PARAMETERS
    n_links = 8;                 % number of snake segments
    n_poses = 5;                 % number of poses
    linkLength = 0.05;           % fixed link length [m]

     % obstacles [x y radius]
    obstacles = [%0.3 0.2 0.05; 
                 0.6 0.14 0.06]; 
                 %0.78 0.2 0.04]; 
    colors = jet(n_poses);       % color map for poses

    % initialize snake poses (straight line along x-axis)
    snakePoses = cell(n_poses,1);
    for p = 1:n_poses
        x = (0:n_links-1)*linkLength+ones(1,8)*(((p-1)/(n_poses-1))-linkLength*7);
        y=0.02*sin(x*12*pi);
        %y = zeros(1,n_links);
        snakePoses{p} = [x(:), y(:)];
    end

    %% PLOT SETUP
    figure('Name','Adjust Snake Poses','Color','w'); 
    axis equal; grid on; hold on;
    xlim([-0.4 1.2]); ylim([-0.7 0.7]);
    xlabel('x [m]'); ylabel('y [m]');
    title('Adjust Snake Poses with Fixed Link Lengths');

    % Draw obstacles
    theta = linspace(0,2*pi,50);
    for i = 1:size(obstacles,1)
        fill(obstacles(i,1)+obstacles(i,3)*cos(theta), ...
             obstacles(i,2)+obstacles(i,3)*sin(theta), ...
             'b','FaceAlpha',0.3,'EdgeColor','b');
    end
    plot(0,0,'go','MarkerFaceColor','g','MarkerSize',8); % start
    plot(1,0,'ro','MarkerFaceColor','r','MarkerSize',8); % goal

    % Plot all poses
    hPlots = gobjects(n_poses,1);
    for p = 1:n_poses
        hPlots(p) = plot(snakePoses{p}(:,1), snakePoses{p}(:,2), '-o', ...
            'Color', colors(p,:), 'MarkerFaceColor', colors(p,:), ...
            'MarkerSize',6,'LineWidth',1.5);
    end

    %% INTERACTIVE DRAGGING
    disp('👉 Drag points to adjust. First joint moves whole pose, others rotate. Close window when finished.');

    set(gcf,'WindowButtonDownFcn',@mouseDown);
    set(gcf,'WindowButtonUpFcn',@mouseUp);

    dragging = false; poseIdx = []; pointIdx = []; prevMouse = [];

    function mouseDown(~,~)
        cp = get(gca,'CurrentPoint'); cp = cp(1,1:2);
        % find closest point among all poses
        minDist = inf;
        for p = 1:n_poses
            for i = 1:n_links
                d = norm(cp - snakePoses{p}(i,:));
                if d < minDist && d < 0.05 % tolerance
                    minDist = d;
                    poseIdx = p; pointIdx = i;
                end
            end
        end
        if minDist < inf
            dragging = true;
            prevMouse = cp;
            set(gcf,'WindowButtonMotionFcn',@mouseMove);
        end
    end

    function mouseMove(~,~)
        if ~dragging, return; end
        cp = get(gca,'CurrentPoint'); cp = cp(1,1:2);

        if pointIdx == 1
            % --- Case 1: Move entire pose ---
            delta = cp - prevMouse;
            snakePoses{poseIdx} = snakePoses{poseIdx} + delta;
            prevMouse = cp; % update reference
        else
            % --- Case 2: Rotate downstream links ---
            prevJoint = snakePoses{poseIdx}(pointIdx-1,:);
            dirVec = cp - prevJoint;
            if norm(dirVec) > 1e-6
                dirVec = dirVec / norm(dirVec); % unit vector
                newPos = prevJoint + linkLength*dirVec;
                snakePoses{poseIdx}(pointIdx,:) = newPos;

                % update downstream joints
                for j = pointIdx+1:n_links
                    prevJoint = snakePoses{poseIdx}(j-1,:);
                    dirVec = snakePoses{poseIdx}(j,:) - prevJoint;
                    dirVec = dirVec / norm(dirVec);
                    snakePoses{poseIdx}(j,:) = prevJoint + linkLength*dirVec;
                end
            end
        end

        % update plot
        set(hPlots(poseIdx),'XData',snakePoses{poseIdx}(:,1), ...
                            'YData',snakePoses{poseIdx}(:,2));
        drawnow;
    end

    function mouseUp(~,~)
        dragging = false;
        set(gcf,'WindowButtonMotionFcn','');
    end

    % Wait until the figure is closed
    waitfor(gcf);

    %% FINAL CLEAN PLOT
    figure('Name','Final Snake Poses','Color','w'); hold on; grid on; axis equal;
    xlim([-0.4 1.2]); ylim([-0.7 0.7]);
    xlabel('x [m]'); ylabel('y [m]');
    title('Final Snake Poses');

    % Obstacles
    for i = 1:size(obstacles,1)
        fill(obstacles(i,1)+obstacles(i,3)*cos(theta), ...
             obstacles(i,2)+obstacles(i,3)*sin(theta), ...
             'b','FaceAlpha',0.3,'EdgeColor','b');
    end
    plot(0,0,'go','MarkerFaceColor','g','MarkerSize',8);
    plot(1,0,'ro','MarkerFaceColor','r','MarkerSize',8);

    % Final poses (lines + small dots)
    for p = 1:n_poses
        plot(snakePoses{p}(:,1), snakePoses{p}(:,2), '-o', ...
            'Color', colors(p,:), ...
            'MarkerSize', 3, ...
            'MarkerFaceColor', colors(p,:), ...
            'LineWidth', 1.5);
    end
end
