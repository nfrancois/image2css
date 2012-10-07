#import("dart:html");

const BMP_HEADER = const [66, 77, 54, 108, 0];

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
    var imageHeader = array.getRange(0, 5);
    /// Ugly comparison
    if(imageHeader.toString() == BMP_HEADER.toString()){
      var imageReader = new BMPReader();
      var content = imageReader.read(array);
      _write(content);
    } else {
      _unsupportedImageType();
    }
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
  abstract String read(Uint8Array array);
}

//class UnsupportedImageFormatException implements Exception {
//  const UnsupportedImageFormatException();
//}


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
  
}
