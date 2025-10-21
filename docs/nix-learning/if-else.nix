let
	x = true;
	message = if x then "x is true" else "x is false";
in
	message ++ 
		(if (config.services.xserver.windowManager.xmonad.enable == true) 
			then [ pkgs.wofi])
		else
			(if (config.services.xserver.windowManager.hyprland.enable == true)
				then [pkgs.fuzzel] else [])
