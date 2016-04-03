#ifndef __OSX_READ_IMAGE_FILE__
#define __OSX_READ_IMAGE_FILE__

#import "OSXRGB24ImagePtr.h"

enum eFileFormatType 
{
  eRv2XMLFile=0, ePNGFile, eBMPFile, eTIFFFile, eJPEGFile
};

class DynamicBuffer;
namespace OSX
{
  class ImageFileReaderWriter
  {
    MemoryLibrary::DynamicBuffer myRGBBuffer;
  public:
    ImageFileReaderWriter();
    ~ImageFileReaderWriter();
    OSXRGB24ImagePtr read(const char* szFilePath);
    OSXRGB24ImagePtr read(unsigned char* byteBuffer, int iBufferLength);
    bool write(OSXRGB24ImagePtr& img, const char* szPath, eFileFormatType iFileFormatType);
  };
  
  
}// namespace Rv2


#endif

