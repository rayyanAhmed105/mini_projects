%% PROJECT
close all;
clear;
image = imread('Cereal_noise.png');
%% PART 1: CLEARNING IMAGE --------------------------------------------------------------------------------------------------------------------------------------
%% EXTRACT RGB CHANNELS 
figure;
fontSize = 15;
subplot(1, 5, 1);
imshow(image);
title('Original color Image', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'Position', get(0,'Screensize'));
RGB_color = {'Red','Green','Blue'};
channels={};
% Extract the individual red, green, and blue color channels.
for i=1:3
    channel = image(:,:,i);
    subplot(1,5,1+i)
    imshow(channel);
    channels{i}=channel;
    title(RGB_color{i}, 'FontSize', fontSize);
end
%
rgbFixed = cat(3, channels{1}, channels{2}, channels{3});
subplot(1, 5, 5);
imshow(rgbFixed);
title('Restored Image', 'FontSize', fontSize);
%% FFT of Images 
figure;setappdata(gcf, 'SubplotDefaultAxesLocation', [0, 0, 1, 1]); plot_counter =1; set(gcf, 'Position', get(0,'Screensize')); 
fontSize = 15;
plot_counter=1;
for i=1:3
    subplot(3,2,plot_counter);plot_counter=plot_counter+1;
    imshow(channels{i});
    title(RGB_color{i}+ "channel", 'FontSize', fontSize);
    subplot(3,2,plot_counter);plot_counter=plot_counter+1;
    %FFT
%     F=fft2(channels{i});
%     S=fftshift(log(1+abs(F)));
%     imshow(S,[]);
    frequencyImage = fftshift(fft2(channels{i}));
    amplitudeImage = log(abs(frequencyImage));
    Minimum = min(min(amplitudeImage));
    MaximumVal = max(max(amplitudeImage));
    imshow(amplitudeImage, []);
    title("FFT "+RGB_color{i}+ "channel", 'FontSize', fontSize);

end
%% creating NOTCH filters
%
sigma = 20;%25;%4
% Notch_Filters = notch('gaussian', PQ(1), PQ(2), sigma, 0, 0);
Notch_Filters = ones(size(frequencyImage));
for x_center_distance = 576:-100:0%(size(frequencyImage,2)/2)%-400 
H_positive = notch('gaussian', size(frequencyImage,1), size(frequencyImage,2), sigma, x_center_distance, round(size(frequencyImage,1)/2));
Notch_Filters = Notch_Filters.*H_positive;
if x_center_distance ~= 0
H_negative = notch('gaussian', size(frequencyImage,1), size(frequencyImage,2), sigma,- x_center_distance, round(size(frequencyImage,1)/2));
Notch_Filters = Notch_Filters.*H_negative;
end

end

figure;imshow(Notch_Filters); title('Gaussian Notch filters', 'FontSize', 25);

binaryImage = Notch_Filters <= 0.4;
[B,L] = bwboundaries(binaryImage);

%% APPLYING NOTCH FILTER 
figure;
setappdata(gcf, 'SubplotDefaultAxesLocation', [0, 0, 1, 1]); plot_counter =1; set(gcf, 'Position', get(0,'Screensize')); 
fontSize = 15;
plot_counter=1;
Filtered_channels={};
for i=1:1:3
    %show channel in spatial domain
    subplot(3,4,plot_counter);plot_counter=plot_counter+1;
    imshow(channels{i});
    title(RGB_color{i}+ " channel");
    %show channel FFT
    %FFT
    frequencyImage = fftshift(fft2(im2double(channels{i})));
    amplitudeImage = log(abs(frequencyImage));
    subplot(3,4,plot_counter);plot_counter=plot_counter+1;
    imshow(amplitudeImage, []);
    title(RGB_color{i}+ " channel FFT");
    %
    
    frequencyImage = frequencyImage.*Notch_Filters;
    amplitudeImage2 = log(abs(frequencyImage));
    Minimum = min(min(amplitudeImage2));
    MaximumVal = max(max(amplitudeImage2));
    subplot(3,4,plot_counter);plot_counter=plot_counter+1;
    imshow(amplitudeImage2, [Minimum MaximumVal]);impixelinfo;
    title(RGB_color{i}+ " channel filtered FFT");
    % IFFT show in spatial domain
    filteredImage = ifft2(fftshift(frequencyImage));
    amplitudeImage3 = abs(filteredImage);
    Minimum = min(min(amplitudeImage3));
    MaximumVal = max(max(amplitudeImage3));
    Filtered_channels{i}=amplitudeImage3;
    subplot(3,4,plot_counter);plot_counter=plot_counter+1;
    imshow(amplitudeImage3, [Minimum MaximumVal]);
    title(RGB_color{i}+ " channel filtered IFFT")     
end
%% Display removed regions
fontSize = 15;
plot_counter=1;
for i=1:1:3
    %show channel in spatial domain
    figure;
    F=fft2(im2double(channels{i}));
    Fc=fftshift(F);
    S1=log(abs(Fc));
    imshow(S1,[]); title(RGB_color{i}+ " channel filtered FFT");impixelinfo;
    hold on;
    for k=1:length(B)
      boundary = B{k};
      plot(boundary(:,2), boundary(:,1),...
        'r-', 'LineWidth', 0.5)
    end   
end
%%
figure;setappdata(gcf, 'SubplotDefaultAxesLocation', [0, 0, 1, 1]);
subplot(1, 2, 1);
imshow(rgbFixed);
title('Image', 'FontSize', fontSize);
rgbFixed_filtered = cat(3, Filtered_channels{1}, Filtered_channels{2}, Filtered_channels{3});
subplot(1, 2, 2);
imshow(rgbFixed_filtered);
title('Filtered Image', 'FontSize', fontSize);impixelinfo

