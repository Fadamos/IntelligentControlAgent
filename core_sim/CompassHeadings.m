function Output = CompassHeadings(AgentsHeading)
% Author: Daniel Baxter
% LastModified: 12-July-2022
% Explanation: This function calculates the compass heading (N, NE, E, SE, S, SW, W, NW)

% Set headings to none for long enough for them to start moving

    % Convert the agent/s atan2 to a compass heading 
    if (-22.5 < AgentsHeading) && (AgentsHeading < 22.5)
        AgentsHeading = "East";

    elseif (22.5 < AgentsHeading) && (AgentsHeading < 67.5)
        AgentsHeading = "North East";

    elseif (67.5 < AgentsHeading) && (AgentsHeading < 112.5)
        AgentsHeading = "North";

    elseif (112.5 < AgentsHeading) && (AgentsHeading < 157.5)
        AgentsHeading = "North West";

    elseif (157.5 < AgentsHeading) && (AgentsHeading < 180)
        AgentsHeading = "West";

    elseif (-179.999 < AgentsHeading) && (AgentsHeading < -157.5)
        AgentsHeading = "West";

    elseif (-157.5 < AgentsHeading) && (AgentsHeading < -112.5)
        AgentsHeading = "South West";

    elseif (-112.5 < AgentsHeading) && (AgentsHeading < -67.5)
        AgentsHeading = "South";

    else (-67.5 < AgentsHeading) && (AgentsHeading < -22.5);
        AgentsHeading = "South East";
    end



Output = [AgentsHeading];