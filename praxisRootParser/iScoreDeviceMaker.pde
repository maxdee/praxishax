


class DeviceMaker{
    JSONObject device;
    JSONArray deviceChildren;

    public DeviceMaker(){
        // make a i-Score device and add its settings
        device = new JSONObject();
        JSONObject deviceSettings = new JSONObject();
        deviceSettings.setString("Host", "127.0.0.1");
        deviceSettings.setInt("InputPort", 1234);
        deviceSettings.setString("Name", "generatedDevice");
        deviceSettings.setInt("OutputPort", 9997);
        deviceSettings.setString("Protocol", "9a42de4b-f6eb-4bca-9564-01b975f601b9");
        deviceChildren = new JSONArray();
        device.setJSONArray("Children", deviceChildren);
        device.setJSONObject("DeviceSettings", deviceSettings);
        saveJSONObject(device, "generatedDevice.device");
    }

    public void addFloat(String _path, String _name, float _min, float _max, float _def){
        JSONObject _child = new JSONObject();
        JSONObject _adr = new JSONObject();
        JSONObject _domain = new JSONObject();
        JSONObject _float = new JSONObject();
        _float.setFloat("Max", _max);
        _float.setFloat("Min", _min);
        _domain.setJSONObject("Float", _float);
        _adr.setJSONObject("Domain", _domain);
        _adr.setString("ClipMode", "Free");
        _adr.setString("Description", "");
        _adr.setString("Name", _name);
        _adr.setInt("Priority", 0);
        _adr.setBoolean("RepetitionFilter", true);
        _adr.setJSONArray("Tags", new JSONArray());
        _adr.setString("Type", "Float");
        _adr.setString("Unit", "None");
        _adr.setString("ioType", "->");
        _adr.setFloat("Value", _def);

        _child.setJSONObject("AddressSettings", _adr);
        _child.setJSONArray("Children", new JSONArray());

        // append it in
        JSONObject _propertyParent = getByPath(_path);
        _propertyParent.getJSONArray("Children").append(_child);
    }

    // get a json object by path name
    public JSONObject getByPath(String _path){
        String _split[] = split(_path.substring(1), '/');
        JSONObject _dir = device;
        for(String _str : _split){
            _dir = getNamedChild(_dir, _str);
        }
        return _dir;
    }

    // creates a child if not present
    public JSONObject getNamedChild(JSONObject _obj, String _name){
        JSONObject _out = null;
        JSONArray _siblings = _obj.getJSONArray("Children");
        for(int i = 0; i < _siblings.size(); i++){
            JSONObject _adr = _siblings.getJSONObject(i).getJSONObject("AddressSettings");
            if(_adr.getString("Name").equals(_name)){
                _out = _siblings.getJSONObject(i);
            }
        }
        if(_out == null){
            _out = addNamedChild(_obj, _name);
        }
        return _out;
    }

    public JSONObject addNamedChild(JSONObject _obj, String _name){
        JSONObject _child = new JSONObject();
        JSONObject _adr = new JSONObject();

        _adr.setString("ClipMode", "Clip");
        _adr.setString("Description", "");
        _adr.setJSONObject("Domain", new JSONObject());
        _adr.setString("Name", _name);
        _adr.setInt("Piority", 0);
        _adr.setBoolean("RepetitionFilter", true);
        _adr.setJSONArray("Tags", new JSONArray());
        _adr.setString("Type", "None");
        _adr.setString("Unit", "None");
        _adr.setString("Value", null);
        _adr.setString("ioType", ""); // or "<->"

        _child.setJSONObject("AddressSettings", _adr);
        _child.setJSONArray("Children", new JSONArray());
        _obj.getJSONArray("Children").append(_child);
        return _child;
    }

    public void save(String _fileName){
        saveJSONObject(device, _fileName);
    }
}
