# ============================================================
#  MangoWC config.conf — Verified dispatch names
#  Source: github.com/DreamMaoMao/mangowc wiki
# ============================================================

# ── Display ──────────────────────────────────────────────────
monitorrule=name:HDMI-A-2,width:3840,height:2160,refresh:240,x:0,y:0,scale:1,vrr:1

# ── Window effects ───────────────────────────────────────────
blur=1
blur_optimized=1
blur_params_num_passes=2
blur_params_radius=5
shadows=1
shadow_only_floating=1
shadows_size=10
shadows_blur=15
shadows_position_x=2
shadows_position_y=4
shadowscolor=0x00000099
border_radius=8
no_radius_when_single=0
focused_opacity=1.0
unfocused_opacity=1.0

# ── Animations ───────────────────────────────────────────────
animations=1
layer_animations=1
animation_type_open=zoom
animation_type_close=zoom
animation_fade_in=1
animation_fade_out=1
animation_duration_open=200
animation_duration_close=180
animation_duration_move=150
animation_duration_tag=250
zoom_initial_ratio=0.85

# ── Layout ───────────────────────────────────────────────────
default_layout=float

# ── Gaps ─────────────────────────────────────────────────────
gappi=0
gappo=0
smartgaps=0

# ── Overview ─────────────────────────────────────────────────
hotarea_size=10
enable_hotarea=1
overviewgappi=8
overviewgappo=40

# ── General ──────────────────────────────────────────────────
sloppyfocus=1
warpcursor=1
focus_on_activate=1
enable_floating_snap=1
snap_distance=20
cursor_size=48
new_is_master=1
default_mfact=0.55
default_nmaster=1

# ── Window rules ─────────────────────────────────────────────
windowrule=isfloating:1

# ── Keyboard ─────────────────────────────────────────────────
repeat_rate=25
repeat_delay=600
xkb_rules_layout=us

# ── Autostart ────────────────────────────────────────────────
exec=~/.config/mango/autostart.sh

# ── Terminal ─────────────────────────────────────────────────
bind=SUPER,Return,spawn,kitty

# ── Launcher ─────────────────────────────────────────────────
bind=SUPER,SPACE,spawn,wofi --show drun
bind=SUPER,e,spawn,thunar
bind=SUPER,l,spawn,waylock

# ── Window management ────────────────────────────────────────
bind=SUPER,q,killclient,
bind=SUPER,f,togglefloating,
bind=SUPER,F11,togglefullscreen,
bind=SUPER,m,togglemaximizescreen,0
bind=SUPER+SHIFT,r,reload_config,
bind=SUPER,r,spawn,bash ~/.config/mango/rebar.sh

# ── Overview ─────────────────────────────────────────────────
bind=SUPER,0,toggleoverview,
bind=SUPER,TAB,toggleoverview,

# ── Screenshots ──────────────────────────────────────────────
bind=NONE,Print,spawn,bash -c 'mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png && notify-send "Screenshot saved"'
bind=SHIFT,Print,spawn,bash -c 'mkdir -p ~/Pictures/Screenshots && grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png && notify-send "Screenshot saved"'

# ── Volume ───────────────────────────────────────────────────
bind=NONE,XF86AudioRaiseVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind=NONE,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind=NONE,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# ── Window focus ─────────────────────────────────────────────
bind=SUPER,h,focusdir,left
bind=SUPER,j,focusdir,down
bind=SUPER,k,focusdir,up
bind=SUPER,l,focusdir,right
bind=SUPER,Left,focusdir,left
bind=SUPER,Right,focusdir,right
bind=SUPER,Up,focusdir,up
bind=SUPER,Down,focusdir,down

# ── Move floating windows ────────────────────────────────────
bind=CTRL+SHIFT,Up,movewin,+0,-50
bind=CTRL+SHIFT,Down,movewin,+0,+50
bind=CTRL+SHIFT,Left,movewin,-50,+0
bind=CTRL+SHIFT,Right,movewin,+50,+0

# ── Resize floating windows ──────────────────────────────────
bind=CTRL+ALT,Up,resizewin,+0,-50
bind=CTRL+ALT,Down,resizewin,+0,+50
bind=CTRL+ALT,Left,resizewin,-50,+0
bind=CTRL+ALT,Right,resizewin,+50,+0

# ── Tags ─────────────────────────────────────────────────────
bind=SUPER,1,viewtag,1
bind=SUPER,2,viewtag,2
bind=SUPER,3,viewtag,3
bind=SUPER,4,viewtag,4
bind=SUPER,5,viewtag,5
bind=SUPER,6,viewtag,6
bind=SUPER,7,viewtag,7
bind=SUPER,8,viewtag,8
bind=SUPER,9,viewtag,9

# ── Move window to tag ────────────────────────────────────────
bind=SUPER+SHIFT,1,tag,1
bind=SUPER+SHIFT,2,tag,2
bind=SUPER+SHIFT,3,tag,3
bind=SUPER+SHIFT,4,tag,4
bind=SUPER+SHIFT,5,tag,5
bind=SUPER+SHIFT,6,tag,6
bind=SUPER+SHIFT,7,tag,7
bind=SUPER+SHIFT,8,tag,8
bind=SUPER+SHIFT,9,tag,9

# ── Mouse ────────────────────────────────────────────────────
mousebind=SUPER,btn_left,moveresize,curmove
mousebind=SUPER,btn_right,moveresize,curresize
mousebind=NONE,btn_middle,togglemaximizescreen,0
