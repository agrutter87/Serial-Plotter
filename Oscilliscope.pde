import processing.serial.*;

class Window                                                                                                                                                              //class Window
{
  // Properties
  int size_X; // width of window
  int size_Y; // height of window
  int pos_X; // position of window from left
  int pos_Y; // position of window from top
  int[] data;
  int[] timestamp;
  int[] graph;
  
  
  
  // Constructor
  Window(int layoutPosition)
  {
    size_X = int((width / numWindowsPerRow) - windowSpacing); // sets the width of the window to evenly space it to allow 'numWindowsPerRow' to fit smoothly
    size_Y = int(((height - 100) / numWindowsPerColumn) - windowSpacing); // sets the height of the window to evenly space it to allow 'numWindowsPerColumn' to fit smoothly while allowing 100px for buttons at the bottom
    data = new int[size_X];
    graph = new int[size_X];
    timestamp = new int[size_X];
    for(int i = 0; i < size_X; i++)
    {
      data[i] = 0;
      graph[i] = 0;
      timestamp[i] = 0;
    }
    for(int rowNumber = 1; rowNumber <= numWindowsPerColumn; rowNumber++) // loop determines window's position on screen based on the 'layoutPosition' and 'numWindowsPerColumn' variables
    {
      if(layoutPosition <=  rowNumber * numWindowsPerRow)
      {
        pos_X = int(borderSpacing + ((layoutPosition - (numWindowsPerRow * (rowNumber - 1) + 1)) * (size_X + windowSpacing)));
        pos_Y = int(borderSpacing + ((windowSpacing + size_Y) * (rowNumber - 1)));
        break;
      }
    }
  }
  // Functions
  void show() // function for drawing window to screen
  {
    fill(color(255,255,255)); // chooses the color white for the window background
    rect(pos_X, pos_Y, size_X, size_Y); // draws the window background as a rectangle
    for(int i = 0; i < (size_X - 1); i++)
    {
      stroke(0);
      graph[size_X - 1 - i] = int(map(data[size_X - 1 - i], 0, 255, 0, (size_Y - 1)));
      graph[size_X - 2 - i] = int(map(data[size_X - 2 - i], 0, 255, 0, (size_Y - 1)));
      line((pos_X + i),(pos_Y + size_Y - graph[size_X - 1 - i]),(pos_X + 1 + i),(pos_Y + size_Y - graph[size_X - 2 - i]));
    }
  }
}                                                                                                                                                                          //class Window
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
class Button                                                                                                                                                               //class Button
{
  //properties
  String label;
  int size_X;
  int size_Y;
  int pos_X;
  int pos_Y;
  Boolean disabled;
  
  
  
  //constructor
  Button(String Text, int layoutPosition)
  {
    size_X = int((width / 9) - 20);
    size_Y = 30;
    if(layoutPosition < 10)
    {
      pos_X = 10 + ((layoutPosition - 1) * (size_X + 20));
      pos_Y = int((height - 90));
    }
    if(layoutPosition > 9)
    {
      pos_X = 10 + ((layoutPosition - 10) * (size_X + 20));
      pos_Y = int((height - 40));
    }
    label = Text;
    disabled = false;
  }
  //functions
  void show()
  {
    fill(color(255,255,255));
    rect(pos_X, pos_Y, size_X, size_Y);
    fill(color(0,0,0));
    if(disabled) fill(color(128,128,128));
    textAlign(CENTER, CENTER);
    textSize(14);
    text(label, (pos_X +(size_X / 2)), (pos_Y + (size_Y / 2)));
  }
}                                                                                                                                                                         // class Button
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
int numWindows = 2;                                                                                                                                              
final int numButtons = 18;
int numWindowsPerRow = 2;
int numWindowsPerColumn = 1;
final int windowSpacing = 20;
final int borderSpacing = 10;
final String[] buttonLabel = { "Record", "Play" , "button3" , "button4" , "button5" , "button6" , "button7" , "button8" , "button9", 
                              "button10", "button11", "button12", "button13", "button14", "button15", "button16", "button17", "button18" };
Window[] window = new Window[numWindows];
Button[] button = new Button[numButtons];
Serial input = new Serial(this, Serial.list()[0], 9600);
OutputStream fileOutput;
InputStream fileInput;
int timesize;
boolean save = false;
boolean play = false;

void setup()                                                                                                                                                              // function setup()
{
  size(1200, 600);
  fileInput = createInput("output.txt");
  fileOutput = createOutput("output.txt");
  for(int i = 0; i < numWindows; i++)
  {
    window[i] = new Window(i + 1);
  }
  for(int i = 0; i < numButtons; i++)
  {
    button[i] = new Button(buttonLabel[i], i + 1);
  }
}                                                                                                                                                                        // function setup()
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
void draw()                                                                                                                                                              // function draw()
{
  if(input.available() > 0)
  {
    for(int i = (window[0].size_X - 1); i > 0; i--)
    {
      window[0].data[i] = window[0].data[i-1];
      window[0].timestamp[i] = window[0].timestamp[i-1];
    }
    timesize = input.read();
    window[0].timestamp[0] = 0;
    for(int i = 0; i < timesize; i++)
    {
      window[0].timestamp[0] = window[0].timestamp[0] + input.read();
    }
    //println(timesize);
    //println(window[0].timestamp[0]);
    //println(window[0].data[0]);
    window[0].data[0] = input.read();
    if(save)
    {
      try
      {
        fileOutput.write(timesize);
        fileOutput.write(window[0].timestamp[0]);
        fileOutput.write(window[0].data[0]);
      }
      catch(IOException e)
      {
        e.printStackTrace();
      }
    }
    if(play)
    {
      for(int i = (window[1].size_X - 1); i > 0; i--)
      {
        window[1].data[i] = window[1].data[i-1];
        window[1].timestamp[i] = window[1].timestamp[i-1];
      }
      try
      {
        timesize = fileInput.read();
      }
      catch(IOException e)
      {
        e.printStackTrace();
      }
      window[1].timestamp[0] = 0;
      for(int i = 0; i < timesize; i++)
      {
        try
        {
          window[1].timestamp[0] = window[1].timestamp[0] + fileInput.read();
        }
        catch(IOException e)
        {
          e.printStackTrace();
        }
      }  
      try
      {
        window[1].data[0] = fileInput.read();
      }
      catch(IOException e)
      {
        e.printStackTrace();
      }
    }
    input.write('G');
  }
  background(0);
  for(int i = 0; i < numWindows; i++)
  {
    window[i].show();
  }
  for(int i = 0; i < numButtons; i++)
  {
    button[i].show();
  }  
}                                                                                                                                                                    // function draw()
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
void mouseClicked()                                                                                                                                                  // function mouseClicked()
{
  int windowClicked = -1;
  int buttonClicked = -1;
  for(int i = 0; i < numWindows; i++)
  {
    if((mouseY >= (window[i].pos_Y)) && (mouseY <= (window[i].pos_Y + window[i].size_Y)) && (mouseX >= window[i].pos_X) && (mouseX <= (window[i].pos_X + window[i].size_X))) windowClicked = i;
    if(windowClicked >= 2)
    {
      button[i].label = "Window Clicked";
      windowClicked = -1;
    }
  }
  for(int i = 0; i < numButtons; i++)
  {
    if((mouseY >= (button[i].pos_Y)) && (mouseY <= (button[i].pos_Y + button[i].size_Y)) && (mouseX >= button[i].pos_X) && (mouseX <= (button[i].pos_X + button[i].size_X))) buttonClicked = i;
    if(buttonClicked >= 2)
    {
      button[i].label = "I feel violated..";
      buttonClicked = -1;
    }
    else if(buttonClicked == 0)
    {
      if(!save)
      {
        fileOutput = createOutput("output.txt");
        save = true;
        button[0].label = "Stop";
      }
      else
      {
        save = false;
        button[0].label = "Record";
        if(button[1].label == "Stop recording!") button[1].label = "Play";
      }
      buttonClicked = -1;
    }
    else if(buttonClicked == 1)
    {
      if(!play)
      {
        if(save)
        {
          button[1].label = "Stop recording!";
        }
        else
        {
          fileInput = createInput("output.txt");
          play = true;
          button[1].label = "Stop";
        }
      }
      else
      {
        play = false;
        button[1].label = "Play";
      }
      buttonClicked = -1;
    }
  }
}

