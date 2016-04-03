#import "OSXVideoCapture.h"

@implementation OSXVideoCapture


-(NSString *)showDialogForUserToSelectDevice
{
  NSMutableString* strSrc = [[NSMutableString alloc] init];
  [strSrc appendString:@"choose from list{"];
  for(int i = 0; i < [mArrayOfDevicesOnThisMachine count]; i++)
  {
    [strSrc appendFormat:@"\"%@\"", [[mArrayOfDevicesOnThisMachine objectAtIndex:i] localizedDisplayName]];
    if(i != [mArrayOfDevicesOnThisMachine count] - 1)
      [strSrc appendString:@", "];
  }
  [strSrc appendString:@"} with prompt \"Please pick a video capture device\""];
  
  NSAppleScript* showUIScript = [[NSAppleScript alloc] initWithSource:strSrc];
  NSAppleEventDescriptor* result = [showUIScript executeAndReturnError:nil];
  //int resultIdx = [result int32Value];
  NSLog(@"++++user selected %@", [result stringValue]);
  NSString* strResult = [[NSString alloc] initWithString:[result stringValue]]; 
  [strSrc release];
  [showUIScript release];
  return [strResult autorelease];
}





-(BOOL)startWithDeviceAtIndex:(int)iDeviceIndex withImageWidth:(int)width andHeight:(int)height
{
  if(YES == bRunning)
  {
    NSLog(@"OSXVideoCapture Device is busy running!!");
    return NO;
  }
  
  if(iDeviceIndex >= [self cameraCount])
  {
    NSLog(@"OSXVideoCapture iDeviceIdx is out of range");
    return NO;
  } 
  mCaptureSession = [[QTCaptureSession alloc] init];
  
  QTCaptureDevice* device;
  if(-1 == iDeviceIndex) //default device
    device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
  else
    device = [mArrayOfDevicesOnThisMachine objectAtIndex:iDeviceIndex];
  NSError* error = nil;
  BOOL success = [device open:&error];
  if(NO == success)
  {
    [[NSAlert alertWithError:error] runModal];
    return NO;
  }
  
  // Add a device input for that device to the capture session
  mCaptureDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:device];
  success = [mCaptureSession addInput:mCaptureDeviceInput error:&error];
  if(!success) 
  {
    [[NSAlert alertWithError:error] runModal];
    return NO;
  }
  
  // Add a decompressed video output that returns raw frames to the session
  mCaptureDecompressedVideoOutput = [[QTCaptureDecompressedVideoOutput alloc] init];
  [mCaptureDecompressedVideoOutput setDelegate:self];
  if(width > 0 && height > 0)
  { 
    [mCaptureDecompressedVideoOutput setPixelBufferAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                               [NSNumber numberWithDouble:(double)width], (id)kCVPixelBufferWidthKey,
                                                               [NSNumber numberWithDouble:(double)height], (id)kCVPixelBufferHeightKey,
                                                               [NSNumber numberWithUnsignedInt:k24RGBPixelFormat], (id)kCVPixelBufferPixelFormatTypeKey,
                                                               nil]];                        //k32ARGBPixelFormat or
  }                                                                                       //k24RGBPixelFormat
  else
  {
    [mCaptureDecompressedVideoOutput setPixelBufferAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                               [NSNumber numberWithUnsignedInt:k24RGBPixelFormat], (id)kCVPixelBufferPixelFormatTypeKey,
                                                               nil]];
  }
  
  success = [mCaptureSession addOutput:mCaptureDecompressedVideoOutput error:&error];
  if(!success) 
  {
    [[NSAlert alertWithError:error] runModal];
    return NO;
  }
  
  mCurrentDeviceName = [NSString stringWithString:[device localizedDisplayName]];
  // Start the session
  [mCaptureSession startRunning];
  bRunning = YES;
  return YES;
}

-(int)startWithDeviceName:(NSString*)strName withImageWidth:(int)width andHeight:(int)height
{
  int iDeviceIndex = -1; //default device
  for(size_t i = 0; i < [mArrayOfDevicesOnThisMachine count]; i++)
  {
    NSString* s= [[mArrayOfDevicesOnThisMachine objectAtIndex:i] localizedDisplayName];
    NSRange r = [s rangeOfString:strName options:NSCaseInsensitiveSearch];
    if(NSNotFound != r.location)
    {
      iDeviceIndex = i;
      break;
    }
  }
  
  if(YES == [self startWithDeviceAtIndex:iDeviceIndex withImageWidth:width andHeight:height])
  {
    return iDeviceIndex;
  }
  else 
  {
    return -1;
  }

}

-(void)stop
{
  if(NO == bRunning)
    return;
  @synchronized (self) 
  {
    if(YES == [mCaptureSession isRunning])
      [mCaptureSession stopRunning];
    QTCaptureDevice *device = [mCaptureDeviceInput device];
    if(YES == [device isOpen])
      [device close]; 
    
    [mCaptureSession release];
    [mCaptureDeviceInput release];
    [mCaptureDecompressedVideoOutput release];
    bRunning = NO;
  }
}

-(void)captureOutput:(QTCaptureOutput *)captureOutput didOutputVideoFrame:(CVImageBufferRef)videoFrame withSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection
{
  // Store the latest frame
	// This must be done in a @synchronized block because this delegate method is not called on the main thread
  CVImageBufferRef imageBufferToRelease;
  
  CVBufferRetain(videoFrame);
  
  @synchronized (self) 
  {
    imageBufferToRelease = mCurrentImageBuffer;
    mCurrentImageBuffer = videoFrame;
  }
  
  CVBufferRelease(imageBufferToRelease);
}

////////////////////////////////////////////////
-(id)init
{
  [super init];
  mArrayOfDevicesOnThisMachine = [[NSMutableArray alloc] init];
  [mArrayOfDevicesOnThisMachine addObjectsFromArray:[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo]];
  bRunning = NO;
  NSLog(@"---------------->[OSXVideoCapture init]");
  return self;
}

-(void)dealloc
{
  [self stop];
  [mArrayOfDevicesOnThisMachine release];
  [super dealloc];
  NSLog(@"-----------------<[OSXVideoCapture dealloc]");
}

-(int)cameraCount
{
  return [mArrayOfDevicesOnThisMachine count];
}

-(BOOL)hasCamera
{
  return [self cameraCount] > 0 ? YES:NO;
}

-(NSString*)currentCameraName
{
  return mCurrentDeviceName;
}

-(NSString*)nameOfCameraWithId:(int)index
{
  if(index >= 0 && index < [mArrayOfDevicesOnThisMachine count] )
  {
    return [[mArrayOfDevicesOnThisMachine objectAtIndex:index] localizedDisplayName];
  }
  
  return nil;
}

-(int)startUsingGUIToSelectCamera
{
  return [self startWithDeviceName: [self showDialogForUserToSelectDevice]
                    withImageWidth: -1  
                         andHeight: -1]; //default with and height;
}

-(BOOL)startWithCameraId:(int)index
{
  return [self startWithDeviceAtIndex: index
                       withImageWidth: -1
                            andHeight: -1];
}

-(OSXRGB24ImagePtr)captureImage
{
  OSXRGB24ImagePtr image;
  image.data = NULL;
  image.dataLength = 0;
  image.width = 0;
  image.height = 0;
  
  if(NO == bRunning)
    return image;
  
  CVPixelBufferRef imageBuffer;  
  @synchronized (self) 
  {
    imageBuffer = (CVPixelBufferRef)CVBufferRetain(mCurrentImageBuffer);
  }
  
  
  
  if(imageBuffer) 
  {
    if(kCVReturnSuccess == CVPixelBufferLockBaseAddress(imageBuffer, 0))
    {
      void* pixels = CVPixelBufferGetBaseAddress(imageBuffer);
      size_t width = CVPixelBufferGetWidth(imageBuffer);
      size_t height = CVPixelBufferGetHeight(imageBuffer);
      size_t size = CVPixelBufferGetBytesPerRow(imageBuffer)  * height;
      
      image.dataLength = width*height*3;
      image.data = (unsigned char*)malloc(image.dataLength);
      image.width = width;
      image.height = height;
      image.bNeedToFreeData = true;
      memcpy(image.data, pixels, size); // k24RGB
      CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
    else
    {
      NSLog(@"Fail to lock imageBuffer");
    }
    
    CVBufferRelease(imageBuffer);
    
  } //if
  
  return image;
}


@end



/*
 - (void)initializeMovie {
 
 NSLog(@"Hi!");
 
 QTCaptureSession* mainSession = [[QTCaptureSession alloc] init];
 
 QTCaptureDevice* deviceVideo = [QTCaptureDevice defaultInputDeviceWithMediaType:@"QTMediaTypeVideo"];
 
 QTCaptureDevice* deviceAudio = [QTCaptureDevice defaultInputDeviceWithMediaType:@"QTMediaTypeSound"];
 
 NSError* error;
 
 [deviceVideo open:&error];
 [deviceAudio open:&error];
 
 QTCaptureDeviceInput* video = [QTCaptureDeviceInput deviceInputWithDevice:deviceVideo];
 
 QTCaptureDeviceInput* audio = [QTCaptureDeviceInput deviceInputWithDevice:deviceAudio];
 
 [mainSession addInput:video error:&error];
 [mainSession addInput:audio error:&error];
 
 QTCaptureMovieFileOutput* output = [[QTCaptureMovieFileOutput alloc] init];
 [output recordToOutputFileURL:[NSURL URLWithString:@"Users/chasemeadors/Desktop/capture1.mov"]];
 
 [mainSession addOutput:output error:&error];
 
 [movieView setCaptureSession:mainSession];
 
 [mainSession startRunning];
 
 }*/


