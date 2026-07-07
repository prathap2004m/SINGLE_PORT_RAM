interface ram_if(input bit clk);
    logic reset;
    logic [7:0] data_in;
    logic write_enb;
    logic read_enb;
    logic [7:0] address;
    logic [7:0] data_out;
    
    clocking DRV_cb @(posedge clk);
        default input #1step output #1;
        output reset, write_enb, read_enb, address, data_in;
    endclocking
    
    clocking MON_cb @(posedge clk);
        default input #1step output #1;
        input reset, write_enb, read_enb, address, data_in, data_out; 
    endclocking
    
    modport DRV(clocking DRV_cb);
    modport MON(clocking MON_cb);
endinterface
