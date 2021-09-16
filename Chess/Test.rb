board=[['bK','wK','wb','bb'],['wp','bp'],['wp','bk']]
board2=[['bK','wK','wb','bb'],['wp','bp']]
h ={}

h.default=0
h[board]+=1
h[board]+=1
h[board2]+=1
print h