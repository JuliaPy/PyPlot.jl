using PyPlot, Base.Test, PyCall

#Checking if there's a GUI
@test typeof(pygui()) == Symbol
pygui(false)
pygui(true)

#Plotting  
quiver(1:10,1:10)
xlabel("thing")
ylabel("blah")
plot(1:10, 1:10)
plot(1:10, 1:10, "r+")
f = plot(1:10, 1:10, "bo")
plot3D(1:10, 1:10)
mesh(1:100,1:100,1:100)
surf(rand(3,3))
surf(rand(3,3), rand(3,3), rand(3,3))
mesh(rand(3,3))
bar(["a", "b"], [1, 2])
bar([:a, :b], [1, 2])

#Figure utils
a = Figure(f[1])
@test isempty(figure())
b = figure()
@test !(a == b)
hash(a)
c = PyObject(rand(10))
@test !(a == c)
@test !(c == a)
@test haskey(a, "a") == false
a[:set_url] = 1
close(:a)

#Show images
a = rand(Int8, 100, 100)
a = abs(a)
imshow(a)

#ColorMaps
c = get_cmaps()
@test length(c) > 1
get_cmap()
b = ColorMap("Blues")
imshow(a,b)
t = ColorMap("thing", rand(3,3))
imshow(a,t)
t = ColorMap("thing", rand(4,4))
imshow(a,t)
ColorMap("thing", fill((1,2,3),100*100), fill((1,2,3),100*100), fill((1,2,3),100*100))
c1 = ColorMap("thing", fill((1,2,3),100*100), fill((1,2,3),100*100), fill((1,2,3),100*100), fill((1,2,3),100*100))
c2 = ColorMap(rand(3,3))
@test !(c1 == c2)
c3 = PyObject(c2)
@test !(c1 == c3)
@test !(c3 == c1)
hash(c1)
@test !haskey(c1, "c")
keys(c1)
@show c1
c1[:set_over]
c1[:set_over] = 1
a1 = c[1:5]
get_cmap(a1[1])
get_cmap("Accent", 1)
register_cmap("thing", a1[1])

#Save Image
imsave("a.svg", a)

#MIME thing
io = IOBuffer()
m = MIME{symbol("image/svg+xml")}()
t = ColorMap("Blues")
writemime(io, m, t)

#Spy plot sparse matrix
a = spdiagm(1:100)
spy(a)

#Different backends
pygui(:wx)
plot(1:100,1:100)
pygui(:gtk)
plot(1:100,1:100)
pygui(:qt)
plot(1:100,1:100)

#Try another backend
workspace()
using PyCall
PyCall.pygui(:qt)
using PyPlot
plot(1:100,1:100)

#Some other internal stuff
PyPlot.svg()
PyPlot.svg(true)
PyPlot.pushclose(figure())
PyPlot.display_figs()
PyPlot.force_new_fig()
PyPlot.show()

#Final internal calls
PyPlot.monkeypatch()
PyPlot.draw_if_interactive()

PyPlot.close_queued_figs()
