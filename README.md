# replace_evernote
Simple project to replace evernote with a 'local' solution

### Purpose

> I would like to have an evernote replacement, one of the nice things about Evernote was that it would OCR everything I threw at it and make all my scanned stuff searchable.
>
>  Below is my own 'home grown' version of that.

### Tools you will need

**tesseract** - OSX

> Tesseract is the ocr engine -- [https://github.com/tesseract-ocr/tesseract](https://github.com/tesseract-ocr/tesseract)
> 
> `brew install tesseract`
> 
> NOTE: *pay attention to possible linking errors*

**imagemagick**- OSX
> Imagemagick converts any image to any format - [http://www.imagemagick.org/script/index.php](http://www.imagemagick.org/script/index.php)
> 
> `brew install imagemagick`
 
**tag**- OSX
> 'tag' is used to tag files from the command line - [https://github.com/jdberry/tag](https://github.com/jdberry/tag)
> 
> (download and install it from github)
 
 **poppler**- OSX
> poppler is a pdf command line utility for creating / merging / splitting pdf files as well as extracting images from pdf files (if necessary) -- [http://poppler.freedesktop.org](http://poppler.freedesktop.org)
> 
> `brew install poppler`
> 

**Scannable** iOS app
> get it from the app store, it's free and fantastic

## Basic workflow

> 1. Save files in my 'documents' folder in Dropbox (use whatever file structure you'd like)
> 2. Run the script [ocr_pdf.sh](https://github.com/johnofcamas/replace_evernote/blob/master/scripts/ocr_pdf.sh) "File To OCR" <can be an image or a pdf>

### How to search your files

> Keeping it simple, use 'Finder' and search.. it will search the contents of the pdfs.


### Optional bonus points

> I use Hazel to automate the process, whenever I add a file that is not 'searchable' I will run the script below on that file

## The Script

### What does the script do?

> There are two different code paths for pdf files and image files
> 
> + PDF file
>     + use pdfimages (from poppler) to extrac the images from the PDF
>     + loop over each page:
>        + use imagemagick 'convert' to convert the images to jpgs
>        + use tesseract to ocr jpgs or pngs and output the results in PDF
>     + combine pdfs using 'pdfunite' (poppler)
> + regular image file
>     + use tesseract to ocr jpgs or pngs and output the results in PDF 
> 
> Once that is done, the script cleans up
> + Sets the date/time stamp to that of the original file
> + Sets the tags on the file to that of the original file
> 
> 

### Interesting links
 
>  [http://www.cyberciti.biz/faq/easily-extract-images-from-pdf-file/](http://www.cyberciti.biz/faq/easily-extract-images-from-pdf-file/)

