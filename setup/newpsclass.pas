{ Don Whitbeck 2010 - Basic class for postscript output
}
unit newpsclass;
//{$linklib c}
{$mode objfpc} 
interface
 uses BaseUnix, unixtype,initc, errors, sysutils, classes, strings, ctypes, db, sqldb;

const 
  CR = #13;
  LF = #10;
  FATFONT = 0.5;
  JUSTIFYLEFT = 0;
  JUSTIFYCENTER = 1;
  JUSTIFYRIGHT = 2;
  TIMESROMAN = 'Times-Roman';
  TIMESITALIC = 'Times-Italic';
  TIMESBOLD = 'Times-Bold';
  HELVETICA = 'Helvetica';
  HELVETICAITALIC = 'Helvetica-Italic';
  HELVETICABOLD = 'Helvetica-Bold';
  HELVETICACONDENSED = 'Helvetica-Condensed';
  POINTS = 72.0;


  BOXLINEALL = 15;
  BOXLINENONE = 0;
  BOXLINELEFT = 1;
  BOXLINETOP = 2;
  BOXLINERIGHT = 4;
  BOXLINEBOTTOM = 8;

  PORTRAIT = 0;
  LANDSCAPE = 1;

Type
	PTab = ^TTab;                  //A pointer to a tab
	TTab = record
	  XPos:         Integer;       //tab stop - use integers to reduce conversions
	  justifyText:  Integer;
	  BoxWidth:     Integer;       //width of this tab box
	  Margin:       Integer;       //Distance from lefte tab edge and start of text
	  BShade:       byte;          //Shadeing in box 
	  BLines:       byte;          //Box lines
	  Next:         PTab;
	  Prev:         PTab;
	end;  
     
Type
    PTabList = ^TTabList;            //A pointer to a linked list of tabs
	TTabList = record
	  TabIndex:  integer;
	  TabCount:  integer;     //Number of tabs in this list
	  boxHeight: integer;     //All boxes in these tab list are this high
	  TabPos:    PTab;        //Current tab in list	  
	  TabHead:   PTab;        //Pointer to first tab in this tab list
	  TabTail:   PTab;        //Pointer to last tab in this tab list
end;

Type
  TTabsArray = array [1..10] of PTabList;

Type
  PFontType = ^FontType;
  FontType = record
    FontName: String;
    FontSize: Integer;
  end;


Type
  TFontArray = array [1..10] of PFontType;

  TPostscriptClass = class(TObject)
  private
	  fTabArray         : TTabsArray;
          fFontArray        : TFontArray;
	  fTabArrayIndex    : Integer;
	  fCurrentX         : Integer;    //Page Cursor
          fCurrentY         : Integer;
	  fCurrentFontName  : String;
	  fCurrentFontSize  : Integer;
	  fLineScale        : Double;
	  fPrintFileOpen    : Boolean;
	  fPrintFile        : Text;
	  fPrintFileName    : String;
          fPageNo           : Integer;
	  fLeftMargin       : Integer;
	  fTopMargin        : Integer;
	  fRightMargin      : Integer;
	  fBottomMargin     : Integer;
	  fLineToLine       : Integer;
	  fErrorCode        : Integer;
	  fPageLength       : integer;
	  fpageWidth        : integer;
          fFont             : FontType;
          fBold             : Boolean;
          fOnFontChange     : TNotifyEvent;
          fErrorMessage     : String;
	
	 procedure   CreateTabArray;
         procedure   CreateFontArray;
   protected

         property    OnFontChange: TNotifyEvent
                     read fOnFontChange write fOnFontChange;

         procedure   setBold(BoldOn: Boolean);
         procedure   setFont(AFont: FontType);
	 procedure   setCurrentX(XLoc: Double);
	 procedure   setCurrentY(YLoc: Double);
	 function    getCurrentX: Double;
	 function    getCurrentY: Double;

	 procedure   setPageLength(Ln: Double);
	 procedure   setPageWidth( Wd: Double);
         function    getPageLength: Double;
	 function    getPageWidth: Double;
	 
		 
	 procedure   setLineToLine(Spc: Double);
	 function    getLineToLine: Double;
	 procedure   PrintPointXY(S: String; XPos, YPos: Integer);
	 function    CalcCenterPage: Integer;

         procedure   PrintLeftPoint(S: String; XPos: integer);
	 procedure   PrintCenterPoint(S: String; XPos: integer);
	 procedure   PrintRightPoint(S: String; XPos: integer);
	 function    NewTabPoint(IDX, XPosition, just, XWidth, XMargin: integer;
                                     TabRel: Boolean; boxLines, boxShade: byte): PTab;

         procedure  PrintCurrentFont(Sender: TObject);

   public
	 constructor Create;
	 destructor  Destroy; override;

 	 function    getBoxShadeString(TabPtr: PTab): String;  //for printing	 function    getFontName(ListPtr: PTabList): String;
         property    PageNo: Integer read fPageNo write fPageNo;

         property    font: FontType read fFont write setFont;

         property    TabArrayIndex: Integer read fTabArrayIndex write fTabArrayIndex;
	 property    PrintFileOpen: boolean read fPrintFileOpen;
	 property    PrintFile: Text read fPrintFile;
	 property    TabArray: TTabsArray read fTabArray;

         property    Bold: Boolean read fBold write setBold;
	 property    LineScale: Double read fLineScale write fLineScale;
	 property    LineSpacing: Double read getLineToLine write setLineToLine;

	 property    CurX: Integer read fCurrentX write fCurrentX;
	 property    CurY: Integer read fCurrentY write fCurrentY;
	 property    CurrentX: Double read getCurrentX write setCurrentX;
	 property    CurrentY: Double read getCurrentY write setCurrentY;

         property    PgeNo: Integer read fPageNo write fPageNo;
         property    PageLength: Double read getPageLength write setPageLength;
	 property    PageWidth: Double  read getPageWidth  write setPageWidth;
	 property    PageLengthInt: Integer read fPageLength;
	 property    PageWidthInt: Integer read fPageWidth; 
	 
	 function    getBoxLeft(Combined: Byte): Boolean;
	 function    getBoxBottom(Combined: Byte): Boolean;
	 function    getBoxRite(Combined: Byte): Boolean;
	 function    getBoxTop(Combined: Byte): Boolean;

	 function    ShadePercentToByte(Percent: Double): Byte; 
         function    BoxLinesToByte(Lf, Tp, Rt, Bt: Boolean): Byte;
	 procedure   setBoxWidth(TabPtr: PTab; BWidth: Double);  
	 function    getBoxWidth(TabPtr: PTab):Double;

	 function    getTabBoxHeight(IDX: Integer):Double;
         procedure   setTabBoxHeight(IDX: Integer; BHeight: Double);

	 procedure   PrintXY(XPos, YPos: Double; S: String);
	 procedure   PrintLeft(S: String; XPos: Double);
	 procedure   PrintCenter(S: String; XPos: Double);
	 procedure   PrintRight(S: String; XPos: Double);
	 
	 procedure   printTab(IDX: integer; S: String);
         function    resetTab(IDX: Integer): PTab;
	 
	 procedure   SaveFontName(IDX: Integer; FName: String);
         procedure   SaveFontSize(IDX, FSize: Integer);
         procedure   RestoreFont(IDX: Integer);
	 procedure   setBoxShade(TabPtr: PTab; Percent: Double);
	 
	 function    PointToInch(Pnt: Integer): Double;
	 function    InchToPoint(Inch: Double): Integer;
	 procedure   FreeAllTabs;
	 procedure   FreeTabs(IDX: Integer);
         procedure   FreeFont(IDX: Integer);
         procedure   FreeAllFonts;
	 function    nextTab(IDX: Integer): PTab;
         procedure   Home;

	
    function    calcStringY(Base, Height: Integer): integer;
	//New tab creates a new tab in tabs array width index = IDX
	 function NewTab(IDX: Integer; XPosition: Double; just: Integer;XWidth, XMargin: Double;
	                    TabRel: Boolean; boxLines, boxShade: byte): PTab;	
							
     function    EvenTabs(IDX, XPosition, just, XWidth, XMargin, BHeight, Space, Num: integer;
                                    boxLines, boxShade: byte): PTab;	
									
	 procedure   setPageMargins(Lf, Tp, Rt, Bt: Double);

	 function    LinesLeft: Integer;
	 function    TransXFloat(X: Double): Integer;    //User to x points
	 function    TransYFloat(Y: Double): Integer;    //User to y points
	 function    TransXPoint(X: Integer): Integer;   //user x points to PS points
	 function    TransYPoint(Y: Integer): Integer;   //User y points to PS points
	 procedure   NewLine;
	 procedure   OpenPrintFile(FileName: String);    // Open file - discriptor goes to fPrintFile
	 procedure   ClosePrintFile;
	 procedure   PrintCenterPage(S: String);
	 procedure   setLineScale(Scale: Double);
	 procedure   GotoXY(X, Y: Double);
	 //postscript procedures
	 procedure   XLocation(X: Double);
	 procedure   PSProcs;
	 procedure   NewPage;
         procedure   EndPage;
        // procedure   showPage;
  end;

 type
   pAddressRecord = ^TAddressRecord;
   TAddressRecord = record
      AName: String;
      Add1: String;
      Add2: String;
      CityState: String;
      ZipCode: String;
     // PostNetCode: PostNetType;
   end;

 type
  TAddressLabelClass = class(TPostScriptClass)
    private
          fLabelStyle       : String;
          fNumAcross        : integer;
          fNumDown          : integer;
         // fMarginTop        : integer;
         // fMarginLeft       : integer;
          fTextMarginTop    : Integer;
          fTextMarginLeft   : Integer;
          fLabelWidth       : integer;
          fLabelHeight      : integer;
          fSpacingWidth     : integer;
          fSpacingHeight    : integer;
          fPostNetHeight    : Double;
          fPostNetSpacing   : Double;
          fPostNetLineWidth : Double;
          fPrintPostNet     : Boolean;
          fRowPointer       : Integer;
          fColPointer       : Integer;
          fPageDone         : Boolean;
          fAddressRecord    : TAddressRecord;
          fAddressDataSource: TDataSource;
  protected
    function getMarginTop: Double;
    procedure setMarginTop(Top: Double);
    function getMarginLeft: Double;
    procedure setMarginLeft(Left: Double);
    function getTextMarginTop: Double;
    procedure setTextMarginTop(Top: Double);
    function getTextMarginLeft: Double;
    procedure setTextMarginLeft(Left: Double);
    function getLabelWidth: Double;
    procedure setLabelWidth(LabelWidth: Double);
    function getLabelHeight: Double;
    procedure setLabelHeight(LabelHeight: Double);
    function getSpacingWidth: Double;
    procedure setSpacingWidth(SpacingWidth: Double);
    function getSpacingHeight: Double;
    procedure setSpacingHeight(SpacingHeight: Double);
    procedure setAddressRecord(Title, fName, lName, Addr1, Addr2, City, State, Zip: String);
  public
    constructor Create;
    procedure initPostnet;
    destructor  Destroy; override;
   // property Address: TAddressRecord  write setAddressRecord;
    property LabelStyle: String read fLabelStyle write fLabelStyle;
    property NumAcross: Integer read fNumAcross write fNumAcross;
    property NumDown: Integer read fNumDown write fNumDown;
    property MarginTop: Double read getMarginTop write setMarginTop;
    property MarginLeft: Double read getMarginLeft write setMarginLeft;
    property TextMarginTop: Double read getTextMarginTop write setTextMarginTop;
    property TextMarginLeft: Double read getTextMarginLeft write setTextMarginLeft;
    property LabelWidth: Double read getLabelWidth write setLabelWidth;
    property LabelHeight: Double read getLabelHeight write setLabelHeight;
    property SpacingWidth: Double read getSpacingWidth write setSpacingWidth;
    property SpacingHeight: Double read getSpacingHeight write setSpacingHeight;
    property PostNetHeight: Double read fPostNetHeight write fPostNetHeight;
    property PostNetSpacing: Double read fPostNetSpacing write fPostNetSpacing;
    property PostNetLineWidth: Double read fPostNetLineWidth write fPostNetLineWidth;
    property AddressDataSource: TDataSource read fAddressDataSource write fAddressDataSource;
    property PrintPostNet: Boolean read fPrintPostNet write fPrintPostNet;
    procedure putText(S: String);
    procedure PrintPostNetXY(S: String; X, Y: Integer);
    procedure PrintLabels(LabelDataSrc: TDataSource);
    procedure PrintOneLabel;
  end;


implementation	
 
 procedure TPostScriptClass.OpenPrintFile(FileName: String);
   begin
     assignfile(fPrintFile, FileName);
     reWrite(fPrintFile);
	 fPrintFileOpen := True;
     if Assigned(fOnFontChange) then
        OnFontChange(Self);
     psProcs;
   end;
   
 constructor TPostScriptClass.Create;   
    begin
   	inherited create;               //Set defaults
	fPageLength := 792;             //11.0
	fPageWidth := 612;              //8.5
	fLeftMargin := 36;
	fTopMargin := 36;
        CreateTabArray;                 //create empty tab array
        CreateFontArray;                //Create default Font Array
	fFont.FontName := HELVETICA;
	fFont.FontSize := 10;
	fLineScale := 1.5;
        fLineToLine := round(fFont.FontSize * fLineScale);
	fPrintFileName := '';
	fPrintFileOpen := false;
	setPageMargins(0.25, 0.5, 0.5, 0.75);
	CurX := fLeftMargin;
	CurY := fTopMargin + fLineToLine;
        fOnFontChange:= @PrintCurrentFont;
        fPageNo:= 1;
        fBold := false;
   end;

  procedure TPostScriptClass.NewPage;
  begin
     if (PrintFileOpen)  then
       begin
         writeln(PrintFile, 'save');
       end;
     CurrentY :=0.0;
  end;

  procedure TPostScriptClass.EndPage;
  begin
     if (PrintFileOpen)  then
       begin
         writeln(PrintFile, 'restore');
         writeln(PrintFile, 'showpage');
       end;
  end;

  function TPostScriptClass.LinesLeft: Integer;
  begin
   // result := trunc((fCurrentY - fBottomMargin) / fLineToLine);
   result := trunc((fPageLength-fCurrentY - fBottomMargin) / fLineToLine);
  end;

  procedure TPostScriptClass.setBold(BoldOn: Boolean);
  var
    Dash: Integer;
  begin
     Dash:=pos('-',fFont.FontName);
     If BoldOn then
       begin
         if Dash <=0 then
           fFont.FontName:=fFont.FontName+'-Bold';
       end
      else
        begin
          Dash:=pos('-Bold',fFont.FontName);
          If Dash > 0 then
             fFont.FontName := LeftStr(fFont.FontName,Dash-1);
        end;
       PrintCurrentFont(Self);
  end;

  procedure TPostScriptClass.PrintCurrentFont(Sender: TObject);
  begin
    if (PrintFileOpen)  then
	  begin
	     writeln(PrintFile,'/',Font.FontName,' findfont');
             writeln(PrintFile,Font.FontSize,' scalefont');
             writeln(PrintFile,'setfont');
	   end;
  end;

 procedure TPostScriptClass.setFont(AFont: FontType);
 begin
   fFont.fontName := AFont.FontName;
   fFont.fontSize := AFont.FontSize;
   fLineToLine := round(fFont.fontSize * LineScale);
   if Assigned(fOnFontChange) then
      OnFontChange(Self);
 end;

  procedure TPostScriptClass.ClosePrintFile;
  begin
    if PrintFileOpen then
      CloseFile(fPrintFile);
	fPrintFileOpen := false;
  end;	   

   procedure TPostScriptClass.CreateFontArray; //Array 1..10 of font records
  // Type
  //   PFontType = ^FontType;
  //   FontType = record
  //   FontName: String;
  //   FontSize: Integer;
   var
     IDX: Integer;
     MyP: PFontType;
     P: Pointer;
   begin
      for IDX := 1 to 10 do
        begin
          P := @fFontArray;
          MyP := fFOntArray[IDX];
          fFontArray[IDX]:=new(PFontType);
          MyP := fFOntArray[IDX];
          fFontArray[IDX]^.FontName := HELVETICA;
          fFontArray[IDX]^.FontSize := 10;
         end;
   end;


   procedure  TPostScriptClass.CreateTabArray; //Array 1..10 of tab lists
   var
     IDX: Integer;
	 TabListPtr: PTabList;  
   begin
     for IDX := 1 to 10 do
       begin
	 TabListPtr := new(PTabList);
	 with TabListPtr^ do
	   begin
	     TabIndex := 0;
	     TabPos := nil;
	     TabCount := 0;
	     boxHeight := 0;
	     TabHead := nil;
	     TabTail := nil;
	   end;
     	 fTabArray[IDX] := TabListPtr;
       end;
   end;

  function  TPostScriptClass.getTabBoxHeight(IDX: Integer):Double;
  begin
    getTabBoxHeight := PointToInch( fTabArray[IDX]^.boxHeight);
  end;

   procedure  TPostScriptClass.setTabBoxHeight(IDX: Integer; BHeight: Double);

   begin
     fTabArray[IDX]^.boxHeight :=InchToPoint(BHeight);
   end;

 function TpostScriptClass.EvenTabs(IDX, XPosition, just, XWidth, XMargin, BHeight, Space, Num: integer;
                                    boxLines, boxShade: byte): PTab;
 //A tab list of evenly spaced evenly sized tabs - just a utility									
										
 var
   I, St, Inc, Pos: Integer; 
   TmpTab: PTab;	
  begin
 
  St := XPosition;
  Inc := XWidth + Space;
  Pos := XPosition;
  If (St + Num * Inc) > fPageWidth then
    begin
	  EvenTabs := nil;
	  exit;
	end;  
	
   setTabBoxHeight(IDX, BHeight);
   fTabArray[IDX]^.TabCount := num;	
  for I := 1 to Num do
    begin
	   TmpTab := NewTabPoint(IDX, Pos, just, XWidth, XMargin, false, BoxLines, BoxShade); 
	   Pos := Pos + Inc;
	   If I = 1 then
	     begin
	       fTabArray[IDX]^.TabHead := TmpTab;
		   fTabArray[IDX]^.TabPos  := TmpTab;
		   fTabArray[IDX]^.TabIndex:= 1;
		 end;  
	end;
	fTabArray[IDX]^.TabTail := TmpTab;
  end;   					
  				
function TPostScriptClass.NewTab(IDX: Integer; XPosition: Double; just: Integer;XWidth, XMargin: Double;
	                    TabRel: Boolean; boxLines, boxShade: byte): PTab;		
var
  XP, XW, XM: Integer;
begin
  XP := InchToPoint(XPosition);
  XW := InchToPoint(XWidth);
  XM := InchToPoint(XMargin);
  NewTab := NewTabPoint(IDX, XP,just, XW, XM, TabRel, boxlines, boxshade);
end;								
						    
 function TPostScriptClass.NewTabPoint(IDX, XPosition, just, XWidth, XMargin: integer;
                                  TabRel: Boolean; boxLines, boxShade: byte): PTab;
   // Create a new tab
 var 
    NewPTab: PTab;
	IX: Integer;
	TP: PTab;
 begin
   NewPTab := new(PTab);
   With fTabArray[IDX]^ do
     begin
	   if TabHead = nil then
	     begin
		   NewPTab^.prev := nil;       //First tab in the list
		   TabHead := NewPTab;
		   TabCount := 1;
		   TabIndex := 1;
		   TabPos := NewPTab;
		 end
	   else    
	     begin                         //At least one tab already exists
	       NewPTab^.Prev := TabTail;
		   TabTail^.Next := NewPTab;   //Penultimate tab points to newly created tab
		   TabCount := TabCount + 1;
		 end;  
	   TabTail:= NewPTab;              //The new tab is at the tail of the list ALWAYS
	   
	  // NewPTab^.Next := nil;           //The last tab has no next link	
	    NewPTab^.Next := TabHead;        //Last points to head   	    
     end;
	 
		 
	 With NewPTab^ do                  //Set box parameters, start position and justification 
	   begin 
	     If fTabArray[IDX]^.TabCount = 1 then
		   XPos := XPosition
		 else if (TabRel) and (Prev <> nil) then     
           //New position is relative to prev tab
	       XPos := XPosition + Prev^.XPos + Prev^.BoxWidth
	     else		
           XPos := XPosition;
		   
		 justifyText := just;  
	         BoxWidth := XWidth;
		 Margin := XMargin;
		 BShade := boxShade;
		 BLines := boxLines;
	   end;
	 NewTabPoint := NewPTab;  
  end;	   	  
	    	  	  

  procedure   TPostScriptClass.setPageLength(Ln: Double);
  begin
    fPageLength := trunc(Ln*POINTS);
  end;
  
  procedure   TPostScriptClass.setPageWidth( Wd: Double);
  begin
    fPageWidth := trunc(Wd*POINTS);
  end;
  
  function    TPostScriptClass.getPageLength: Double; 
  begin
    getPageLength := Double(fPageLength)/POINTS;
  end;
  
 function    TPostScriptClass.getPageWidth: Double;
  begin
     getPageWidth := Double(fPageWidth)/POINTS;
  end;
  
  function  TPostScriptClass.ShadePercentToByte(Percent: Double): Byte; 
 var
   B: Byte;
  begin
   
    If (Percent < 1) then
	  B := 0
	else if (Percent >= 100) then
	  B := 15
	else
	  B := round(Percent/100.0 * 15.0);
	//B := B shl 4;
	ShadePercentToByte := B;

  end;	
  
 procedure  TPostScriptClass.setBoxShade(TabPtr: PTab; Percent: Double);
 begin
    TabPtr^.BShade := ShadePercentToByte(Percent);
 end;
  
 function  TPostScriptClass.getBoxShadeString(TabPtr: PTab): String;
  begin
    //20.0 should be 15.0 but grays tend to be too dark
    getBoxShadeString := FloatToStrF(1.0 - TabPtr^.BShade/20.0, ffFixed, 3, 1);
  end;
  
  
  function  TPostScriptClass.BoxLinesToByte(Lf, Tp, Rt, Bt: Boolean): Byte;
   var
    Res: Byte;
  begin
    Res:=0;
	If Lf then Res := Res or BOXLINELEFT;
	If Tp then Res := Res or BOXLINETOP;
	If Rt then Res := Res or BOXLINERIGHT;
	If Bt then Res := Res or BOXLINEBOTTOM;
	BoxLinesToByte := Res;
  end;

  procedure TPostScriptClass.SaveFontName(IDX: Integer; FName: String);
  // Type
  //   PFontType = ^FontType;
  //   FontType = record
  //   FontName: String;
  //   FontSize: Integer;
   var
     MyP: PFontType;
     P: Pointer;
  begin
    P := @fFOntArray;
    P := fFOntArray[IDX];
    if fFontArray[IDX] <> nil then
      fFontArray[IDX]^.FontName := FName;
  end;

  procedure TPostScriptClass.SaveFontSize(IDX, FSize: Integer);
  begin
    if fFontArray[IDX] <> nil then
      fFontArray[IDX]^.FontSize := FSize;
  end;

  procedure TPostScriptClass.RestoreFont(IDX: Integer);
  var
    TmpFont: FontType;
  begin
    TmpFont.FontName := fFontArray[IDX]^.FontName;
    TmpFont.FontSize := fFontArray[IDX]^.FontSize;
    Font := TmpFont;
  end;

  procedure TPostScriptClass.Home;
  begin
    CurX := fLeftMargin;
    CurY := fTopMargin;
  end;

  function TPostScriptClass.getBoxLeft(Combined: Byte): boolean;
  begin  
    getBoxLeft:=(Combined and 1) > 0;   
  end;	    
 
 function TPostScriptClass.getBoxBottom(Combined: Byte): boolean;
  begin  
    getBoxBottom:=(Combined and 8) > 0;   
  end;	  
  
  function TPostScriptClass.getBoxRite(Combined: Byte): boolean;
  begin  
     getBoxRite:=(Combined and 4) > 0;   
  end;	  
  
  function TPostScriptClass.getBoxTop(Combined: Byte): boolean;
  begin  
    getBoxTop:=(Combined and 2) > 0;   
  end;	  
  
  function  TPostScriptClass.getBoxWidth(TabPtr: PTab):Double;
  begin
    getBoxWidth := PointToInch(TabPtr^.BoxWidth);
  end;
  
  function  TPostScriptClass.InchToPoint(Inch: Double): Integer;
  begin
    InchToPoint := round(Inch * POINTS);
  end;
  
 function   TPostScriptClass.PointToInch(Pnt: Integer): Double;
   begin
      PointToInch := Double(Pnt)/POINTS;
   end;
  	
  procedure TPostScriptClass.setBoxWidth(TabPtr: PTab; BWidth: Double);
  begin
    TabPtr^.BoxWidth := InchToPoint(BWidth);
  end;
  
  procedure TPostScriptClass.setCurrentX(XLoc: Double);
  begin
    fCurrentX := round(XLoc*POINTS) + fLeftMargin;
  end; 
  
  function  TPostScriptClass.getCurrentX: Double;
  begin
    getCurrentX := Double(fCurrentX)/POINTS - fLeftMargin;
  end;
  
  
  procedure TPostScriptClass.setCurrentY(YLoc: Double);
  begin
    fCurrentY := round(YLoc*POINTS) + fTopMargin;
  end; 
  
  function  TPostScriptClass.getCurrentY: Double;
  begin
    getCurrentY := Double(fCurrentY)/POINTS - fTopMargin;
  end;
  
  procedure  TPostScriptClass.printTab(IDX: Integer; S: String);
  var
    YPos, TmpY: Integer;
	Shade: String;
	just, SY, Box, XStart, FH: integer;
	BoxBase, BoxLeft, BoxTop, BoxRight, BoxHght, BoxWdth, Marg: Integer;
	TabPtr: PTab;
	FN: String;
  begin
    if not PrintFileOpen then exit;
    if (IDX <= 0) or (IDX > 10) then exit;
	YPos := CurY; 
	TabPtr := fTabArray[IDX]^.TabPos;
	Shade := getBoxShadeString(TabPtr);
	With fTabArray[IDX]^ do
	  begin
	    BoxHght := fTabArray[IDX]^.boxHeight;
	    //Box height is common to all tabs in this list
	    SY := calcStringY(YPos,BoxHght);  //Y location for string inside the box
	    BoxBase := TransYPoint(YPos);     //Base line of box is at YPos
          end;
	With TabPtr^ do
	  begin
	    Marg := Margin;
	    BoxLeft := TransXPoint(Xpos);  //WRiteln('BoxLeft ', BoxLeft,' ',XPos);           
	    BoxRight := TransXPoint(XPos + BoxWidth);
	    BoxWdth := BoxWidth;
	    BoxTop := TransYPoint(YPos - BoxHght);  //Measuring Y = 0 at top of page
	    //BoxTop := BoxBase + BoxHght;          //could eliminate one function call
	    just := justifyText;
	    Box := BLines;
	  end;			
	
	 //fill tab box
	 Writeln(PrintFile,Shade,  ' setgray');  
	 Writeln(PrintFile,'newpath');
	 Writeln(PrintFile,BoxLeft,' ',BoxBase,' moveto');
	 Writeln(PrintFile,BoxWdth,' ',0,' rlineto');
	 Writeln(PrintFile,0,' ',BoxHght,' rlineto');
	 Writeln(PrintFile,-BoxWdth,' ',0,' rlineto');
	 Writeln(PrintFile,'closepath');
	 Writeln(PrintFile,'fill');
         Writeln(PrintFile, '0.0 setgray');

	 //box lines if any
	 if getBoxBottom(Box) then
	    begin
	      Writeln(PrintFile,BoxLeft,' ',BoxBase,' moveto');
	      Writeln(PrintFile,BoxWdth,' ',0,' rlineto');
		  Writeln(PrintFile,'stroke');
		end;
	  if getBoxRite(Box) then
	    begin	
		  Writeln(PrintFile,BoxRight,' ',BoxBase,' moveto'); 
	      Writeln(PrintFile,0,' ',BoxHght,' rlineto');
		  Writeln(PrintFile,'stroke');
		end;
	  if getBoxTop(Box) then
	    begin	
		   Writeln(PrintFile,BoxLeft,' ',BoxTop,' moveto');  
	       Writeln(PrintFile,BoxWdth,' ',0,' rlineto');
		   Writeln(PrintFile,'stroke');
		end;
	   if getBoxLeft(Box) then
	     begin	  
	       Writeln(PrintFile,BoxLeft,' ',BoxBase,' moveto');
	       Writeln(PrintFile,0,' ',BoxHght,' rlineto');
	       Writeln(PrintFile,'stroke');
	     end;
	   if S <> '' then
	     begin
	       TmpY := CurY;
	       CurY := SY;
	       if just = JUSTIFYRIGHT then
	         begin
		   XStart := BoxRight - Font.Fontsize div 2;
		   PrintRightPoint(S, XStart);
		 end
	       else if just = JUSTIFYCENTER then
	         begin
	           XStart := BoxLeft + BoxWdth div 2;
		   PRintCenterPoint(S,XStart);
	         end
	       else
	         begin
		   printLeftPoint(S, BoxLeft + Marg);
		 end;
	       CurY := TmpY;
	     end;  //if S <>
           nextTab(IDX);
  end;
  
 procedure TPostScriptClass.PrintPointXY(S: String; XPos, YPos: Integer); 
 //Print a string at X & Y without altering CurY
 begin
  if (not PrintFileOpen) then exit;
    Writeln(PrintFile,'0.0 setgray');
    Writeln(PrintFile,XPos,' ',YPos,' moveto');
	Writeln(PrintFile,'(',S,')',' show');
 end;
 

  function  TPostScriptClass.ResetTab(IDX: Integer): PTab;
  begin
    //With TabListPtr^ do
    With fTabArray[IDX]^ do
       begin
         TabPos := TabHead;
	 TabIndex := 1;
         ResetTab := TabPos;
       end;
  end;

  //function  TPostScriptClass.nextTab(TabListPtr: PTabList): PTab;
  function  TPostScriptClass.nextTab(IDX: Integer): PTab;
  begin
    With fTabArray[IDX]^ do
	    begin
  		  If TabPos = TabTail then  //Last tab? then wrap to first
		    begin
		      TabPos := TabHead;
		      TabIndex := 1;
                      NewLine;             //Automatic newline after last tab
	 	   end
		  else
		    begin
		      TabPos := TabPos^.next;	  //increment tab position	
			  TabIndex := TabIndex + 1;
			  end; 
          nextTab := TabPos;		
		end;	
		
  end;
  	
  function TPostScriptClass.calcStringY(Base, Height: Integer): integer;
  var
    Margin, FSZ: integer;
  begin
 	FSZ := round(Double(Font.FontSize) * 0.75);
	if FSZ < Height then
	  begin
	    Margin := (Height - FSZ ) div 2 + 1;
	    calcStringY := Base - Margin;
	  end 	
	else
	  calcStringY := Base - 3;
  end;
  					
  procedure TPostScriptClass.FreeAllTabs;
  var
    I: Integer;
  begin
    for I := 1 to 10 do
	  FreeTabs(I);
  end;	  	

 procedure TPostScriptClass.FreeAllFonts;
  var
    I: Integer;
  begin
    for I := 1 to 10 do
	  FreeFont(I);
  end;

  procedure TPostScriptClass.FreeFont(IDX: Integer);
  var
    FontPtr: PFontType;
  begin
    dispose(fFontArray[IDX]);
  end;

  procedure TPostScriptClass.FreeTabs(IDX: Integer);
  var
    ClrTab, NuTab, LastTab: PTab;
  begin
    if (IDX <= 0) then exit;
    ClrTab:=TabArray[IDX]^.TabHead;
    LastTab := TabArray[IDX]^.TabTail;
    if ClrTab <> nil then
    while (ClrTab <> LastTab) do
      begin
        NuTab:=ClrTab^.Next;
        dispose(ClrTab);
        ClrTab := NuTab;
      end;
    dispose(clrTab);
	
    With TabArray[IDX]^ do
      begin
        IDX := 0;
        TabPos := nil;
        TabCount := 0;
        boxHeight := 0;
        TabHead := nil;
        TabTail := nil;
      end;
end;	 	

 procedure TPostScriptClass.PrintXY(XPos, YPos: Double; S: String);
 //Print a string at X & Y without altering CurY
 var
   X, Y: Integer;
 begin
   if fPrintFileOpen then
     begin
	   X := TransXFloat(XPos);
	   Y := TransYFloat(YPos);
       PrintPointXY(S, X, Y);
	end;
 end;
 
 procedure TPostScriptClass.GotoXY(X, Y: Double);
 var
   XInt, YInt: Integer;
 begin
   XInt := TransXFloat(X);
   YInt := TransYFloat(Y);
   Writeln(PrintFile, XInt,' ',Yint,' moveto');
   CurY := YInt;
  end;
 
 procedure TPostScriptClass.PrintCenterPage(S: String);
 var
   X: Integer;
 begin
   X := CalcCenterPage;
   writeln(PrintFile,X,' ',TransYPoint(CurY),' moveto');
   writeln(PrintFile,'(',S,') centershow');
  end;

 function TPostScriptClass.CalcCenterPage: Integer;
 begin
   CalcCenterPage := (fPageWidth - fRightMargin- fLeftMargin) div 2 + fLeftMargin;
 end;
  
  
 procedure TPostScriptClass.PrintLeft(S: String; XPos: Double);
 begin
   writeln(PrintFile,TransXFloat(XPos),' ',TransYPoint(CurY),' moveto');
   writeln(PrintFile,'(',S,')', ' show');
 end;
 
 procedure TPostScriptClass.PrintCenter(S: String; XPos: Double);
 var
   X: Integer;
 begin 
   X := TransXFloat(XPos);
   writeln(PrintFile,X,' ',TransYPoint(CurY),' moveto');
   writeln(PrintFile,'(',S,') centershow');  
 end;
  
 procedure TPostScriptClass.PrintRight(S: String; XPos: Double);
 var
   X: Integer;
 begin 
   X := TransXFloat(XPos);
   writeln(PrintFile,X,' ',TransYPoint(fCurrentY),' moveto');
   writeln(PrintFile,'(',S,') rightshow');  
 end;
  
  procedure TPostScriptClass.PrintLeftPoint(S: String; XPos: integer);
 begin
   writeln(PrintFile,XPos,' ',TransYPoint(CurY),' moveto');
   writeln(PrintFile,'(',S,')', ' show');
 end;
 
 procedure TPostScriptClass.PrintCenterPoint(S: String; XPos: integer);
  begin 
   writeln(PrintFile,XPos,' ',TransYPoint(CurY),' moveto');
   writeln(PrintFile,'(',S,') centershow');  
 end;
  
 procedure TPostScriptClass.PrintRightPoint(S: String; XPos: integer);
 begin 
    writeln(PrintFile,XPos,' ',TransYPoint(fCurrentY),' moveto');
   writeln(PrintFile,'(',S,') rightshow');  
 end;
 
  procedure TPostScriptClass.setPageMargins(Lf, Tp, Rt, Bt: Double);
 begin
   fLeftMargin := InchToPoint(Lf); 
   fTopMargin := InchToPoint(Tp); 
   fRightMargin := InchToPoint(Rt); 
   fBottomMargin := InchToPoint(Bt); 
 end;
 
  procedure TPostScriptClass.setLineToLine(Spc: Double);
  begin
    fLineToLine := round(Double(fCurrentFontSize) * fLineScale);
  end;
  	
  function TPostScriptClass.getLineToLine: Double;
  begin
    getLineToLine := PointToInch(fLineToLine);
  end;
  
    	 
 { function TPostScriptClass.LinesLeft: Integer;
  var
    PageUsed: Integer;	
  begin
    PageUsed := fPageLength - CurY - fBottomMargin;
	LinesLeft := PageUsed div fLineToLine; 
  end;}
   
  function TPostScriptClass.TransXFloat(X: Double): Integer;
  begin
    TransXFloat := TransXPoint(InchToPoint(X));
  end;
  
  function TPostScriptClass.TransYFloat(Y: Double): Integer;
  begin
    TransYFloat := TransYPoint(InchToPoint(Y));
  end;
  
  function TPostScriptClass.TransXPoint(X: Integer): Integer;
  begin
    TransXPoint := X + fLeftMargin;
  end; 
  	
  function TPostScriptClass.TransYPoint(Y: Integer): Integer; 
  begin
    TransYPoint := fPageLength - fTopMargin - Y;
   end;	

procedure TPostScriptClass.XLocation(X: Double);
var
  Xint: Integer;
begin
 if (PrintFileOpen)  then
   begin
     XInt := InchToPoint(X);
 	 writeln(PrintFile,'/loc ',Xint,' def');
   end; 
 // /loc Xint def
end;
 
procedure TPostScriptClass.psProcs;
begin
  if (PrintFileOpen)  then
    begin
	  writeln(PrintFile,'/rightshow');
	  writeln(PrintFile,'{dup stringwidth pop');
	  writeln(PrintFile,'0 exch sub');
	  writeln(PrintFile,'0 rmoveto');
	  writeln(PrintFile,'show} def');
	  writeln(PrintFile);
	  
	  writeln(PrintFile,'/centershow');
	  writeln(PrintFile,'{dup stringwidth pop');
	  writeln(PrintFIle,'2 div');
	  writeln(PrintFile,'0 exch sub');
	  writeln(PrintFile,'0 rmoveto');
	  writeln(PrintFile,'show} def');
	  writeln(PrintFile);
	 end; 
end;

  procedure TPostScriptClass.setLineScale(Scale: Double);
  begin
    fLineScale := Scale;
  end;	
	 	 
  procedure TPostScriptClass.NewLine;
  begin
    CurY := CurY + InchToPoint(LineSpacing);//fLineToLine;
  end;
     
  destructor TPostScriptClass.Destroy;
  begin
  // InitCriticalSection(fCriticalSection); 
	FreeAllTabs;
        FreeAllFonts;
	inherited Destroy;
		
	//DoneCriticalSection(fCriticalSection);	
end;

   constructor TAddressLabelClass.Create;
    begin
      inherited create;
      fRowPointer := 0;
      fColPointer := 0;
      fPageDone := False;
      fPostNetHeight := 0.125;
      fPostNetSpacing := 0.04;
      fPostNetLineWidth := 0.15;
    end;

  destructor TAddressLabelClass.Destroy;
  begin
  // InitCriticalSection(fCriticalSection);
  inherited Destroy;
  //DoneCriticalSection(fCriticalSection);
end;

   procedure TAddressLabelClass.setAddressRecord(Title, fName, lName,
                                Addr1, Addr2, City, State, Zip: String);
     begin
       fAddressRecord.AName := Title+' '+fName+' '+ lName;
       fAddressRecord.Add1 := Addr1;
       fAddressRecord.Add2 := Addr2;
       fAddressRecord.CityState:= City+','+State;
       fAddressRecord.ZipCode := Zip;
     end;

    function TAddressLabelClass.getMarginTop: Double;
    begin
      result := PointToInch(fTopMargin);
    end;

    procedure TAddressLabelClass.setMarginTop(Top: Double);
    begin
       fTopMargin := InchToPoint(Top);
    end;

    function TAddressLabelClass.getMarginLeft: Double;
    begin
      result := PointToInch(fLeftMargin);
    end;

    procedure TAddressLabelClass.setMarginLeft(Left: Double);
    begin
      fLeftMargin := InchToPoint(Left);
    end;

    function TAddressLabelClass.getTextMarginTop: Double;
    begin
      result := PointToInch(fTextMarginTop);
    end;

    procedure TAddressLabelClass.setTextMarginTop(Top: Double);
    begin
       fTextMarginTop := InchToPoint(Top);
    end;

    function TAddressLabelClass.getTextMarginLeft: Double;
    begin
      result := PointToInch(fTextMarginLeft);
    end;

    procedure TAddressLabelClass.setTextMarginLeft(Left: Double);
    begin
      fTextMarginLeft := InchToPoint(Left);
    end;

    function TAddressLabelClass.getLabelWidth: Double;
    begin
      result := PointToInch(fLabelWidth);
    end;

    procedure TAddressLabelClass.setLabelWidth(LabelWidth: Double);
    begin
      fLabelWidth := InchToPoint(LabelWidth);
    end;

    function TAddressLabelClass.getLabelHeight: Double;
    begin
      result := PointToInch(fLabelHeight);
    end;

    procedure TAddressLabelClass.setLabelHeight(LabelHeight: Double);
    begin
      fLabelHeight := InchToPoint(LabelHeight);
    end;

    function TAddressLabelClass.getSpacingWidth: Double;
    begin
      result := PointToInch(fSpacingWidth);
    end;

    procedure TAddressLabelClass.setSpacingWidth(SpacingWidth: Double);
    begin
      fSPacingWidth := InchToPoint(SpacingWidth);
    end;

    function TAddressLabelClass.getSpacingHeight: Double;
    begin
      result := PointToInch(fSpacingHeight);
    end;

    procedure TAddressLabelClass.setSpacingHeight(SpacingHeight: Double);
    begin
       fSPacingHeight := InchToPoint(SpacingHeight);
    end;

   procedure TAddressLabelClass.PrintOneLabel;
   var
     X, Y: Integer;
    YAdd1, YAdd2, YCSZ,YPostNet: Integer;
   begin
      X := fLeftMargin + fTextMarginLeft + fColPointer * (fSpacingWidth );
      Y := fPageLength - fTopMargin  - fTextMarginTop
                       - fRowPointer * (fSpacingHeight);
      YAdd1 := Y - fLineToLine;
      if fAddressRecord.Add2 <> '' then
         YAdd2 := YAdd1 - fLineToLine
      else
         YAdd2 := YAdd1;
      YCSZ  :=  YAdd2 - fLineToLine;

      With fAddressRecord do
        begin
          PrintPointXY(AName, X, Y);
          PrintPointXY(Add1, X, YAdd1);
          if Add2 <> '' then
          PrintPointXY(Add2, X, YAdd2);
          PrintPointXY(CityState+' '+ZipCode, X, YCSZ);
        end;
      if fPrintPostNet then
        begin
          YPostNet := fPageLength - fTopMargin - fLabelHeight + fTextMarginTop -
                       fRowPointer * (fSpacingHeight);

          PrintPostNetXY(faddressRecord.ZipCode, X+2, YPostNet);
        end;
      inc(fColPointer);
      if fColPointer = fNumAcross then
        begin
          fColPointer := 0;
          inc(fRowPointer);
          if FRowPointer = fNumDown then
            begin
              fRowPointer := 0;
              EndPage;
              fPageDone := true;
            end;
        end;
   end;

   procedure TAddressLabelClass.PrintLabels(LabelDataSrc: TDataSource);
    begin
      if not PrintFileOpen then exit;
   // DataSet :=
    if fPrintPostNet then  initPostnet;
    With LabelDataSrc.DataSet do
      begin
        if not active then open;
        first;
        while not EOF do
          begin
            fPageDone := False;
            fAddressRecord.AName := FieldByName('TITLE').AsString + ' ' +
                                    FieldByName('FNAME').AsString + ' ' +
                                    FieldByName('NAME').AsString;
             fAddressRecord.Add1 := FieldByName('ADDRESS_1').AsString;
             fAddressRecord.Add2 := FieldByName('ADDRESS_2').AsString;
             fAddressRecord.CityState    := FieldByName('CITY').AsString + ',' +
                                    FieldByName('STATE').AsString;
             fAddressRecord.ZipCode      := FieldByName('ZIP').AsString;
             PrintOneLabel;
             next;
          end; //While not EOF
      end; //With DataSet
      if fPageDone then
        begin
          fPageDone := false;
          EndPage;
        end;
   end;

   procedure TAddressLabelClass.putText(S: String);
   begin
     writeln(PrintFile,S);
   end;

   procedure TAddressLabelClass.PrintPostNetXY(S: String; X, Y: Integer);
   begin
     Writeln(PrintFile,IntToStr(X)+' '+IntToStr(Y)+' '+'moveto');
     Writeln(PrintFile,'('+S+')'+' barshow');
           // example 72 576 moveto
      //(164331115) barshow
   end;

   procedure TAddressLabelClass.initPostnet;
    var
      SmBarHt, BarHt, BarSpace: String;
    begin
      if not PrintFileOpen then exit;
      BarHt := FloatToStr(fPostNetHeight);
      SmBarHt := FloatToStr(fPostNetHeight / 2.0);
      BarSpace := FloatToStr(fPostNetSpacing);
      putText(FloatToStr(fPostNetLineWidth)+' setlinewidth');
      putText('/inch {72 mul} def');
      putText('/tall '+BarHt+' inch def');
      putText('/short '+SmBarHt+' inch def');
      putText('/space '+BarSpace+' inch def');
      putText('/frame {0.0 tall rlineto  space tall neg rmoveto} def');
      putText('/drawtall {0.0 tall rlineto  space tall neg rmoveto} def ');
      putText('/drawshort {0.0 short rlineto  space short neg rmoveto} def');
      putText('/one {drawshort drawshort drawshort drawtall drawtall} def ');
      putText('/two {drawshort drawshort drawtall drawshort drawtall} def');
      putText('/three { drawshort drawshort drawtall drawtall drawshort} def');
      putText('/four {drawshort drawtall drawshort drawshort drawtall} def');
      putText('/five {drawshort drawtall drawshort drawtall drawshort} def');
      putText('/six {drawshort drawtall drawtall drawshort drawshort} def');
      putText('/seven {drawtall drawshort drawshort drawshort drawtall} def');
      putText('/eight {drawtall drawshort drawshort drawtall drawshort} def');
      putText('/nine {drawtall drawshort drawtall drawshort drawshort} def');
      putText('/zero {drawtall drawtall drawshort drawshort drawshort} def');
      putText('/sum 0 def');
      putText('/barshow');
      putText('{ frame');
      putText('/thestring exch def');
      putText('thestring');
      putText('{ /charcode exch def');
      putText('48 charcode  eq { ');
      putText('  zero');
      putText('}{');
      putText('} ifelse');
      putText('49 charcode  eq { ');
      putText('  one');
      putText('}{');
      putText('} ifelse');
      putText('50 charcode  eq { ');
      putText('  two');
      putText('}{');
      putText('} ifelse');
      putText('51 charcode  eq {');
      putText('  three');
      putText('}{');
      putText('} ifelse');
      putText('52 charcode  eq {');
      putText('  four');
      putText('}{');
      putText('} ifelse');
      putText('53 charcode  eq {');
      putText('   five');
      putText('}{');
      putText('} ifelse');
      putText(' 54 charcode  eq {');
      putText('  six');
      putText('}{ ');
      putText('} ifelse');
      putText(' 55 charcode  eq { ');
      putText('  seven  ');
      putText('}{');
      putText('} ifelse');
      putText(' 56 charcode  eq {');
      putText('  eight');
      putText('}{');
      putText('} ifelse');
      putText(' 57 charcode  eq {');
      putText('  nine');
      putText('}{');
      putText('} ifelse');
      putText('/thechar ( ) dup 0 charcode put def');
      putText('} forall');
      putText('frame');
      putText('stroke');
      putText('} def');
      // example 72 576 moveto
      //(164331115) barshow
   end;
end.


    end;

end.
