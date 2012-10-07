#import("dart:html");

main(){
  var imageInput = query("#imageInput");
  var imageCss = query("#cssImage");
  new Converter(imageInput, imageCss);
}

class Converter {
  
  FileReader reader = new FileReader();
  Element imageInput;
  Element imageCss;
  
  Converter(this.imageInput, this.imageCss){
    _bind();
  }
  
  _bind(){
    imageInput.on.change.add((e) => _loadFile());
  }
  
  _loadFile(){
    var imageFile = imageInput.files[0];
    reader.on.load.add((e) => _readFile(reader.result));
    reader.readAsArrayBuffer(imageFile);    
  }
  
  _readFile(ArrayBuffer buffer){
    // TODO find type with header
    var array = new Uint8Array.fromBuffer(buffer);
    var signature = _readSignature(array);
    try {
      var imageReader = ImageReader.fromSignature(signature);
      var content = imageReader.read(array);
      _write(content);
    } on UnsupportedImageFormatException catch(uife){
      _unsupportedImageType();
    }
  }
  
  _readSignature(Uint8Array array){
    var imageHeader = array.getRange(0, 8);
    var signature = 0;
    for(int i=0; i<imageHeader.length; i++){
      signature = (signature << 8) + (imageHeader[i] & 255);
    }
    return signature;
  }

  _write(String boxShadowContent){
    imageCss.style.boxShadow = boxShadowContent;
  }
  
  _unsupportedImageType(){
    window.alert("Unsupported image type");
  }
  
}

/// A Image reader decode image 
abstract class ImageReader{
  
  static int BMP_HEADER = 4777534617194332160;// 0x424d663900000000;
  static int PNG_HEADER = 0x89504e470d0a1a0a;  
  
  abstract String read(Uint8Array array);
  
  static ImageReader fromSignature(int signature){
    if(signature == BMP_HEADER){
      return new BMPReader();
    }
    throw new UnsupportedImageFormatException();
  }
}

/// Cannot read this image
class UnsupportedImageFormatException implements Exception {
  const UnsupportedImageFormatException();
}


/// Image reader for BMP files
class BMPReader extends ImageReader {
  
  String read(Uint8Array array){
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
    return outBuffer.toString();    
  }
 
  int _readInt(List<int> bytes){
    var result = 0;
    for(int i=0; i<bytes.length; i++){
      result += ((bytes[i] & 255) << 8*i);
    }
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
  
}

