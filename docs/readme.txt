
    Cris' widgets - readme
    ======================

    This is a little collection of rexx widgets written to work with
    Martin Lafaix' Widget Library.
    
    Included are:  a Z! controller widget (actually two cooperating widgets)
                   a clock widget
                   a swap-file-monitor widget
                   a PM123 controller widget
                   a CDPlay controller widget
                   
    
    Z! Controller
    =============
    
    This is a controller for the Z! mp3 player.
    
    Since version 0.4, this widget comes as two cooperating widgets: the main
    "Z! Controller" part, which is a rexx button, and a "Z! Monitor" part,
    which is a rexx gauge.
    
    You can choose (the installer will ask you) between the "normal" version,
    and a "wider" version, which is probably best suited for those having very
    high resolutions (higher than 1024x768). In the "wider" version the
    controls (pause, stop, etc) are not crammed into a single button, but are
    distributed on two buttons, delivering easier selection.
    
    For a full list of features, see the "history.txt" file. There is not
    enough space here ;-)
    

    Clock
    =====
    
    This is a simple clock. It has slight enhancements over the built-in clock
    widget in XCenter.
    
    Features: It only shows hours:minutes, to conserve XCenter space.
              
    		  It can change his background color based on the hour of the 
    		  day.
              
    		  It shows the weekday and the date in the tooltip.
              
    
    Swap File Monitor
    =================
    
    This is a monitor for your swap file.
    
    Features: It shows the percentage of space occupied by the swap file,
              with respect to the free space on the swap drive.
              
              It changes its color when the swapper starts growing, and
              then again when the percentage goes over 90%.
              
              It shows the real size (in megabytes) of the swap file in
              the tooltip.
              
    Note: The percentage may vary even if the swapper is NOT growing,
          because the free space on you swapper drive may change. BTW, you
          will be able to tell if the swapper has grown, by looking at the bar
          color (see above).

    
    PM123 Controller & CDPlay Controller
    ====================================
    
    These two widgets have been contributed by Cliff Brady.
    
    They're two controllers, in the style of the early Z! Controller. The
    first one controls PM123 (a shareware skinnable PM MP3 player), while
    the second controls CDPlay (an old CD player, which - unlike modern
    ones - can be controlled via named pipes... it can be found on hobbes).
    
    I've not tested them, cause I'm not using either program. BTW, the code
    is derived from early versions of my early Z! Controller, with a few
    changes regarding pipe commands and volume setting.
    
    I'm distributing these widgets for the convenience of end users, but
    I don't have the time to keep the code aligned to the main Z! Controller.
    If anybody wants to do this, I'd be very grateful. Send the updated code
    to me and I'll distribute it.
