class ram_reference_model;
    mailbox #(ram_transaction) drv2ref_mbx;
    mailbox #(ram_transaction) ref2scr_mbx;
    ram_transaction packet_ref;
    
    bit [7:0] mem [0:31];
    
    function new(mailbox #(ram_transaction) drv2ref_mbx, mailbox #(ram_transaction) ref2scr_mbx);
        this.drv2ref_mbx = drv2ref_mbx;
        this.ref2scr_mbx = ref2scr_mbx;
    endfunction
    
    task run();
        forever begin
            drv2ref_mbx.get(packet_ref);
            
            if (packet_ref.reset === 1'b0) begin
                packet_ref.data_out = 8'hzz;
		foreach(mem[i])begin
			mem[i]=0;
		end
            end
            else begin
                if (packet_ref.write_enb && !packet_ref.read_enb) begin
                    mem[packet_ref.address[4:0]] = packet_ref.data_in;
                    packet_ref.data_out = 8'hzz;
                end
                else if (packet_ref.read_enb && !packet_ref.write_enb) begin
                    packet_ref.data_out = mem[packet_ref.address[4:0]];
                end
                else begin
                    packet_ref.data_out = 8'hzz;
                end
            end
            ref2scr_mbx.put(packet_ref);
        end
    endtask
endclass
