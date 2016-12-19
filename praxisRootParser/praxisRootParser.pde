// Convert a Prxis LIVE root to a OSC root with all Properties and a .device file for i-Score
// Supply a .pxr here
String pxrFile = "/home/mxd/PraxisProjects/userZeroLive/uzlive_video.pxr";
// a corresponding auto_root.pxr and praxis_root.device while be generated


PrintWriter atLines;
int currentDepth = 0;
int codeSectionDepth = 0;
ArrayList<String> currentPath;
String previousLine = "";

DeviceMaker iScoreDevice;
PraxisOSCRootMaker oscRoot;

void setup(){
    currentPath = new ArrayList<String>();
    atLines = createWriter("atLines.txt");
    oscRoot = new PraxisOSCRootMaker("auto_root.pxr");
    iScoreDevice = new DeviceMaker();

    parseRoot(pxrFile);

    atLines.flush();
    atLines.close();
    oscRoot.save();
    iScoreDevice.save("praxis_root.device");

    exit();
}

void parseRoot(String _file){
    String _lines[] = loadStrings(_file);
    String _combine = "";
    for(String _line : _lines){
        //
        if(_line.contains("  .code ")){
            codeSectionDepth = currentDepth+2;
        }
        else if(_line.equals("\"")){
            codeSectionDepth = 0;
        }

        if(_line.contains("@")){
            if(!_line.contains(";")){
                _combine = _line;
            }
            else{
                _combine = "";
                processAtLine(_line);
            }
        }
        else if(!_combine.equals("")){
            processAtLine(_combine + _line);
            _combine = "";
        }
    }
}

void processAtLine(String _line){
    int _depth = checkDepth(_line);

    if(codeSectionDepth != 0) _depth = codeSectionDepth;
    // _depth /= 2;
    atLines.println(_depth+"_"+_line);
    if(_depth != currentDepth){
        if(_depth > currentDepth){
            currentPath.add(getPath(previousLine));
        }
        else if(_depth < currentDepth){
            for(int i = 0; i < (currentDepth - _depth)/2; i++)
                currentPath.remove(currentPath.size() -1 );
        }
        currentDepth = _depth;
    }
    // add the property
    if(_line.contains("@P(") && !_line.contains("@ReadOnly")){
        addProperty(_line.trim(), getCurrentPath());
    }
    previousLine = _line;
}


void addProperty(String _line, String _path){
    if(_line.contains("@Type.Number")){
        oscRoot.addOSCProperty(_line, _path);
        iScoreDevice.addFloat(getCurrentPath(),
                                    getName(_line),
                                    getMin(_line),
                                    getMax(_line),
                                    getDef(_line));
    }
}

String getCurrentPath(){
    String _p = "";
    for(String _s : currentPath){
        _p+=_s;
    }
    return _p;
}

int checkDepth(String _s){
    int _cnt = 0;
    for(char _c : _s.toCharArray()){
        if(_c == ' ') _cnt++;
        else break;
    }
    return _cnt;
}

String getPath(String _line){
    String _seperated[] = split(_line.trim(), ' ');
    for(String _s : _seperated){
        if(_s.length() > 2){
            if(_s.charAt(0) == '.') return _s.substring(1);
            else if(_s.charAt(0) == '/') return _s;
        }
    }
    return "";
}

// parse property lines
String getName(String _line){
    String _split[] = split(_line, ' ');
    return _split[_split.length-1].replace(";","");
}
float getMin(String _line){
    String _split[] = split(_line.replace("(", "_").replace(")", "_").replace(",", "_"), '_');
    for(String _str : _split){
        if(_str.contains("min")){
            String[] _s = split(_str, ' ');
            return float(_s[_s.length-1]);
        }
    }
    return 0;
}
float getMax(String _line){
    String _split[] = split(_line.replace("(", "_").replace(")", "_").replace(",", "_"), '_');
    for(String _str : _split){
        if(_str.contains("max")){
            String[] _s = split(_str, ' ');
            return float(_s[_s.length-1]);
        }
    }
    return 1;
}
float getDef(String _line){
    String _split[] = split(_line.replace("(", "_").replace(")", "_").replace(",", "_"), '_');
    for(String _str : _split){
        if(_str.contains("def")){
            String[] _s = split(_str, ' ');
            return float(_s[_s.length-1]);
        }
    }
    return 0.5;
}
