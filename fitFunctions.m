function models = fitFunctions(b,x)

    models = ...
        [b(2)+(b(1)-b(2))*((1+power(x*b(4),1-b(3))*sin(pi*b(3)/2))./(1+2*power(x*b(4),1-b(3))*sin(pi*b(3)/2)+power(x*b(4),2*(1-b(3))))) ...
        (b(1)-b(2))*power(x*b(4),1-b(3))*cos(pi*b(3)/2)./((1+2*power(x*b(4),1-b(3))*sin(pi*b(3)/2)+power(x*b(4),(2*(1-b(3))))))];
    
end
