# Building wxWidgets for wxPerl on Windows with Strawberry Perl

**IMPORTANT**: This article refers to the **updated** ``Alien::wxWidgets`` and ``Wx`` kits, obtainable from

<https://github.com/sciurius/wxPerl/Releases/R3.004/Wx-3.004.tar.gz>  
<https://github.com/sciurius/wxPerl/Releases/R3.004/Alien-wxWidgets-0.70.tar.gz>

## Alien::wxWidgets (from scratch)
````
cd Alien-wxWidgets-x.xx
perl Build.PL --wxWidgets-version=3.2.6
````

Now execute
````
perl Build
````

`Build` will download the appropriate wxWidget sources, configure and
build.


This will take some time, 20-30 minutes, and may generate a couple of
(apparently harmless errors):
````
The system can not find the path specified
Link errors involving boot_compilet.
````

Next:
````
perl Build install
````

This will install ``Alien::wxWidgets`` **and wxWidgets** into
Strawberry Perl, usually `C:\Strawberry\perl\site\lib`.

The following files will be installed:
````
Alien/wxWidgets/Config/msw_3_2_6_uni_gcc_3_4.pm
Alien/wxWidgets/Utility.pm
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/include/wx/...
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/build.cfg
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libgcc_s_seh-1.dll
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libstdc++-6.dll
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxbase32u.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxbase32u_net.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxbase32u_xml.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxexpat.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxjpeg.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxmsw32u_adv.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxmsw32u_aui.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxmsw32u_core.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxmsw32u_gl.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxmsw32u_html.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxmsw32u_media.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxmsw32u_propgrid.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxmsw32u_ribbon.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxmsw32u_richtext.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxmsw32u_stc.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxmsw32u_webview.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxmsw32u_xrc.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxpng.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxregexu.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxtiff.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/libwxzlib.a
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/wxbase32u_gcc_custom.dll
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/wxbase32u_net_gcc_custom.dll
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/wxbase32u_xml_gcc_custom.dll
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/wxmsw32u_adv_gcc_custom.dll
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/wxmsw32u_aui_gcc_custom.dll
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/wxmsw32u_core_gcc_custom.dll
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/wxmsw32u_gl_gcc_custom.dll
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/wxmsw32u_html_gcc_custom.dll
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/wxmsw32u_media_gcc_custom.dll
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/wxmsw32u_propgrid_gcc_custom.dll
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/wxmsw32u_ribbon_gcc_custom.dll
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/wxmsw32u_richtext_gcc_custom.dll
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/wxmsw32u_stc_gcc_custom.dll
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/wxmsw32u_webview_gcc_custom.dll
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/wxmsw32u_xrc_gcc_custom.dll
Alien/wxWidgets/msw_3_2_6_uni_gcc_3_4/lib/wx/setup.h
````

## Alien::wxWidgets (from downloaded source)

Download `wxMSW-3.2.6-Setup.exe` from the wxWidgets site and run it.
Install into `C:\wxWidgets-3.2.6`.

Set an environment variable `WXDIR`. In PowerShell, `$Env:WXDIR =
"C:\wxWidgets-3.2.6"`. In CMD, `set WXDIR=C:\wxWidgets-3.2.6`.

Execute the build:
````
cd Alien-wxWidgets-x.xx
perl Build.PL
````

`Build` will detect the source and skip the download.

`Build install`, see above.

## Alien::wxWidgets (from precompiled binary)

Download `wxMSW-3.2.6-Setup.exe` from the wxWidgets site and run it.
Install into `C:\wxWidgets-3.2.6`.

Download Windows binary kits for MinGW-w64 8.1 'Development Files'
from the wxWidgets site.

Unpack `wxMSW-3.2.6_gcc810_x64_Dev.7z` in the root of the wxWidgets kit.

Set environment variable `WXDIR` to the root of the wxWidgets
install, see above.
````
cd Alien-wxWidgets-x.xx
perl Build.PL --wxWidgets-build=0
````

`Build` will use the binary package.

`Build install`, will install `Alien::wxWidgets` **and copy wxWidgets** into `C:\Strawberry\perl\site\lib`

## wxPerl (Wx)

When `Alien::wxWidgets` is installed, `Wx` should build flawlessly.
