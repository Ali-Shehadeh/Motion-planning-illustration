%% ============================================================
% Energy and Contact Force with Obstacle Utilization at x=0.55
% ============================================================
clear; close all; clc;
%% PARAMETERS
n_links = 8;             % number of joints
n_steps = 200;           % discretization along trajectory
totalEnergy = 35;        % desired total energy (J)
contact_x = 0.55;        % normalized obstacle location
%% TRAJECTORY PARAM
t = linspace(0,1,n_steps);  % normalized trajectory progress
%% BASE ENERGY PATTERNS
E = zeros(n_links,n_steps);
for j = 1:n_links
    % baseline sinusoidal oscillation per joint with phase shift
    E(j,:) = abs(sin(2*pi*t + (j-1)*pi/8)) + 0.15*rand(1,n_steps);
end
%% ADD OBSTACLE SPIKE TO SPECIFIC JOINTS
[~, idx_contact] = min(abs(t - contact_x));
spike_profile = exp(-((1:n_steps)-idx_contact).^2 / (2*(5^2))); % Gaussian spike
spiked_joints = [3, 7]; % joints that get the spike
for j = spiked_joints
    E(j,:) = E(j,:) + 1.5*spike_profile;
end
%% REDUCE EFFORT AFTER CONTACT
E(:, idx_contact:end) = linspace(0.70,0.95,length(E(:, idx_contact:end) )) .* E(:, idx_contact:end);
%% NORMALIZE TOTAL ENERGY
E = E / sum(E(:)) * totalEnergy;
%% TOTAL ENERGY (sum over joints)
E_total = sum(E,1);
%% CONTACT FORCE MODEL
F_contact = zeros(1,n_steps);
F_contact(idx_contact) = 10; % Dirac-like spike at contact
F_contact = F_contact + 2*spike_profile; % smooth component
%% PLOTTING
figure('Name','Energy + Contact Force','Color','w'); hold on; grid on;
cmap = lines(n_links);
for j = 1:n_links
    plot(t, E(j,:), 'Color', cmap(j,:), 'LineWidth', 1.2, ...
        'DisplayName', sprintf('Joint %d', j));
end
plot(t, E_total, 'k-', 'LineWidth', 2, 'DisplayName', 'Total Energy');
yyaxis right
plot(t, F_contact, 'r--', 'LineWidth', 2, 'DisplayName', 'Avg. Contact Force');
ylabel('Contact Force [N]');
yyaxis left
xlabel('Normalized Trajectory Progress');
ylabel('Energy [J]');
title(sprintf('Energy & Contact Force with Obstacle Utilization (Total = %.1f J)', totalEnergy));
legend('show','Location','northoutside','Orientation','horizontal');
