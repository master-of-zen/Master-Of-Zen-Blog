+++
title = "YCbCr and RGB"
date = 2022-04-27
+++

I want to take you on small journey into color spaces
and what place they take in our everyday life.

<!-- more -->

### Introduction

YCbCr and RGB are two most used color spaces there is, and
while RGB is everywhere when we talk about computer graphics or screens
YCbCr is dominate all types of media that we see everyday.

### Start

Our experiment will be quite simple, we will take a single RGB image and
convert it to YCbCr, and track what happens along the way.

Commands for all steps will be supplied below images or as actions performed so
you can try it yourself.

As source for experiment i will use a frame from [Peru 8K HDR 60FPS
(FUHD)](https://youtu.be/1La4QzGeaaQ?t=185)
It was taken from 8k source and resized to 1920x1080.

<img src="/yuv/1080p.png"  width=100% height=100%>
`ffmpeg -i 8k_extract.png -pix_fmt rgb24 -vf scale=-2:1080 1080p.png`

All images in this post are PNG 8 bit images and are original size.
Feel free to right click and open image in new tab.

### YCbCr and RGB structure

Both YCbCr and RGB contain 3 planes which together form complete image.

Both color spaces have different bit depths. Bit depth refers to number of
pixels that is used to represent value in each of the planes.
For example 8 bit would give range of 0-255 possible values.
While 10 bit will give 0-1023.

### RGB

In case of RGB those planes are <font color="red">Red</font>, <font 
color="green">Green</font>, <font color="blue">Blue</font>.
Each plane dimensions are the same and equal to image resolution.
RGB is really convenient as each channel contains level of intensity of light
that added together
can form any color we want.

Most popular bit depths are 8,16,32 bits.

Below are 2 images of each canal, first in grayscale where value
of pixel displayed as it brightness and second is channel in their respective
color.

Without any compression, each plane is exactly `2073600` bytes.

Width x Height x Bit depth

`1920 x 1080 x 8 = 2073600`

Whole image is `6220800` bytes, or `6.2208` megabytes/~`5.9`MiB.

## <font color="red">Red</font>

<img src="/yuv/r.png"  width=100% height=100%>
<img src="/yuv/rc.png"  width=100% height=100%>
`ffmpeg -i 1080p.png -filter_complex "extractplanes=r" r.png`

## <font color="green">Green</font>

<img src="/yuv/g.png"  width=100% height=100%>
<img src="/yuv/gc.png"  width=100% height=100%>
`ffmpeg -i 1080p.png -filter_complex "extractplanes=g" g.png`

## <font color="blue">Blue</font>

<img src="/yuv/b.png"  width=100% height=100%>
<img src="/yuv/bc.png"  width=100% height=100%>
`ffmpeg -i 1080p.png -filter_complex "extractplanes=b" r.png`

### YCbCr

YCbCr separates luminance(brightness) from chrominance(color), and designed to
efficiently store visual information, but require conversion before being
displayed.

YCbCr transformed from RGB in such way that most of brightness information is
stored in Y plane (luma) and most of color information of pixels is stored in
Cb and Cr planes.

Most of the details, contrast, and brightness are moved to Y plane, which leaves
Cb and Cr planes rather flat and smooth. That would be apparent on planes preview.

**Subsampling** takes advantage of that by reducing the resolution of Cb and Cr
planes without significant visual difference for reconstructed image. This is
used widely in image and video compression. Absolute majority of media that you
will encounter is subsampled. To benefits of this step we will return later.

Subsampling `4:2:0` is most used and mean that our Cb and Cr planes reduced in
width and height in half.\

We can convert PNG image into YUV 4:2:0 with following command:\
`ffmpeg -i 1080p.png -pix_fmt yuv420p 1080p.yuv`\
\* **yuv** only contains the data, without information about resolution and subsampling,
so usually **y4m** used instead, which contains headers with such information

Which gives us next resolutions of our planes in this example:

`Y - 1920x1080`\
`Cb - 960x540`\
`Cr - 960x540`

Bellow is grayscale image of each Y, Cb, Cr channels, where Cb and Cr channels
are subsampled. Each image is extracted from YUV which have 4:2:0 subsampling,
and collage of all planes together.

**Notice** that all details are concentrated in Y plane.\
Most of the blue in Cb(strips of clothing), and most of the red in Cr(clothing
and face).\
Cb and Cr plains are quite flat and have low contrast.

### Y

<img src="/yuv/y.png"  width=100% height=100%>
`ffmpeg -i 1080p.y4m -filter_complex "extractplanes=y" y.png`

### Cb

<img src="/yuv/u.png"  width=100% height=100%>
`ffmpeg -i 1080p.y4m -filter_complex "extractplanes=u" u.png`

### Cr

<img src="/yuv/v.png"  width=100% height=100%>
`ffmpeg -i 1080p.y4m -filter_complex "extractplanes=v" v.png`

### Y + Cb + Cr

This is a colage of all plains at their size after subsampling.

<img src="/yuv/yuv.png"  width=100% height=100%>
`ffmpeg -i 1080p.y4m  -filter_complex
"[0:v]extractplanes=planes=y[y];[0:v]extractplanes=planes=u[u];[0:v]extractplane
s=planes=v[v];[u][v]hstack[uv];[y][uv]vstack" i.png`

Without any compression it is `2073600` bytes for Y plane, and `518400` bytes
for Cb and Cr planes.
`3110400` bytes or `3.1104`/~`2.97`MiB for whole image.
What is exactly the half of size of RGB image.

## Comparing images

Now as we done those steps, let's put planes together and compare images,
to see how much of visual difference RGB -> YCbCr conversion and subsmapling introduced.\
First is oriiginal and second is reconstructed from YCbCr.

<img src="/yuv/1080p.png"  width=100% height=100%>
<img src="/yuv/1080p_yuv.png"  width=100% height=100%>

Without zooming in and inspecting each image side by side there is little to nothing lost visually.\
Closer cross-examination could show loss of detail, best seen on colorful parts of the image.\
Without having reference, it's hard to say that any loss of quality happened, while guaranteeing
halving total amount of data used for image.

Furthremore we can employ some tools to measure and show us difference between the images.\
For example: `butteraugli`, which give us heatmap and score which measure how much images deviate.

Score for this image is:\
`3.3250269890`\
`3-norm: 1.519525`\

Heatmap of differences:\
<img src="/yuv/heatmap.png"  width=100% height=100%>

## Compressability comparison

As you might notice from the planes, each RGB plane is detailed while
Cb and Cr planes are quite flat, and don't contain a lot of unique features.\
That can be exploited by lossless compression.\
Lossless compression eliminating redundant information, which can be used to reduce
our data amount even futher.

Let's try to compress each of the planes of RGB and YCbCr losslessly.\
Each plane is containing only raw data, making each RGB plane is `2073600` bytes,
and YCbCr planes are `2073600`,`518400`,`518400` bytes respectively.

I will use 2 methods:

- Compression on raw plane using `zstd`.
- Compression of grascale image of the plane using PNG and `optipng`.
  Removing redundant information using image compression standard.

### Extracting planes

rgb:\
`ffmpeg -i 1080p.png -filter_complex "extractplanes=r" r.rgb`\
`ffmpeg -i 1080p.png -filter_complex "extractplanes=g" g.rgb`\
`ffmpeg -i 1080p.png -filter_complex "extractplanes=b" b.rgb`

yuv:\
`ffmpeg -i 1080p.y4m -vf "extractplanes=y" -pix_fmt gray y.yuv`\
`ffmpeg -i 1080p.y4m -vf "extractplanes=y" -pix_fmt gray y.yuv`\
`ffmpeg -i input_video.yuv -vf "extractplanes=y" -pix_fmt gray y.yuv`\

Compression Commands:

- `zstd -b22 file`
- `optipng -o5 file`

## Data

RGB - zstd:\
`r.rgb : 2073600 -> 942755 (x2.200)`\
`g.rgb : 2073600 -> 734736 (x2.822)`\
`b.rgb : 2073600 -> 916753 (x2.262)`

RGB - png:\
`r.png : 2073600 -> 724876 (x2.874)`\
`g.png : 2073600 -> 577642 (x3.607)`\
`b.png : 2073600 -> 700227 (x2.975)`\

YCbCr - zstd:\
`y.yuv : 2073600 -> 789617 (x2.626)`\
`u.yuv : 518400  -> 136283 (x3.804)`\
`v.yuv : 518400  -> 139165 (x3.725)`\

YCbCr - png:\
`y.png : 2073600 -> 620876 (x3.355)`\
`u.png : 518400 -> 117,888 (x4.397)`\
`v.png : 518400 -> 119941 (x4.322)`\

What is quite interesing, is that even though we already reduced size of Cb, Cr planes,
their size could be reduced even more than Y plane, and Y plane compressability laying
somewhere in-between RGB planes for both `zstd` and `png`

This gives our small experient result of `2002745` bytes for RGB and `858705` bytes for YCbCr.
What is (x3.106) and (x7.244) reduction in size respectively.
