#import("dart:html");

main(){
  print(query("#cssImage").classes);
  var fileInput = query("#image");
  fileInput.on.change.add((e) => loadFile(fileInput.files[0]));
}

loadFile(File file){
  print("loading...");
  var reader = new FileReader();
  reader.on.load.add((e) => readFile(reader.result));
  reader.readAsArrayBuffer(file);
}

readFile(ArrayBuffer buffer){
  print("Reading...");
  var array = new Uint8Array.fromBuffer(buffer);
  var width = _readInt(array.getRange(18, 4));
  var height = _readInt(array.getRange(22, 4));
  var current = 54;
  var pixelCount = 0;
  var pixelNbr = height * width;
  var outBuffer = new StringBuffer();
  for(int y = height - 1; y >= 0; y--){
    for(int x = 0; x < width; x++){
      var color = _readColor(array.getRange(current, 3));
      current+=3;
      pixelCount++;
      outBuffer.add("${x*5}px ${y*5}px 5px 5px $color");
      if(pixelCount != pixelNbr) {
        outBuffer.add(",");
      }
    }
  }
  query("#cssImage").style.boxShadow = outBuffer.toString();
}


int _readInt(List<int> b){
  var result = 0;
  result = b[0] & 255;
  result = result + ((b[1] & 255) << 8);
  result = result + ((b[2] & 255) << 16);
  result = result + ((b[3] & 255) << 24);
  return result;
}  

String _readColor(List<int> b){
  var red = _toHex(b[2]);
  var green = _toHex(b[1]);
  var blue = _toHex(b[0]);
  return "#$red$green$blue";
}

String _toHex(int val){
  var result = val.toRadixString(16);
  if(result.length == 1){
    result = "0$result";
  }
  return result;
}
