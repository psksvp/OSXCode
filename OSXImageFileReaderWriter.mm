#include "MemoryLibrary.h"
#include "OSXImageFileReaderWriter.h"
#include "OSXAutoReleasePool.h"
#include <Cocoa/Cocoa.h>
#include <ApplicationServices/ApplicationServices.h>
#include <string>

namespace OSX
{
  ImageFileReaderWriter::ImageFileReaderWriter()
  {
  }
  
  ImageFileReaderWriter::~ImageFileReaderWriter()
  {
  }
  
  OSXRGB24ImagePtr ImageFileReaderWriter::read(unsigned char* byteBuffer, int iBufferLength)
  {
    OSX::AutoReleasePool pool;
    
    //NSData* myImageData = [NSData dataWithBytesNoCopy:(void*)byteBuffer length:iBufferLength];
    
    NSImage *nsImage = [[NSImage alloc] initWithData:[NSData dataWithBytesNoCopy:(void*)byteBuffer 
                                                                          length:iBufferLength 
                                                                    freeWhenDone:NO]];
    if(nil != nsImage)
    {
      NSSize s = [nsImage size];
      
      OSXRGB24ImagePtr imagePtr;
      imagePtr.dataLength = s.width * s.height * 3;
      imagePtr.data = (unsigned char*)::malloc(imagePtr.dataLength);;
      imagePtr.width = s.width;
      imagePtr.height = s.height;
      imagePtr.bNeedToFreeData = true;
      
      
      NSUInteger bytesPerPixel = 4;
      NSUInteger bytesPerRow = bytesPerPixel * s.width;
      NSUInteger bitsPerComponent = 8;
      
      myRGBBuffer.Allocate(s.height * s.width * 4);
      
      unsigned char *rawData = (unsigned char*)myRGBBuffer.Ptr();
      
      CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
      CGContextRef context = CGBitmapContextCreate(rawData, s.width, s.height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
      
      [NSGraphicsContext saveGraphicsState];
      [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO]];
      [nsImage drawInRect:NSMakeRect(0,0, s.width, s.height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
      [NSGraphicsContext restoreGraphicsState];
      [nsImage release];
      CGContextRelease(context);
      CGColorSpaceRelease(colorSpace);
      
      
      unsigned char* destBuffer = imagePtr.data;
      int iCnt = 0;
      for(int y = 0; y < s.height; y++)
      {
        for(int x = 0; x < s.width; x++)
        {
          int byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
          destBuffer[iCnt] = rawData[byteIndex];           //red
          destBuffer[iCnt + 1] = rawData[byteIndex + 1];   //green
          destBuffer[iCnt + 2] = rawData[byteIndex + 2];   //blue
          iCnt += 3;
        }
      } 
      
      return imagePtr;
    }
    else
    {
      OSXRGB24ImagePtr imagePtr;
      imagePtr.data = NULL;
      return imagePtr;
    }

  }
  
  OSXRGB24ImagePtr ImageFileReaderWriter::read(const char* szFilePath)
  {
    OSX::AutoReleasePool pool;
    NSImage *nsImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithCString:szFilePath encoding:NSASCIIStringEncoding]];
    if(nil != nsImage)
    {
      NSSize s = [nsImage size];
      
      OSXRGB24ImagePtr imagePtr;
      imagePtr.dataLength = s.width * s.height * 3;
      imagePtr.data = (unsigned char*)::malloc(imagePtr.dataLength);;
      imagePtr.width = s.width;
      imagePtr.height = s.height;
      imagePtr.bNeedToFreeData = true;
      
      
      NSUInteger bytesPerPixel = 4;
      NSUInteger bytesPerRow = bytesPerPixel * s.width;
      NSUInteger bitsPerComponent = 8;
      
      myRGBBuffer.Allocate(s.height * s.width * 4);
      
      unsigned char *rawData = (unsigned char*)myRGBBuffer.Ptr();
      
      CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
      CGContextRef context = CGBitmapContextCreate(rawData, s.width, s.height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
      
      [NSGraphicsContext saveGraphicsState];
      [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO]];
      [nsImage drawInRect:NSMakeRect(0,0, s.width, s.height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
      [NSGraphicsContext restoreGraphicsState];
      [nsImage release];
      CGContextRelease(context);
      CGColorSpaceRelease(colorSpace);
      
      
      unsigned char* destBuffer = imagePtr.data;
      int iCnt = 0;
      for(int y = 0; y < s.height; y++)
      {
        for(int x = 0; x < s.width; x++)
        {
          int byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
          destBuffer[iCnt] = rawData[byteIndex];           //red
          destBuffer[iCnt + 1] = rawData[byteIndex + 1];   //green
          destBuffer[iCnt + 2] = rawData[byteIndex + 2];   //blue
          iCnt += 3;
        }
      } 
      
      return imagePtr;
    }
    else
    {
      OSXRGB24ImagePtr imagePtr;
      imagePtr.data = NULL;
      return imagePtr;
    }
  }
  
  bool ImageFileReaderWriter::write(OSXRGB24ImagePtr& img, const char* szPath, eFileFormatType iFileFormatType)
  {
    const char *szFileExt[] = {".xml", ".png", ".bmp", ".tiff", ".jpeg"};
    
    if(iFileFormatType <= 0 || iFileFormatType > 4)
    {
      //Debug::Error("Rv2::ImageFileReaderWriter::write unknown file type index->%d", iFileFormatType);
      return false;
    }
    
    
    unsigned char* pRGBBuffer = img.data;
    unsigned char* imageData[1];
    imageData[0] = pRGBBuffer;
    int width = img.width;
    int height = img.height;
    NSBitmapImageRep* myBitmapRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:imageData
                                                                            pixelsWide:width
                                                                            pixelsHigh:height
                                                                         bitsPerSample:8
                                                                       samplesPerPixel:3
                                                                              hasAlpha:NO 
                                                                              isPlanar:NO 
                                                                        colorSpaceName:NSCalibratedRGBColorSpace 
                                                                           bytesPerRow:width * 3 
                                                                          bitsPerPixel:24];
    if(nil != myBitmapRep)
    {
      NSBitmapImageFileType nsFileType = NSPNGFileType;
      switch(iFileFormatType)
      {
        case ePNGFile: nsFileType = NSPNGFileType; break;
        case eBMPFile: nsFileType = NSBMPFileType; break;
        case eTIFFFile: nsFileType = NSTIFFFileType; break;
        case eJPEGFile: nsFileType = NSJPEGFileType; break;
      }
      
      NSData* data = [myBitmapRep representationUsingType:nsFileType 
                                               properties:nil];
      std::string strOutputFilePath = szPath;
      strOutputFilePath += szFileExt[iFileFormatType];
      [data writeToFile:[NSString stringWithCString:strOutputFilePath.c_str() 
                                           encoding:NSASCIIStringEncoding]
             atomically: NO];
      
      [myBitmapRep release];
      return true;
    }
    else 
    {
      //Debug::Error("Rv2::ImageFileReaderWriter::write fail to allocate NSBitmapImageRep");
      return false;
    }

  }
} //namespace Rv2


