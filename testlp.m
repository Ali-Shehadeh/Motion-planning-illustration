a=[0,0]
b=[2,5]

    for k = 1:100  
       disp (k)
       lp1=abs(a(1)-b(1))^k
       lp2=abs(a(2)-b(2))^k
       lp=(lp1+lp2)^(1/k)
      
    end