class ram_scoreboard;
    mailbox #(ram_transaction) mon2scr_mbx;
    mailbox #(ram_transaction) ref2scr_mbx;
    
    ram_transaction packet_mon;
    ram_transaction packet_ref;
    
    int pass_count = 0;
    int fail_count = 0;
    int file_handle;

    function new(mailbox #(ram_transaction) mon2scr_mbx, mailbox #(ram_transaction) ref2scr_mbx);
        this.mon2scr_mbx = mon2scr_mbx;
        this.ref2scr_mbx = ref2scr_mbx;
        
        file_handle = $fopen("reports.txt", "w");
        if (file_handle == 0) $fatal("Failed to open reports.txt");
    endfunction
    
    task run();
        forever begin
            mon2scr_mbx.get(packet_mon);
            ref2scr_mbx.get(packet_ref);
            
            if (packet_mon.reset === 1'b0) begin
                if (packet_mon.data_out === 8'hZZ) begin
                    $fdisplay(file_handle, "[SCOREBOARD] [PASS] RESET active: Output High-Z | Reset: %b | W_EN: %b | R_EN: %b", 
                              packet_mon.reset, packet_mon.write_enb, packet_mon.read_enb);
                    pass_count++;
                end
                else begin
                    $fdisplay(file_handle, "[SCOREBOARD] [FAIL] RESET active: Expected 8'hZZ, but got %0h | Reset: %b", 
                              packet_mon.data_out, packet_mon.reset);
                    fail_count++;
                end
            end
            else begin
                if (packet_mon.data_out === packet_ref.data_out) begin
                    if (packet_mon.read_enb === 1'b1 && packet_mon.write_enb === 1'b0) begin
                        $fdisplay(file_handle, "[SCOREBOARD] [PASS] READ at Addr: %0d | Expected: %0h | Actual: %0h | Reset: %b | W_EN: %b | R_EN: %b", 
                                 packet_mon.address, packet_ref.data_out, packet_mon.data_out, packet_mon.reset, packet_mon.write_enb, packet_mon.read_enb);
                    end
                    else if (packet_mon.write_enb === 1'b1 && packet_mon.read_enb === 1'b0) begin
                        $fdisplay(file_handle, "[SCOREBOARD] [PASS] WRITE at Addr: %0d | Data: %0h | Reset: %b | W_EN: %b | R_EN: %b", 
                                 packet_mon.address, packet_mon.data_in, packet_mon.reset, packet_mon.write_enb, packet_mon.read_enb);
                    end
                    else begin
                        $fdisplay(file_handle, "[SCOREBOARD] [PASS] IDLE at Addr: %0d | Reset: %b | W_EN: %b | R_EN: %b", 
                                 packet_mon.address, packet_mon.reset, packet_mon.write_enb, packet_mon.read_enb);
                    end
                    pass_count++;
                end
                else begin
                    $fdisplay(file_handle, "[SCOREBOARD] [FAIL] Mismatch at Addr: %0d | Expected: %0h | Actual: %0h | Reset: %b | W_EN: %b | R_EN: %b", 
                           packet_mon.address, packet_ref.data_out, packet_mon.data_out, packet_mon.reset, packet_mon.write_enb, packet_mon.read_enb);
                    fail_count++;
                end
            end
        end
    endtask
    
    function void report();
        $fdisplay(file_handle, "==================================================");
        $fdisplay(file_handle, "            RAM SCOREBOARD FINAL REPORT           ");
        $fdisplay(file_handle, "==================================================");
        $fdisplay(file_handle, " Total Passed Comparisons : %0d", pass_count);
        $fdisplay(file_handle, " Total Failed Comparisons : %0d", fail_count);
        $fdisplay(file_handle, "==================================================");
        $fclose(file_handle);
    endfunction
endclass
