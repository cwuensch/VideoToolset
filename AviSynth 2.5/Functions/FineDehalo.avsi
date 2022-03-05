# http://avisynth.nl/index.php/FineDehalo
#
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.

Function FineDehalo (clip src, float "rx", float "ry", int "thmi", int "thma", int "thlimi", int "thlima", float "darkstr", float "brightstr", int "showmask", float "contra", bool "excl", float "edgeproc")
{
	rx        = Default (rx,          2)
	ry        = Default (ry,         rx)
	thmi      = Default (thmi,       80)
	thma      = Default (thma,      128)
	thlimi    = Default (thlimi,     50)
	thlima    = Default (thlima,    100)
	darkstr   = Default (darkstr,   1.0)
	brightstr = Default (brightstr, 1.0)
	showmask  = Default (showmask,    0)
	contra    = Default (contra,    0.0)
	excl      = Default (excl,     true)
	edgeproc  = Default (edgeproc,  0.0)

	rx_i = Round (rx)
	ry_i = Round (ry)

	src


	### Dehaloing ###

	dehaloed = DeHalo_alpha (rx=rx, ry=ry, darkstr=darkstr, brightstr=brightstr)

	# Contrasharpening
	dehaloed =   (contra > 0)
\	           ? dehaloed.FineDehalo_contrasharp (src, contra)
\	           : dehaloed


	### Main edges ###

	# Basic edge detection, thresholding will be applied later.
	edges = mt_edge (mode="prewitt", thY1=0, thY2=255)

	# Keeps only the sharpest edges (line edges)
	strong = edges.mt_lut (expr="x "+String(thmi)+" - "+String(thma-thmi)+" / 255 *")

	# Extends them to include the potential halos
	large = strong.mt_expand_multi (sw=rx_i, sh=ry_i)


	### Exclusion zones ###

	# When two edges are close from each other (both edges of a single
	# line or multiple parallel color bands), the halo removal
	# oversmoothes them or makes seriously bleed the bands, producing
	# annoying artifacts. Therefore we have to produce a mask to exclude
	# these zones from the halo removal.

	# Includes more edges than previously, but ignores simple details
	light = edges.mt_lut (expr="x "+String(thlimi)+" - "+String(thlima-thlimi)+" / 255 *")

	# To build the exclusion zone, we make grow the edge mask, then shrink
	# it to its original shape. During the growing stage, close adjacent
	# edge masks will join and merge, forming a solid area, which will
	# remain solid even after the shrinking stage.

	# Mask growing
	shrink = light.mt_expand_multi (sw=rx_i, sh=ry_i, mode="ellipse")

	# At this point, because the mask was made of a shades of grey, we may
	# end up with large areas of dark grey after shrinking. To avoid this,
	# we amplify and saturate the mask here (actually we could even
	# binarize it).
	shrink = shrink.mt_lut ("x 4 *")

	# Mask shrinking
	shrink = shrink.mt_inpand_multi (sw=rx_i, sh=ry_i, mode="ellipse")

	# This mask is almost binary, which will produce distinct
	# discontinuities once applied. Then we have to smooth it.
	shrink = shrink.RemoveGrain (20, -1)
	shrink = shrink.RemoveGrain (20, -1)


	### Final mask building ###

	# Previous mask may be a bit weak on the pure edge side, so we ensure
	# that the main edges are really excluded. We do not want them to be
	# smoothed by the halo removal.
	shr_med = (excl) ? mt_logic (strong, shrink, mode="max") : strong

	# Substracts masks and amplifies the difference to be sure we get 255
	# on the areas to be processed.
	outside = mt_lutxy (large, shr_med, "x y - 2 *")

	# If edge processing is required, adds the edgemask
	ep_str  = "x y "+String(edgeproc * 0.66)+" * +"
	outside = (edgeproc > 0) ? mt_lutxy (outside, strong, ep_str) : outside

	# Smooth again and amplify to grow the mask a bit, otherwise the halo
	# parts sticking to the edges could be missed.
	outside = outside.RemoveGrain (20, -1).mt_lut ("x 2 *")

	### Masking ###

	mt_merge (last, dehaloed, outside, y=3, u=2, v=2)

	  (showmask == 1) ? outside.GreyScale ()
\	: (showmask == 2) ? shrink.GreyScale ()
\	: (showmask == 3) ? edges.GreyScale ()
\	: (showmask == 4) ? strong.GreyScale ()
\	:                   last
}

# level == 1.0 : normal contrasharp
Function FineDehalo_contrasharp (clip dehaloed, clip src, float level)
{
	bb  = dehaloed.RemoveGrain (11, -1)
	bb2 = bb.Repair (bb.Repair (bb.Medianblur (2, -256, -256), 1), 1)
	xd  = mt_makediff (bb, bb2)
	xd  = xd.mt_lut ("x 128 - 2.49 * "+String(level)+" * 128 +")
	xdd = mt_lutxy (
\		xd,
\		mt_makediff (src, dehaloed),
\		"x 128 - y 128 - * 0 < 128 x 128 - abs y 128 - abs < x y ? ?"
\	)

	dehaloed.mt_adddiff (xdd, y=3, u=2, v=2)
}




# Try to remove 2nd order halos.
Function FineDehalo2 (clip src, string "hconv", string "vconv", int "showmask")
{
	hconv    = Default (hconv, "-1 -2 0 0 40 0 0 -2 -1")
	vconv    = Default (vconv, "-2 -1 0 0 40 0 0 -1 -2")
	showmask = Default (showmask, 0)

	src
	fix_h = mt_convolution (horizontal="1", vertical=vconv, y=3, u=2, v=2)
	fix_v = mt_convolution (horizontal=hconv, vertical="1", y=3, u=2, v=2)
	edges_h = mt_edge (mode="1 2 1 0 0 0 -1 -2 -1", thY1=0, thY2=255)
	edges_v = mt_edge (mode="1 0 -1 2 0 -2 1 0 -1", thY1=0, thY2=255)
	mask_h = edges_h	#.mt_lut (expr="x 2 *")
	mask_v = edges_v	#.mt_lut (expr="x 2 *")
	temp_h = mt_lutxy (mask_h, mask_v, expr="x 3 * y -")
	temp_v = mt_lutxy (mask_v, mask_h, expr="x 3 * y -")
	mask_h = temp_h
	mask_v = temp_v

	mask_h = mask_h.FineDehalo2_grow_mask ("vertical")
	mask_v = mask_v.FineDehalo2_grow_mask ("horizontal")

	src
	mt_merge (last, fix_h, mask_h, y=3, u=2, v=2)
	mt_merge (last, fix_v, mask_v, y=3, u=2, v=2)

	  (showmask == 1) ? mt_logic (mask_h, mask_v, mode="max").GreyScale ()
\	:                   last
}

Function FineDehalo2_grow_mask (clip mask, string mode)
{
	Assert ((mode == "horizontal" || mode == "vertical"), "Wrong mode")

	mask
	mt_expand (mode=mode).mt_inpand (mode=mode)
	mask_1 = mt_expand (mode=mode)
	mask_2 = mask_1.mt_expand (mode=mode).mt_expand (mode=mode)
	mt_lutxy (mask_2, mask_1, expr="x y -")
	RemoveGrain (12, -1).mt_lut (expr="x 1.8 *")
}