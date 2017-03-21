using PyCall
using PyConversions

@pyimport tensorflow as tf

# pyopen = pybuiltin("open")
# 
# @pywith pyopen("testfile", "w") opened_file begin
#     opened_file[:write]("testing") 
# end

a = tf.constant(1)
b = tf.constant(2)

expr = :(@pywith tf.Session() sess begin
    global c = sess[:run](tf.add(a,b))
end)


mac = macroexpand(expr)

eval(expr)



