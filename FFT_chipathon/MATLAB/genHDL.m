hdlcfg = coder.config('hdl');
hdlcfg.TargetLanguage = 'Verilog';
hdlcfg.InstantiateFunctions = true; 
%codegen -config hdlcfg myAdder -args {int16(0), int16(0)}
%codegen -config hdlcfg mySub -args {int16(0), int16(0)}
codegen -config hdlcfg myTop -args {int16(0), int16(0)}