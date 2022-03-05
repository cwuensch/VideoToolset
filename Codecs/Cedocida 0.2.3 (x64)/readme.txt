/******************************************************************************/
/*                                                                            */
/*  Cedocida DV-Codec                                                         */
/*                                                                            */
/*  Copyright (C) 2007 Andreas Dittrich <dittrich@cithraidt.de>               */
/*  Project start: 15.12.2003                                                 */
/*  Last change  : 16.06.2007                                                 */
/*                                                                            */
/******************************************************************************/
/*                                                                            */
/*  This program is free software; you can redistribute it and/or modify      */
/*  it under the terms of the GNU General Public License as published by      */
/*  the Free Software Foundation; either version 2 of the License, or         */
/*  (at your option) any later version.                                       */
/*                                                                            */
/*  This program is distributed in the hope that it will be useful,           */
/*  but WITHOUT ANY WARRANTY; without even the implied warranty of            */
/*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             */
/*  GNU General Public License for more details.                              */
/*                                                                            */
/*  You should have received a copy of the GNU General Public License         */
/*  along with this program; if not, write to the Free Software               */
/*  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA */
/*                                                                            */
/******************************************************************************/


Introduction
------------
Cedocida is a Video for Windows (VfW) DV-Type2-Codec.


Features
--------
- supported formats for in- and output: RGB, YUY2, YV12 (PAL-DV / MPEG2-I / MPEG2-P)
- direct YUV-4:2:0 output when using "YV12 PAL-DV" option
- specifying allowed input and output formats


Some Notes on YV12 Sampling Options and DV compression (see remarks below)
------------------------------------------------------------
DV is compressed video based on a 4:2:0 (PAL) or 4:1:1 color format.
In case of PAL-DV the position of the chroma samples are different then in other formats.

(I - Encoding)
When encoding to DV and input is YV12 you have to tell the encoder
which type of YV12 input you are feeding to the encoder:

1.) "DV", that is the luma and chroma samples are taken 1:1 for
DCT-type compression as specified in the standard. If the source
has sample positions which are not compliant to the DV standard
you will get wrong results.

2.) "MPEG 2 non interlaced", you are feeding in YV12 which is used
in the MPEG 2 standard for non interlaced material. In order to get
correct DV-compressed-video the position of the chroma samples are
internally shifted/interpolated.

3.) "MPEG 2 interlaced", same as 2.) but for interlaced MPEG 2 material

4.) When feeding the encoder with YUY2 or RGB material there is no
uncertainty about the sample positions of luma/chroma, that is the
"YV12 chroma sampling"-options are irrelevant.

(II - Decoding)
When decoding from DV and output is YV12 you have to tell the decoder
which type of YV12 output you want to get out of the decoder:

1.), 2.) and 3.) same as above but now specifies the output material.

4.) When decoding to YUY2 or RGB the color sample positions, not available 
in the native DV format are linear interpolated based on fields.

Here YV12 is used (in the broader sense), that there are 4 parts
of luma and 2 parts of chroma samples for a 4-pixel-block, each 8bit per
sample, and arranged in a planar way in memory. The position of the
samples differs for the various video formats.

That is, if you deal with YV12, you have to tell what material you have
(to feed the encoder) or you want to get (from the decoder).


Remarks concerning DVCPRO25 and DVCPRO50
-----------------------------------------
DVCPRO25 is based on 4:1:1 color sampling for NTSC and PAL
DVCPRO50 is based on 4:2:2 color sampling for NTSC and PAL (and since it doubles the compressed size the quality is better)
Here the appropriate uncompressed format is YUY2 since it preserves the color information
in each line.