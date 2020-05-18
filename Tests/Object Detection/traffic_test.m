function [new_image] = traffic_test()
   
    a = imread('slow_traffic.PNG');
    a = rgb2gray(a);
    a = imbinarize(a);
    b = imread('busy_traffic.PNG');
    b = rgb2gray(b);
    b = imbinarize(b);
      
    x = size(a);
    
    for i=1:x(1)
        for j=1:x(2)
            if a(i,j) ~= b(i,j)
                a(i,j) =  b(i,j);
            else
                a(i,j) = 0;
            end
        end
    end
    
    sedisk = strel('disk',2);
    better_a = imopen(a,sedisk);
    imshow(better_a);
end
                