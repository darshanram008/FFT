function y = myAdder(a, b)
%#codegen
coder.inline('never');
temp = a + b;
y = temp;
end



