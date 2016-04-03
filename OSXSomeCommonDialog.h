#include <vector>
#include <string>

namespace OSX
{
  int ShowDialogToSelectListOfString(std::vector<std::string>& list, const char* szPrompt="Please select one");
  int ShowDialogToEnterText(std::string& strDefaultAndResult, const char* szPrompt="Please enter text", const char* szWindowTitle="");
  int ShowDialogToEnterNumber(double& numberDefaultAndResult, double min, double max, const char* szPrompt="Please enter number");
}