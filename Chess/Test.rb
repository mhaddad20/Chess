require 'ruby2d'
set background: 'white'

def draw(x,y)
  r= Rectangle.new(
    x: 329, y: 229,
    width: 122, height: 42,
    color: 'black',
    )
  if r.contains?(x,y)
    print "ok"
  end
end


on :mouse_down do |event|
  draw(event.x,event.y)
end
show