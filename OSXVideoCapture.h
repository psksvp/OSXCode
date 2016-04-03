#import <QTKit/QTKit.h>
#import <Cocoa/Cocoa.h>
#import "OSXRGB24ImagePtr.h"



@interface OSXVideoCapture : NSObject
{
  QTCaptureSession                    *mCaptureSession;
  QTCaptureDeviceInput                *mCaptureDeviceInput;
  QTCaptureDecompressedVideoOutput    *mCaptureDecompressedVideoOutput;
  
  NSMutableArray                      *mArrayOfDevicesOnThisMachine;
  CVImageBufferRef                    mCurrentImageBuffer;
  NSString*                           mCurrentDeviceName;
  BOOL                                bRunning;
}

-(int)cameraCount;
-(BOOL)hasCamera;
-(NSString*)currentCameraName;
-(NSString*)nameOfCameraWithId:(int)index;

-(int)startUsingGUIToSelectCamera; // return device idx if ok, otherwise return -1
-(BOOL)startWithCameraId:(int)index;
-(void)stop;

-(OSXRGB24ImagePtr)captureImage;
@end