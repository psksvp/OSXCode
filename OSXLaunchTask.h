/* Copyright (c) 1994-2004 Pongsak Suvanpong (psksvp@ccs.neu.edu).  
* All Rights Reserved.
*
* This computer software is owned by Pongsak Suvanpong, and is
* protected by U.S. copyright laws and other laws and by international
* treaties.  This computer software is furnished by Pongsak Suvanpong 
* pursuant to a written license agreement and may be used, copied,
* transmitted, and stored only in accordance with the terms of such
* license and with the inclusion of the above copyright notice.  This
* computer software or any other copies thereof may not be provided or
* otherwise made available to any other person.
*/

#ifndef __OSX_LAUNCH_TASK__
#define __OSX_LAUNCH_TASK__

namespace OSX
{
  void exitSystemUsingCocoa(void);
  int startSystemUsingCocoa( int argc, char** argv);
  int runCocoaEventLoop(int nLoop=5);
}

#endif
