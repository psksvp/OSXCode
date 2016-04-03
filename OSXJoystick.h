#ifndef __OSX_JOY_STICK__
#define __OSX_JOY_STICK__

#include <vector>
#include <string>

namespace OSX
{  
  enum JoystickHatsPosition 
  {
    eHatCenter=0,
    eHatUp,
    eHatDown,
    eHatRight,
    eHatLeft,
    eHatRightUp,
    eHatRightDown,
    eHatLeftUp,
    eHatLeftDown
  };
  
  struct Joystick
  {
    unsigned long iD;
    std::string name;
    int numberOfAxis;
    int numberOfHats;
    int numberOfBalls;
    int numberOfButtons;
  
    std::vector<int> axisDataVector;
    std::vector<bool> buttonDataVector;
    std::vector<JoystickHatsPosition> hatDataPositionVector;
    
    void update();
    
    Joystick()
    {
      iD = -1;
    }
  };
  
  int joystickCount();
  std::string joystickName(int idxOfWhich);
  
  
  
  OSX::Joystick* connectToJoystick(int idxOfWhich);
  void disconnectFromJoystick(OSX::Joystick* j);
} // namespace



#endif