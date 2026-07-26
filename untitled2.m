%% ============================================================
% Energy Distribution Plot for Snake Locomotion
% ============================================================

clear; close all; clc;

%% PARAMETERS
n_links = 8;           % number of joints
n_steps = 200;         % discretization along trajectory
totalEnergy = 38.7;    % desired total energy (J)

%% GENERATE SYNTHETIC JOINT ENERGY USAGE
t = linspace(0,1,n_steps);  % normalized trajectory progress

% base oscillatory patterns for each joint (like traveling wave)
E = zeros(n_links,n_steps);
for j = 1:n_links
    E(j,:) = abs(sin(2*pi*t + (j-1)*pi/6)) + 0.3*rand(1,n_steps);
end

% Normalize so that total energy = 38.7 J
E = E / sum(E(:)) * totalEnergy;

% Total per-step energy
E_total = sum(E,1);

%% PLOTTING
figure('Name','Energy Usage','Color','w'); hold on; grid on;
cmap = lines(n_links);

% plot per-joint energy
for j = 1:n_links
    plot(t, E(j,:), 'Color', cmap(j,:), 'LineWidth', 1.2, ...
        'DisplayName', sprintf('Joint %d', j));
end

% plot total energy
plot(t, E_total, 'k-', 'LineWidth', 2, 'DisplayName','Total');

xlabel('Normalized trajectory progress');
ylabel('Energy [J]');
title(sprintf('Energy Distribution per Joint (Total = %.1f J)', totalEnergy));
legend('show','Location','northoutside','Orientation','horizontal');
