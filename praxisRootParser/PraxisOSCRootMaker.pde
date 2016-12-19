class PraxisOSCRootMaker {
    PrintWriter oscRoot;
    int propertyCount = 0;

    public PraxisOSCRootMaker(String _rootName){
        oscRoot = createWriter(_rootName);
        oscRoot.println("@ /uzlive_osc root:osc {"); //  will need to be configured
        oscRoot.println("  #%pxr.format 2");
        oscRoot.println("  .port "+1234);
    }

    public void addOSCProperty(String _line, String _path){
        oscRoot.println("  @ ./prop" + (propertyCount++) + " osc:input {");
        String _split[] = split(_line, ' ');
        oscRoot.println("    .address "+_path+"."+_split[_split.length-1].replace(";",""));
        oscRoot.println("    .osc-address "+_path+"/"+_split[_split.length-1].replace(";",""));
        oscRoot.println("  }");
    }

    public void save(){
        oscRoot.println("}");
        oscRoot.flush();
        oscRoot.close();
    }
}
