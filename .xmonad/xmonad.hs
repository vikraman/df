--
-- ~/.xmonad/xmonad.hs
--
-- vh4x0r's xmonad.hs
--
-- Imports

import XMonad hiding ( (|||) )
import Data.Ratio
import Data.Monoid
import Data.List
import System.IO
import System.Time
import System.Locale
import System.Environment
import System.Exit
import Graphics.X11.Xlib

-- Actions
import XMonad.Actions.GridSelect
import XMonad.Actions.CycleWS
import XMonad.Actions.WindowGo
import XMonad.Actions.UpdatePointer
import XMonad.Actions.Search
import XMonad.Actions.RotSlaves
import qualified XMonad.Actions.Search as S
import qualified XMonad.Actions.Submap as SM

-- Utils
import XMonad.Util.EZConfig(additionalKeysP,additionalMouseBindings)
import XMonad.Util.Run
import XMonad.Util.Themes
import XMonad.Util.NamedScratchpad

-- Prompt
import XMonad.Prompt
import qualified XMonad.Prompt as P
import XMonad.Prompt.Man
import XMonad.Prompt.Shell
import XMonad.Prompt.AppendFile
import XMonad.Prompt.RunOrRaise

-- Layout
import XMonad.Layout.Tabbed
import XMonad.Layout.IM
import XMonad.Layout.GridVariants
import XMonad.Layout.MosaicAlt
import XMonad.Layout.ResizableTile
import XMonad.Layout.Spiral
import XMonad.Layout.Named
import XMonad.Layout.TwoPane

-- Layout helpers
import XMonad.Layout.LayoutHints
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.MultiToggle
import XMonad.Layout.Reflect
import XMonad.Layout.NoBorders
import XMonad.Layout.LayoutCombinators

-- Hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks hiding (L)
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook

-- Utility functions
import qualified XMonad.StackSet as W
import qualified Data.Map as M

-----------------------------------------
-- Run xmonad with the specified settings
--

main = do d <- spawnPipe myXMonadBar
	  xmonad $ defaultConfig
	    {
	      -- simple stuff
	      terminal           = myTerminal
	    , focusFollowsMouse  = myFocusFollowsMouse
	    , borderWidth        = myBorderWidth
	    , modMask            = myModMask
	    , numlockMask        = myNumlockMask
	    , workspaces         = myWorkspaces
	    , normalBorderColor  = myNormalBorderColor
	    , focusedBorderColor = myFocusedBorderColor
	      -- layout stuff
	    , layoutHook         = myLayoutHook
	    , manageHook         = myManageHook
	    , handleEventHook    = myEventHook
	    , logHook            = myLogHook d
	    , startupHook        = myStartupHook
	      -- end
	    } `additionalKeysP` myKeys

-- Define my colors
--
myBGColor	 = "#202020"
myFGColor	 = "#606060"
myFGColorHi	 = "#909090"
myFGWhite	 = "#f0f0f0"
myHiliteColor	 = "#3fa9f5"
myUrgentColor	 = "#ff1d25"
myPromptFGColor	 = "#ff931e"
myPromptBGColor	 = "#101010"
myAltHiliteColor = "#7ac943"

goldenRatio = 2/(1+sqrt(5)::Double);

myXFTFont	= "xft:Inconsolata:pixelsize=12"

myTheme = defaultTheme
    { activeColor           = myBGColor
    , inactiveColor         = myPromptBGColor
    , activeTextColor       = myPromptFGColor
    , inactiveTextColor     = myFGColor
    , activeBorderColor     = myBGColor
    , inactiveBorderColor   = myPromptBGColor
    , urgentBorderColor     = myUrgentColor
    , urgentTextColor       = myUrgentColor
    , fontName              = myXFTFont 
    , decoHeight            = 18
    }
    
myXPConfig = defaultXPConfig
    { fgColor = myPromptFGColor
    , bgColor = myPromptBGColor
    , fgHLight = myPromptBGColor
    , bgHLight = myPromptFGColor
    , promptBorderWidth = 1
    , historySize = 100
    , font = myXFTFont
    , position = Top
    , borderColor = myBGColor 
    , height = 18
    }
    
searchEngineMap method = M.fromList $
       [ ((0, xK_g), method S.google )
       , ((0, xK_y), method S.youtube )
       , ((0, xK_m), method S.maps )
       , ((0, xK_d), method S.dictionary )
       , ((0, xK_w), method S.wikipedia )
       , ((0, xK_a), method S.amazon )
       ]

myColorizer = colorRangeFromClassName
                    black
                    white
                    (0x22,0x20,0xAA)
                    white
                    white
    where
        black = minBound
        white = maxBound

myGSConfig colorizer = (buildDefaultGSConfig colorizer) 
                            { gs_cellheight     = 50
                            , gs_cellwidth      = 200
                            , gs_cellpadding    = 10
                            , gs_font           = myXFTFont
                            }
    
-- Define params for makeDzen
--
monitorWidth	= 1366
monitorHeight	= 768
barHeight	= 18
leftBarWidth	= 900

-- Preferred terminal program
--
myTerminal      = "urxvtc"

-- Whether focus follows the mouse pointer
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Width of the window border in pixels
--
myBorderWidth   = 1

-- "Windows key" to be used as Modkey
--
myModMask       = mod4Mask

-- The mask for the numlock key
--
myNumlockMask   = mod2Mask

-- List of workspaces
--
myWorkspaces    = ["1:main","2:web","3:irc","4:code","5:chat","6:ssh","7:mail","8:mon","9:x","-","="]

-- Border colors for unfocused and focused windows
--
myNormalBorderColor  = "#cccccc"
myFocusedBorderColor = "#0000ff"

-- Additional keys
--
myKeys      = -- kill conky and dzen when we quit
              [ ("M-q",     spawn "killall -9 dzen2;xmonad --recompile;xmonad --restart")
              , ("M-w",     kill)
              -- apps
              , ("M-S-i",   spawn "urxvtc -T irssi -e irssi")
              -- extra workspace keys
              --, ("M--","")
              --, ("M-=","")
              
              -- prompt keys              
              , ("M-s",     SM.submap $ searchEngineMap $ promptSearchBrowser myXPConfig "firefox")
              , ("M-S-s",   selectSearch google) 
              , ("M-S-g",   promptSearchBrowser myXPConfig "firefox" myMultiSearch)
              , ("M-/",     manPrompt myXPConfig)
              , ("M-n",     appendFilePrompt myXPConfig "~/NOTES")
              , ("M-S-n",   appendFilePrompt myXPConfig "~/IDEAS")
              , ("M-`",     namedScratchpadAction scratchpads "htop")
              , ("M-p",     shellPrompt myXPConfig)
              , ("M-S-p",   runOrRaisePrompt  myXPConfig)
              -- gridselect
              , ("M-g",     goToSelected $ myGSConfig myColorizer)
              --, ("M-S-g",   spawnSelected myGSConfig ["urxvtc", "chromium"])
              -- some useful nav helpers
              , ("M-o",     sendMessage MirrorExpand)
              , ("M-i",     sendMessage MirrorShrink)
              , ("M-r",     sendMessage $ Toggle REFLECTX)
              , ("M-S-r",   sendMessage $ Toggle REFLECTY)
              , ("M-f",     jumpToFull)
              , ("M-S-t",   jumpToTall)
              , ("M-<Backspace>", focusUrgent)
              , ("M-S-<Backspace>", clearUrgents)
              -- Tiled
              , ("M-a",     sendMessage MirrorShrink)
              , ("M-z",     sendMessage MirrorExpand)
              -- for Mosaic
              , ("M-S-a",     withFocused (sendMessage . expandWindowAlt))
              , ("M-S-z",     withFocused (sendMessage . shrinkWindowAlt))
              , ("M-C-a",     withFocused (sendMessage . tallWindowAlt))
              , ("M-C-z",     withFocused (sendMessage . wideWindowAlt))
              , ("M-C-S-a",   sendMessage resetAlt) 
              -- struts
              , ("M-b",     sendMessage $ ToggleStruts)
              -- CycleWS
              , ("M-<R>",   nextWS)
              , ("M-S-<R>", shiftToNext >> nextWS)
              , ("M-<L>",   prevWS)
              , ("M-S-<L>", shiftToPrev >> prevWS)
              , ("M-z",     toggleWS)
              -- RotSlaves
              , ("M-<U>",   rotSlavesUp)
              , ("M-<D>",   rotSlavesDown)
              ]
              where
                jumpToFull = sendMessage $ JumpToLayout "Full"
                jumpToTall = sendMessage $ JumpToLayout "tiled"
                
                myMultiSearch = intelligent (multi !> prefixAware(google))

------------------------------------------------------------------------
-- Mouse bindings
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Scratchpad
scratchpads =
    [ NS "htop" "urxvtc -T htop -e htop" (title =? "htop") (customFloating $ W.RationalRect 0 (18/1050) 1 (2/5))
    ]
    where role = stringProperty "WM_WINDOW_ROLE"

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--

myLayoutHook =  mkToggle (single REFLECTX)      $
                mkToggle (single REFLECTY)      $            
                avoidStruts                     $   
                onWorkspace "2:web" webLayouts  $
                onWorkspace "5:chat" imLayouts  $
                onWorkspace "3:irc" ircLayouts  $
                hinted (standardLayouts)
     where
         hinted l = layoutHintsWithPlacement (0,0) l
         
         standardLayouts =  tiled ||| Mirror tiled ||| trueFull ||| 
                            spiral gRatio ||| Grid gRatio ||| MosaicAlt M.empty |||
                            mytabbed ||| splitGrid
         
         -- tabs
         mytabbed = named "simpletab" (tabbed shrinkText myTheme)

         -- mostly fullscreen
         webLayouts = hinted (trueFull ||| tiled ||| simpleTabbedBottomAlways )
        
         -- gajim
         imLayouts = withIM (1/9) imProp (Grid (16/10)) ||| gridIM (1/9) imProp 
         imProp = Role "roster"
         
         -- irc / irssi (one main, one 80col terminal), and full

         ircLayouts = named "irc" (TwoPane (3/100) (5/8)) ||| hinted (trueFull)
         
         splitGrid = named "sgrid" (hinted ( SplitGrid L 1 2 (2/3) gRatio delta ))
         
         tiled   = ResizableTall nmaster delta gRatio []
         trueFull = noBorders Full

         nmaster = 1
         
         -- golden ratio
         gRatio   = toRational goldenRatio
         delta   = 3 % 100


------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--

myManageHook = (composeAll . concat $
    [ [isDialog --> doFloat]
    , [className =? c --> doFloat | c <- myCFloats]
    , [title =? t --> doFloat | t <- myTFloats]
    , [resource =? i --> doIgnore | i <- myIgnores]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShift "1:main" | x <- my1Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShift "2:web" | x <- my2Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShift "3:irc" | x <- my3Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShift "4:code" | x <- my4Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShift "5:chat" | x <- my5Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShift "6:ssh" | x <- my6Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShift "7:mail" | x <- my7Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShift "8:mon" | x <- my8Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShift "9:x" | x <- my9Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShift "-" | x <- myMinusShifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShift "=" | x <- myEqualShifts]
    ]) <+> manageDocks <+> namedScratchpadManageHook scratchpads 
    where
        myCFloats = ["mplayer","vlc","Smplayer","Xmessage"]
        myTFloats = ["Save As..."]
        myIgnores = ["desktop_window","kdesktop"]
        my1Shifts = []
        my2Shifts = ["Firefox","Chrome"]
        my3Shifts = ["irssi*","irssi"]
        my4Shifts = []
        my5Shifts = ["Pidgin"]
        my6Shifts = []
        my7Shifts = []
        my8Shifts = []
        my9Shifts = []
        myMinusShifts   = []
        myEqualShifts    = []

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--
myDzenFont :: String
myDzenFont = "fixed"

makeDzen :: Int -> Int -> Int -> Int -> String -> String
makeDzen x y w h a = "dzen2 -p 1"		++
                     " -ta "    ++ a            ++
                     " -x "     ++ show x       ++
                     " -y "     ++ show y       ++
                     " -w "     ++ show w       ++
                     " -h "     ++ show h       ++
                     " -fn '"   ++ myDzenFont   ++ "'" ++
                     " -fg '"   ++ myFGColor    ++ "'" ++
                     " -bg '"   ++ myBGColor    ++ "' -e 'onstart=lower;enterslave=grabmouse;leaveslave=ungrabmouse'"

myXMonadBar     = makeDzen 0 0 leftBarWidth barHeight "l"

myLogHook :: Handle -> X ()
myLogHook h = ( dynamicLogWithPP $ defaultPP
    { ppCurrent         = dzenColor myFGWhite myHiliteColor . pad
    , ppHidden          = dzenColor myFGColorHi myBGColor . noNSP
    , ppHiddenNoWindows = dzenColor myFGColor myBGColor . pad
    , ppLayout          = dzenColor myHiliteColor myBGColor . pad . renameWorkspaces 
    , ppUrgent          = wrap (dzenColor myUrgentColor "" "[") (dzenColor myUrgentColor "" "]" ) . pad
    , ppTitle           = wrap "^fg(#909090) [^fg(#3fa9f5) " " ^fg(#909090)]^fg()" . shorten 80
    , ppWsSep           = "^fg(#606060)^r(1x18)"
    , ppSep             = " "
    , ppOutput          = hPutStrLn h
    }) >> updatePointer (Relative 0.05 0.95)
    where
        noNSP ws = if ws == "NSP" then "" else pad ws    
        renameWorkspaces =  (\x -> case x of
                    "ResizableTall"          -> wsTokenWrap (dzenHilite "|") 
                    "Mirror ResizableTall"   -> wsTokenWrap (dzenHilite "-")  
                    "Full"                   -> wsTokenWrap (dzenHilite "F")
                    "Spiral"                 -> wsTokenWrap (dzenHilite "@")
                    "Grid"                   -> wsTokenWrap (dzenHilite "+")
                    "MosaicAlt"              -> wsTokenWrap (dzenHilite "M")
                    "simpletab"              -> wsTokenWrap (dzenHilite "t")
                    "irc"                    -> wsTokenWrap (dzenHilite "i")
                    "sgrid"                  -> wsTokenWrap (dzenHilite "S")
                    ) . stripHints . stripIM

        stripIM s = if "IM " `isInfixOf` s then drop (length "IM ") s else s
        stripHints s = if "Hinted " `isInfixOf` s then drop (length "Hinted ") s else s
        
        wsTokenWrap :: String -> String
        wsTokenWrap s = wrap (dzenColor myFGColorHi "" "[") (dzenColor myFGColorHi "" "]") s

        dzenHilite :: String -> String
        dzenHilite s = (dzenColor myHiliteColor "" ) s

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = return ()

