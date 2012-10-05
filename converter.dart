#import("dart:io");

const int _MASK = 0xFF;
const int PIXEL_SIZE = 5;

/*
class Pixel {
  int x, y;
  String color;
  Pixel(this.x, this.y, this.color);
}

class Image {
  int height, width;
  List<Pixel> pixels;
}
*/
abstract class ImageReader {
  abstract void read(File imageFile);
}

class BMPReader extends ImageReader {
  
  const int HEADER1_DATA_STATE = 0;
  const int WIDTH_DATA_STATE = 1;
  const int HEIGHT_DATA_STATE = 2;
  const int HEADER2_DATA_STATE = 3;
  const int PIXEL_DATA_STATE = 4;  
  Map<int, int> chunksSize; 
  
  BMPReader(){
    chunksSize = new Map();
    chunksSize[HEADER1_DATA_STATE] = 18;
    chunksSize[HEIGHT_DATA_STATE] = 4;
    chunksSize[WIDTH_DATA_STATE] = 4;    
    chunksSize[HEADER2_DATA_STATE] = 28;
    chunksSize[PIXEL_DATA_STATE] = 3;    
  }
  
  void read(File imageFile){
    var inputStream = imageFile.openInputStream();
    ChunkedInputStream cis = new ChunkedInputStream(inputStream);
    var state = HEADER1_DATA_STATE;
    cis.chunkSize = chunksSize[state];
    int width, height, x, y;;
    cis.onData = () {
      List<int> buffer = cis.read();
      switch(state){
        case HEIGHT_DATA_STATE:
          height = _readInt(buffer);
          y = height-1;
          state++;
          break;
        case WIDTH_DATA_STATE:
          width = _readInt(buffer);
          x = 0;
          state++;
          break;
        case HEADER1_DATA_STATE:
        case HEADER2_DATA_STATE:
          state++;
          break;
        case PIXEL_DATA_STATE:
          String color = _readColor(buffer);
          print("${x*PIXEL_SIZE}px ${y*PIXEL_SIZE}px ${PIXEL_SIZE}px ${PIXEL_SIZE}px $color,");
          // Next position
          x++;
          if(x==width){
            print("\n");
            x = 0;
            y--; 
          }          
          break;          
      }
      cis.chunkSize = chunksSize[state];
    };
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
  var imageFileName = "vangogh.bmp";
  print("Convert $imageFileName");
  var imageFile = new File(imageFileName);
  var reader = new BMPReader();
  reader.read(imageFile);
}
