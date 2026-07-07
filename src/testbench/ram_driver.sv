class ram_test_regression;
    ram_env env;
    virtual ram_if.DRV drv_vif;
    virtual ram_if.MON mon_vif;
    
    ram_transaction       normal_tx;
    ram_transaction_write write_tx;
    ram_transaction_read  read_tx;
    ram_transaction_oob   oob_tx;

    function new(virtual ram_if.DRV drv_vif, virtual ram_if.MON mon_vif);
        this.drv_vif = drv_vif;
        this.mon_vif = mon_vif;
    endfunction

    task run();
        env = new(drv_vif, mon_vif);
        
        normal_tx = new();
        write_tx  = new();
        read_tx   = new();
        oob_tx    = new();
        
        $display("\n==================================================");
        $display("             STARTING RAM REGRESSION              ");
        $display("==================================================");
        
        env.drv.init_reset();
        
        fork
            env.drv.drv();
            env.mon.run();
            env.ref_model.run();
            env.scb.run();
        join_none 
        
        $display("\n--- PHASE 1: NORMAL RANDOM TRAFFIC (20 txns) ---");
        env.gen.gen_traffic(200, normal_tx);
        
        $display("\n--- PHASE 2: WRITE-ONLY TRAFFIC (20 txns) ---");
        env.gen.gen_traffic(200, write_tx);
        
        $display("\n--- PHASE 3: READ-ONLY TRAFFIC (20 txns) ---");
        env.gen.gen_traffic(200, read_tx);
        
        $display("\n--- PHASE 4: OUT-OF-BOUNDS ADDRESSES (10 txns) ---");
        env.gen.gen_traffic(100, oob_tx);
        
        $display("\n--- PHASE 5: MID-SIMULATION RESET ---");
        env.drv.drv_reset();
        
        $display("\n--- PHASE 6: RECOVERY TRAFFIC (10 txns) ---");
        env.gen.gen_traffic(100, normal_tx);
        
        #50;
        env.scb.report();
        $display("\n==================================================");
        $display(" Overall Functional Coverage: %0.2f%%", env.drv.cg.get_coverage());
        $display("==================================================");
        $finish;
    endtask
endclass
