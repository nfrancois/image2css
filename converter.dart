#import("dart:io");

const int _MASK = 0xFF;
const int PIXEL_SIZE = 5;

class Pixel {
  int x, y;
  String color;
  Pixel(this.x, this.y, this.color);
}

class Image {
  int height, width;
  List<Pixel> pixels;
}

abstract class ImageReader {
  abstract Image read(File imageFile);
}

class BMPReader extends ImageReader {
  
  Image read(File imageFile){
    var image = new Image();
    //print(imageFile.readAsBytesSync());
    var inputStream = imageFile.openInputStream();
    inputStream.onError = (e) => print(e);
    inputStream.onClosed = () => print("file is now closed");
    inputStream.onData = () {
      print(inputStream.available());
      inputStream.read(18);// data we don't care
      int width = _readInt(inputStream.read(4));
      int height = _readInt(inputStream.read(4));
      inputStream.read(28);// data we don't care
      //Lecture des données
      for(int y = height - 1; y >= 0; y--){
         for(int x = 0; x < width; x++){
          var color = _readColor(inputStream.read(3));
          print("${y*PIXEL_SIZE}px ${x*PIXEL_SIZE}px 4px ${PIXEL_SIZE}px $color,");
         }
       }      
      
    };
    return image;
  }
  
  int _readInt(List<int> b){
    var result = 0;
    result = b[0] & _MASK;
    result = result + ((b[1] & _MASK) << 8);
    result = result + ((b[2] & _MASK) << 16);
    result = result + ((b[3] & _MASK) << 24);
    return result;
  }  
  
  String _readColor(List<int> b){
    var red = b[2].toRadixString(16);
    var green = b[1].toRadixString(16);
    var blue = b[0].toRadixString(16);
    return "#$red$green$blue";
  }
  
  
}

class CssWriter {
  
}


main(){
  /*
  var args = new Options().arguments;
  if(args.isEmpty()){
    print("No param");
    return;
  }
  var imageFileName = args[0];
  */
  var imageFileName = "img24b.bmp";
  //var imageFileName = "me.bmp";
  print("Convert $imageFileName");
  var imageFile = new File(imageFileName);
  var reader = new BMPReader();
  reader.read(imageFile);
}
