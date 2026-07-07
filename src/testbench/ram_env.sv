class ram_env;
    ram_generator       gen;
    ram_driver          drv;
    ram_monitor         mon;
    ram_reference_model ref_model;
    ram_scoreboard      scb;

    mailbox #(ram_transaction) gen2drv_mbx;
    mailbox #(ram_transaction) drv2ref_mbx;
    mailbox #(ram_transaction) mon2scr_mbx;
    mailbox #(ram_transaction) ref2scr_mbx;

    event sync_event;
    
    virtual ram_if.DRV drv_vif;
    virtual ram_if.MON mon_vif;

    function new(virtual ram_if.DRV drv_vif, virtual ram_if.MON mon_vif);
        this.drv_vif = drv_vif;
        this.mon_vif = mon_vif;

        gen2drv_mbx = new();
        drv2ref_mbx = new();
        mon2scr_mbx = new();
        ref2scr_mbx = new();

        gen       = new(gen2drv_mbx);
        drv       = new(gen2drv_mbx, drv2ref_mbx, drv_vif);
        mon       = new(mon2scr_mbx, mon_vif);
        ref_model = new(drv2ref_mbx, ref2scr_mbx);
        scb       = new(mon2scr_mbx, ref2scr_mbx);

        gen.drv_done = this.sync_event;
        drv.drv_done = this.sync_event;
    endfunction
endclass
