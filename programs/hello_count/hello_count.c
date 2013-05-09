//
// bare-metal, no-libraries, counting hello world
//

//
// macros for volatile I/O pointers 
//
#define VP_32U(x)   ((volatile unsigned long  *)(x))
#define VP_16U(x)   ((volatile unsigned short *)(x))
#define VP_8U(x)    ((volatile unsigned char  *)(x))

//
// evb I/O register declarations
//
#define MA_UART         0xC0000000
#define MA_IO           0x80000000

#define MB_IO_TX_READY  0x00000080
#define MB_IO_RX_READY  0x00000040


void put_ch( char ch )
{
  register volatile unsigned long *uart_ptr = VP_32U(MA_UART);
  register volatile unsigned long *io_ptr   = VP_32U(MA_IO);

  while ( !(*io_ptr & MB_IO_TX_READY) ) 
    {};

  *uart_ptr = ch;

}

void put_str( char *cp )
{
  while (*cp)
  {
    put_ch(*cp);
    cp++;
  }
}

unsigned long decades[10] = 
{ 
            1,
           10,
          100,
         1000,
        10000,
       100000,
      1000000,
     10000000,
    100000000,
   1000000000
};

void put_ulong( unsigned long value )
{
    char buffer[12];

    int n;
    int i;
    int digit;

    unsigned long decade; 


    for ( i = 0, n = 11; n >= 0; n-- )
    {
      decade = decades[n];
      digit  = 0;

      while ( value >= decade ) 
      {
        value -= decade;
        digit++;
      }  

      if ( ( digit > 0 ) | ( n == 0 ) )
      {
        buffer[i] = '0' + digit;
        i++;
      }
    }

    buffer[i] = '\0';
    put_str(buffer);
}

void main()
{
  unsigned long i;

  for ( i = 0 ; i < 20; i++ )
  {
    put_str("Hello, World ");
    put_ulong(i);
    put_str("!\r\n");
  }

}
