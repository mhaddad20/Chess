array=[[0,6],[0,5],[1,0]]
valid=[[false,false],[true,false]]
for a in 0..1
  for b in 0..1
    if valid[a][b]
      if array.include?([a,b])
        print "yes"
      end
    end
  end
end