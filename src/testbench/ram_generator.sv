class ram_generator;
    mailbox #(ram_transaction) gen2drv_mbx;
    ram_transaction blueprint; 
    event drv_done;

    function new(mailbox #(ram_transaction) gen2drv_mbx);
        this.gen2drv_mbx = gen2drv_mbx;
        this.blueprint = new(); 
    endfunction  
    
    task gen_traffic(int count, ram_transaction custom_blueprint = null);
        ram_transaction packet;
        if (custom_blueprint != null) this.blueprint = custom_blueprint;

        repeat(count) begin
            packet = blueprint.copy(); 
            if(!packet.randomize()) $fatal("Randomization failed");    
            gen2drv_mbx.put(packet);
            @(drv_done);
        end    
    endtask
endclass
