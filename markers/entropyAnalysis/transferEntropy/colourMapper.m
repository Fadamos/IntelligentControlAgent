function result = colourMapper(TEdata, scale, element)

colMapper = zeros(length(TEdata),3);

for(i = 1:length(TEdata))
    if TEdata(i)' > 0
        colMapper(i,:) = scale*[1 0 0]; % red = positive 
    end
    if TEdata(i)' < 0
        colMapper(i,:) = scale*[0 0 1]; % blue = negative
    end
    if TEdata(i)' == 0
        colMapper(i,:) = [128/256 128/256 128/256]; % grey = zero
    end
    if isnan(TEdata(i)')
        colMapper(i,:) = [210/256 180/256 140/256]; % light color = NaN
    end
    
    result = colMapper(element,:);
end


% colMapper = (TEdata' > 0 .* [1 0 0]) + (TEdata' < 0) .* [0 0 1];
% colMapper = zeros(length(TEdata),3);
% for(i = 1:length(TEdata))
%    if TEdata(i)' > 0
%        colMapper(i,:) = [1 0 0];
%    end
%    if TEdata(i)' < 0
%        colMapper(i,:) = [0 0 1];
%    end
% end

% scatter(x(1:227,2),y(1:227,2), rescale(TEdata', 5, 100), TEdata, 'Filled')