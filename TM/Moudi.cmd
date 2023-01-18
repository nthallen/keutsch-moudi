%{
  #ifdef SERVER
    void create_restart_file() {
      FILE *fp = fopen("restart.txt", "w");
      fprintf(fp, "Restart, please\n");
      fclose(fp);
    }
  #endif
%}

%INTERFACE(Tx) <UDPCmdTx>
&command
  : &^command
  ;

&^command
  : Create Restart File * { create_restart_file(); }
  ;
