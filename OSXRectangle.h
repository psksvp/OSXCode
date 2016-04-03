#import <Foundation/Foundation.h>


namespace OSX
{
  struct Point :public NSPoint
  {
    
  };
  
  struct Size :public NSSize
  {
    
  };
  
  /////
  struct Rectangle :public NSRect
  {
    Point topLeft();
    Point topRight();
    Point bottomLeft();
    Point bottomRight();
    
    Point center();
    Point centerOfTopEdge();
    Point centerOfBottomEdge();
    Point centerOfLeftEdge();
    Point centerOfEightEdge();
  };
}//namespace OSX

