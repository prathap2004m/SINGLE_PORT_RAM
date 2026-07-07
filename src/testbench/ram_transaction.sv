class ram_transaction;
    rand bit [7:0] data_in;
    rand bit write_enb;
    rand bit read_enb;
    rand bit [7:0] address;
    
    logic [7:0] data_out; 
    bit reset = 1'b1;
    constraint c_address { address inside {[0:31]}; }
    virtual function ram_transaction copy();
        ram_transaction temp = new();
        temp.data_in   = this.data_in;
        temp.write_enb = this.write_enb;
        temp.read_enb  = this.read_enb;
        temp.address   = this.address;
        temp.reset     = this.reset;
        return temp;
    endfunction
endclass

class ram_transaction_write extends ram_transaction;
    constraint wr_rd_constraint { {write_enb, read_enb} == 2'b10; }
    virtual function ram_transaction copy();
        ram_transaction_write temp = new();
        temp.data_in   = this.data_in;
        temp.write_enb = this.write_enb;
        temp.read_enb  = this.read_enb;
        temp.address   = this.address;
        temp.reset     = this.reset;
        return temp;
    endfunction
endclass

class ram_transaction_read extends ram_transaction;
    constraint wr_rd_constraint { {write_enb, read_enb} == 2'b01; }
    virtual function ram_transaction copy();
        ram_transaction_read temp = new();
        temp.data_in   = this.data_in;
        temp.write_enb = this.write_enb;
        temp.read_enb  = this.read_enb;
        temp.address   = this.address;
        temp.reset     = this.reset;
        return temp;
    endfunction
endclass


class ram_transaction_oob extends ram_transaction;
    constraint c_address { address inside {[32:255]}; } 
    virtual function ram_transaction copy();
        ram_transaction_oob temp = new();
        temp.data_in   = this.data_in;
        temp.write_enb = this.write_enb;
        temp.read_enb  = this.read_enb;
        temp.address   = this.address;
        temp.reset     = this.reset;
        return temp;
    endfunction
endclass
