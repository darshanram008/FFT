function [addOut, subOut] = myTop(a, b)
%#codegen
addOut = myAdder(a, b);
subOut = mySub(a, b);
end

