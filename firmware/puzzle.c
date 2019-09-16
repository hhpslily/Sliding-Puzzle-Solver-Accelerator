#include "firmware.h"
void puzzle(void)
{
    //soft_puzzle();
    int cnt = 0, done = 0;
    int case_num = 10;
    hard_puzzle(case_num, 4); // choose test case
    for(int i=0; i<3; i++){
        for(int j=0; j<3; j++){
			done = hard_puzzle(i,j);  
		} 
    }
    while(done != 1){
        cnt++; 
        print_str("Step ");
        print_dec(cnt); 
        print_str("\n");
        hard_puzzle(0,3); //right
        hard_puzzle(1,3); //left
        hard_puzzle(2,3); //up
        done = hard_puzzle(3,3); //down                                 
    }
    print_str("solve puzzle ");
    print_dec(case_num);
    print_str(" in ");
    print_dec(cnt);
    print_str(" steps!!!");
}

void soft_puzzle()
{
    int right;
    int left;
    int up;
    int down;
    int lastcall = 0;
    int zerox = 0;
    int zeroy = 0;
    int count = 0;
    int goal [3][3];
    int initial[3][3];
    goal[0][0] = 1;
    goal[0][1] = 2;
    goal[0][2] = 3;
    goal[1][0] = 4;
    goal[1][1] = 5;
    goal[1][2] = 6;
    goal[2][0] = 7;
    goal[2][1] = 8;
    goal[2][2] = 0;
    initial[0][0] = 0;
    initial[0][1] = 2;
    initial[0][2] = 8;
    initial[1][0] = 5;
    initial[1][1] = 6;
    initial[1][2] = 3;
    initial[2][0] = 7;
    initial[2][1] = 1;
    initial[2][2] = 4;
    zerox = 0;
    zeroy = 0;

    int z = distance(initial);

    printboard(initial);

   while(z > 0)
   {

      right = 100;
      left = 100;
      up = 100;
      down = 100;


     if(zeroy != 2 && lastcall != 2)
     {
           right = rightmove(initial,zerox,zeroy);

     }
     if(zeroy !=0 && lastcall != 1)
     {
           left = leftmove(initial,zerox,zeroy);

     }
     if(zerox != 0 && lastcall !=3)
     {
           up = upmove(initial,zerox,zeroy);

     }
     if(zerox != 2 && lastcall != 4)
     {
           down = downmove(initial,zerox,zeroy);

     }
     //printf("%d %d %d %d",right, left, up, down);
        if(right ==left || right == up || right == down )
        {
            if(right%2 == 0)
                right = 100;
        }
        else if(left ==right || left == up || left == down )
        {
            if(left%2 == 0)
                left = 100;
        }
        else if(up ==right || up == left || up == down )
        {
            if(up%2 == 0)
             up = 100;
        }
        else if(down ==right || down == left || down == left )
        {
            if(down%2 == 0)
                down = 100;
        }

        //right
        if(right <= left && right <= up && right <= down)
        {


            int temp = initial[zerox][zeroy + 1];
            initial[zerox][zeroy + 1] = initial[zerox][zeroy];
            initial[zerox][zeroy] = temp;
            zeroy = zeroy + 1;
            lastcall = 1;


        }
        //down
        else if(down <= left && down <= up && down <= right)
        {
            int temp = initial[zerox+1][zeroy];
            initial[zerox +1][zeroy] = initial[zerox][zeroy];
            initial[zerox][zeroy] = temp;
            zerox = zerox + 1;
            lastcall = 3;
        }
        //left
        else if(left <= right && left <= up && left <= down)
        {

            int temp = initial[zerox][zeroy - 1];
            initial[zerox][zeroy - 1] = initial[zerox][zeroy];
            initial[zerox][zeroy] = temp;
            zeroy = zeroy - 1;
            lastcall = 2;

        }

        //up
        else if(up <= left && up <= right && up <= down)
        {
            int temp = initial[zerox-1][zeroy];
            initial[zerox - 1][zeroy] = initial[zerox][zeroy];
            initial[zerox][zeroy] = temp;
            zerox = zerox - 1;
            lastcall =4;
        }

        printboard(initial);
        z = distance(initial);
        count++;
        if(count == 100000)
        {
            z = -1;
        }

}

    if(z == 0)
    {  
        print_str("solve puzzle in ");
        print_dec(count);
    }
    return 0;
}
int distance(int array[][3])
{

    int MSum = 0;
    int x,y,value,targetX,targetY,dy,dx;
    for (x = 0; x < 3; x++){ //Transversing rows(i)
        for (y = 0; y < 3; y++) { //traversing colums (j)
        value = array[x][y]; // sets int to the value of space on board
            if (value != 0) { // Don't compute MD for element 0
                targetX = (value - 1) / 3; // expected x-coordinate (row)
                targetY = (value - 1) % 3; // expected y-coordinate (col)
                if(x > targetX)
                    dx = x - targetX; // x-distance to expected coordinate
                else 
                    dx = targetX - x;
                if(y > targetY)
                    dy = y - targetY; // y-distance to expected coordinate
                else
                    dy = targetY - y;
                MSum += dx + dy;
            }
        }

    }
    int m = MSum;
    return m;

}
int rightmove(int array[][3],int zerox,int zeroy)
{
   int arraycopy[3][3];
   for(int i=0; i<3; i=i+1){
       for(int j=0;j<3;j=j+1)
        arraycopy[i][j] = array[i][j];
   }
   int temp = arraycopy[zerox][zeroy+1];
   arraycopy[zerox][zeroy+1] = arraycopy[zerox][zeroy];
   arraycopy[zerox][zeroy] = temp;
  // zeroy = zeroy + 1;
   int z = distance(arraycopy);

   return z;
}

int leftmove(int array[][3],int zerox,int zeroy)
{
   int arraycopy[3][3];
    for(int i=0; i<3; i=i+1){
       for(int j=0;j<3;j=j+1)
        arraycopy[i][j] = array[i][j];
   }
   int temp = arraycopy[zerox][zeroy - 1];
   arraycopy[zerox][zeroy - 1] = arraycopy[zerox][zeroy];
   arraycopy[zerox][zeroy] = temp;
   int z = distance(arraycopy);
   return z;

}
int upmove(int array[][3],int zerox,int zeroy)
{
   int arraycopy[3][3];
    for(int i=0; i<3; i=i+1){
       for(int j=0;j<3;j=j+1)
        arraycopy[i][j] = array[i][j];
   }
   int temp = arraycopy[zerox-1][zeroy];
   arraycopy[zerox-1][zeroy] = arraycopy[zerox][zeroy];
   arraycopy[zerox][zeroy] = temp;
   int z = distance(arraycopy);
   return z;

}
int downmove(int array[][3],int zerox,int zeroy)
{
   int arraycopy[3][3];
    for(int i=0; i<3; i=i+1){
       for(int j=0;j<3;j=j+1)
        arraycopy[i][j] = array[i][j];
   }
   int temp = arraycopy[zerox+1][zeroy];
   arraycopy[zerox+1][zeroy] = arraycopy[zerox][zeroy];
   arraycopy[zerox][zeroy] = temp;
   int z = distance(arraycopy);

   return z;
}

void printboard(int array[][3])
{
  print_str("\n");
  for(int i =0; i <3;i++)
  {
    for(int j = 0; j <3;j++)
    {
        if(array[i][j] !=0)
        {
            print_dec(array[i][j]);
            print_str(" ");
        }
        else
            print_str(" ");
    }
    print_str("\n");
  }
  print_str("\n");
}
