; *********************************************************
; Este programa en ensamblador muestra una ventana de diálogo simple
; que actúa como un panel de control mínimo. Muestra una lista de archivos .cpl
; en el directorio del sistema y permite ejecutarlos al hacer doble clic en ellos.
; *********************************************************

      .486                      ; Configuración para código de 32 bits
      .model flat, stdcall      ; Modelo de memoria de 32 bits y llamadas a funciones de la API de Windows
      option casemap :none      ; Sensible a mayúsculas y minúsculas

;     Archivos de inclusión
;     ~~~~~~~~~~~~~
      include \masm32\include\windows.inc   ; Definiciones de constantes y estructuras de Windows
      include \masm32\include\masm32.inc    ; Macros y funciones útiles para ensamblador
      include \masm32\include\gdi32.inc     ; Declaraciones de funciones de GDI32
      include \masm32\include\user32.inc    ; Declaraciones de funciones de USER32
      include \masm32\include\kernel32.inc  ; Declaraciones de funciones de KERNEL32
      include \masm32\include\Comctl32.inc  ; Declaraciones de funciones de COMCTL32
      include \masm32\include\comdlg32.inc  ; Declaraciones de funciones de COMDLG32
      include \masm32\include\shell32.inc   ; Declaraciones de funciones de SHELL32
      include \masm32\include\oleaut32.inc  ; Declaraciones de funciones de OLEAUT32
      include \masm32\macros\macros.asm     ; Macros adicionales para ensamblador

;     Bibliotecas
;     ~~~~~~~~~
      includelib \masm32\lib\masm32.lib     ; Biblioteca de funciones de MASM32
      includelib \masm32\lib\gdi32.lib      ; Biblioteca de funciones de GDI32
      includelib \masm32\lib\user32.lib     ; Biblioteca de funciones de USER32
      includelib \masm32\lib\kernel32.lib   ; Biblioteca de funciones de KERNEL32
      includelib \masm32\lib\Comctl32.lib   ; Biblioteca de funciones de COMCTL32
      includelib \masm32\lib\comdlg32.lib   ; Biblioteca de funciones de COMDLG32
      includelib \masm32\lib\shell32.lib    ; Biblioteca de funciones de SHELL32
      includelib \masm32\lib\oleaut32.lib   ; Biblioteca de funciones de OLEAUT32

      FUNC MACRO parameters:VARARG          ; Macro para simplificar llamadas a funciones
        invoke parameters
        EXITM <eax>
      ENDM

      include \masm32\include\dialogs.inc   ; Macros para crear diálogos comunes

; Definiciones de identificadores
IDC_PROGRAMAS equ 1001
IDC_BLUETOOTH equ 1002
IDC_ESCRITORIO equ 1003
IDC_DISPOSITIVO equ 1004
IDC_INTERNET equ 1005
IDC_JUEGO equ 1006
IDC_MOUSE equ 1007
IDC_SONIDO equ 1008
IDC_REDES equ 1009
IDC_ENERGIA equ 1010
IDC_SISTEMA equ 1011
IDC_FECHA equ 1012

; Definir nuevos colores de fondo
COLOR_BG_DIALOG equ RGB(0, 0, 0)  ; Negro

dlgproc PROTO :DWORD,:DWORD,:DWORD,:DWORD
RunAppwiz PROTO
RunBthprops PROTO
RunDesk PROTO
RunHdwwiz PROTO
RunInetcpl PROTO
RunJoy PROTO
RunMain PROTO
RunMmsys PROTO
RunNcpa PROTO
RunPowercfg PROTO
RunSysdm PROTO
RunTimedate PROTO


.data
  hInstance     dd ?
  hBrushBlack	dd ?
  hBitmap 		dd ?  ; Identificador de la imagen bitmap
  hIcon			dd ?
  ;ProgramasCaracteristicas db "Programas y Características",0
  ;BluetoothPropiedades db "Propiedades de Bluetooth",0
  ;DeskPropiedades db "Propiedades de Escritorio",0

.code

start:
  mov hInstance, FUNC(GetModuleHandle,NULL)
  invoke InitCommonControls
  call main
  invoke ExitProcess,eax

main proc
  Dialog "Panel de Control", \
         "MS Sans Serif",8, \
         WS_OVERLAPPEDWINDOW or \
         WS_SYSMENU or DS_CENTER, \
         13, \
         50,50,180,130, \
         1024
         
  ; Establecer el color de fondo del diálogo
  ;invoke SetClassLong, hWin, GCL_HBRBACKGROUND, COLOR_BG_DIALOG

  ; Botones para cada opción ft. mrTuns scr
  DlgButton "Programas",WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON or WS_BORDER,6,5,57,25,IDC_PROGRAMAS
  DlgButton "Bluetooth",WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON or WS_BORDER,62,5,57,25,IDC_BLUETOOTH
  DlgButton "Pantalla",WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON or WS_BORDER,118,5,57,25,IDC_ESCRITORIO
  DlgButton "Dispositivos",WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON or WS_BORDER,6,29,57,25,IDC_DISPOSITIVO
  DlgButton "Internet",WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON or WS_BORDER,62,29,57,25,IDC_INTERNET
  DlgButton "Juego",WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON or WS_BORDER,118,29,57,25,IDC_JUEGO
  DlgButton "Ratón",WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON or WS_BORDER,6,53,57,25,IDC_MOUSE
  DlgButton "Sonido",WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON or WS_BORDER,62,53,57,25,IDC_SONIDO
  DlgButton "Redes",WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON or WS_BORDER,118,53,57,25,IDC_REDES
  DlgButton "Energía",WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON or WS_BORDER,6,77,57,25,IDC_ENERGIA
  DlgButton "Sistema",WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON or WS_BORDER,62,77,57,25,IDC_SISTEMA
  DlgButton "Fecha",WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON or WS_BORDER,118,77,57,25,IDC_FECHA

  DlgButton "Cancelar",WS_TABSTOP,72,110,35,15,IDCANCEL
  ; Crear pincel negro
  invoke GetStockObject, BLACK_BRUSH
  mov hBrushBlack, eax

  ; Llamar al diálogo modal
  CallModalDialog hInstance, 0, dlgproc, NULL
  ret
main endp

dlgproc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
  LOCAL path[260]:BYTE
  
  .if uMsg == WM_INITDIALOG
      invoke SendMessage,hWin,WM_SETICON,1,
                         FUNC(LoadIcon,NULL,IDI_ASTERISK)					  
  .elseif uMsg == WM_COMMAND
    mov eax, wParam
    .if eax == IDCANCEL
      invoke EndDialog,hWin,0
    .elseif eax == IDC_PROGRAMAS
      invoke RunAppwiz
    .elseif eax == IDC_BLUETOOTH
      invoke RunBthprops
    .elseif eax == IDC_ESCRITORIO
      invoke RunDesk
    .elseif eax == IDC_DISPOSITIVO
      invoke RunHdwwiz
    .elseif eax == IDC_INTERNET
      invoke RunInetcpl
    .elseif eax == IDC_JUEGO
      invoke RunJoy
    .elseif eax == IDC_MOUSE
      invoke RunMain
    .elseif eax == IDC_SONIDO
      invoke RunMmsys
    .elseif eax == IDC_REDES
      invoke RunNcpa
    .elseif eax == IDC_ENERGIA
      invoke RunPowercfg
    .elseif eax == IDC_SISTEMA
      invoke RunSysdm
    .elseif eax == IDC_FECHA
      invoke RunTimedate
    
    .endif
  .elseif uMsg == WM_CLOSE
    invoke EndDialog,hWin,0
  .endif

  xor eax, eax
  ret

dlgproc endp

; Funciones para ejecutar los archivos cpl
RunAppwiz proc
  LOCAL path[260]:BYTE

  ; Copia la ruta completa directamente
  invoke lstrcpy, ADDR path, SADD("C:\\Windows\\System32\\appwiz.cpl")

  invoke ShellExecuteA, 0, 0, ADDR path, 0, 0, SW_SHOW

  ret
RunAppwiz endp


RunBthprops proc
  LOCAL path[260]:BYTE

  ; Copia la ruta completa directamente
  invoke lstrcpy, ADDR path, SADD("C:\\Windows\\System32\\bthprops.cpl")

  invoke ShellExecuteA, 0, 0, ADDR path, 0, 0, SW_SHOW
  
  ret
RunBthprops endp

RunDesk proc
  LOCAL path[260]:BYTE

  invoke lstrcpy, ADDR path, SADD("C:\\Windows\\System32\\desk.cpl")

  invoke ShellExecuteA, 0, 0, ADDR path, 0, 0, SW_SHOW

  ret
RunDesk endp

RunHdwwiz proc
  LOCAL path[260]:BYTE

  invoke lstrcpy, ADDR path, SADD("C:\\Windows\\System32\\hdwwiz.cpl")

  invoke ShellExecuteA, 0, 0, ADDR path, 0, 0, SW_SHOW

  ret
RunHdwwiz endp

RunInetcpl proc
  LOCAL path[260]:BYTE

  invoke lstrcpy, ADDR path, SADD("C:\\Windows\\System32\\inetcpl.cpl")

  invoke ShellExecuteA, 0, 0, ADDR path, 0, 0, SW_SHOW

  ret
RunInetcpl endp

RunJoy proc
  LOCAL path[260]:BYTE

  invoke lstrcpy, ADDR path, SADD("C:\\Windows\\System32\\joy.cpl")

  invoke ShellExecuteA, 0, 0, ADDR path, 0, 0, SW_SHOW

  ret
RunJoy endp

RunMain proc
  LOCAL path[260]:BYTE

  invoke lstrcpy, ADDR path, SADD("C:\\Windows\\System32\\main.cpl")

  invoke ShellExecuteA, 0, 0, ADDR path, 0, 0, SW_SHOW

  ret
RunMain endp

RunMmsys proc
  LOCAL path[260]:BYTE

  invoke lstrcpy, ADDR path, SADD("C:\\Windows\\System32\\mmsys.cpl")

  invoke ShellExecuteA, 0, 0, ADDR path, 0, 0, SW_SHOW

  ret
RunMmsys endp

RunNcpa proc
  LOCAL path[260]:BYTE

  invoke lstrcpy, ADDR path, SADD("C:\\Windows\\System32\\ncpa.cpl")

  invoke ShellExecuteA, 0, 0, ADDR path, 0, 0, SW_SHOW

  ret
RunNcpa endp

RunPowercfg proc
  LOCAL path[260]:BYTE

  invoke lstrcpy, ADDR path, SADD("C:\\Windows\\System32\\powercfg.cpl")

  invoke ShellExecuteA, 0, 0, ADDR path, 0, 0, SW_SHOW

  ret
RunPowercfg endp

RunSysdm proc
  LOCAL path[260]:BYTE

  invoke lstrcpy, ADDR path, SADD("C:\\Windows\\System32\\sysdm.cpl")

  invoke ShellExecuteA, 0, 0, ADDR path, 0, 0, SW_SHOW

  ret
RunSysdm endp

RunTimedate proc
  LOCAL path[260]:BYTE

  invoke lstrcpy, ADDR path, SADD("C:\\Windows\\System32\\timedate.cpl")

  invoke ShellExecuteA, 0, 0, ADDR path, 0, 0, SW_SHOW

  ret
RunTimedate endp

end start
        
