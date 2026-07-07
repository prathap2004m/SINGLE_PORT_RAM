module top;
    import ram_pkg::*;
    bit clk;
    always #10 clk = ~clk;
    
    ram_if vif(clk); 

    RAM DUT (
        .clk(vif.clk),
        .reset(vif.reset),
        .data_in(vif.data_in),
        .write_enb(vif.write_enb),
        .read_enb(vif.read_enb),
        .address(vif.address[4:0]),
        .data_out(vif.data_out)
    );
    
    ram_test_regression test;
    
    initial begin
        clk = 0;
        test = new(vif.DRV, vif.MON);
        test.run(); 
    end
endmodule
