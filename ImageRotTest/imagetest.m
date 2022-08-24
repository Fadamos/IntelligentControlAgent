function imagetest(directionx,directiony)

ImageWidth = 20;
x = 10;
y = 10;

[DogImg,~,DogM] = imread('f35.png');
DogImg = imresize(DogImg,[7.64, 11], 'lanczos3');
DogM = imresize(DogM,[7.64, 11], 'lanczos3');


% [BoidImage, ~, BoidAlpha]   = imread(['f35.png']);
% BoidImage = imresize(BoidImage, [ImageWidth ImageWidth], 'lanczos3' );
% BoidAlpha = imresize(BoidAlpha, [ImageWidth ImageWidth], 'lanczos3' );

quiver(x,y,directionx,directiony);

axis([-100 100 -100 100]);

hold on
Theta = asin(abs(directionx / (0.01 + norm([directionx,directiony])))) * 180 / pi;

if directionx > 0
    if directiony < 0
        Theta = - Theta;
    end
else
    if directiony > 0
        Theta = 180 - Theta;
    else
        Theta = 180 + Theta;
    end
end


angle = Theta - 180;        
img_i = imrotate(DogImg, angle );
alpha_i = imrotate(DogM, angle );

ImageHandler=image(x-ImageWidth, y-ImageWidth, img_i);
ImageHandler.AlphaData = alpha_i;