class ram_monitor;
    mailbox #(ram_transaction) mon2scr_mbx;
    virtual ram_if.MON ram_vif;
    ram_transaction packet_mon;
    ram_transaction prev_packet;

    function new(mailbox #(ram_transaction) mon2scr_mbx, virtual ram_if.MON ram_vif);
        this.ram_vif = ram_vif;
        this.mon2scr_mbx = mon2scr_mbx;
        this.prev_packet = null;
    endfunction
    
    task run();
        @(ram_vif.MON_cb);
        forever begin
            @(ram_vif.MON_cb);
            packet_mon = new();
            packet_mon.reset     = ram_vif.MON_cb.reset;
            packet_mon.address   = ram_vif.MON_cb.address;
            packet_mon.data_in   = ram_vif.MON_cb.data_in;
            packet_mon.write_enb = ram_vif.MON_cb.write_enb;
            packet_mon.read_enb  = ram_vif.MON_cb.read_enb;
            
            if (prev_packet != null) begin
                prev_packet.data_out = ram_vif.MON_cb.data_out;
                mon2scr_mbx.put(prev_packet);
            end
            prev_packet = packet_mon;
        end    
    endtask
endclass
