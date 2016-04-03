namespace OSX
{
  void installKeyboardHandler();
  void removeKeyboardHandler();
  int waitForKeyPress();
  
  struct KeyboardInfo 
  {
    int code;
    char character;
  };
  
  KeyboardInfo waitForKeyboard();
}