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
> 2. Run the script below on the files to create a 'searchable' pdf version of the image.

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

**What's a good script for doing the work**

```bash
#!/bin/sh

## 
# This script will take a file that is located in the 'Inbox/Make Searchable' folder
# process it, and move it up to the 'inbox'
#
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

export PATH=$PATH:/usr/local/bin
set -xv
LOG_FILE="/Users/johnsturgeon/Dropbox/Documents/Inbox/Log/ocr.log"
DROPBOX_DOCS_DIR="/Users/johnsturgeon/Dropbox/Documents"
DROPBOX_SEARCHABLE_DIR="${DROPBOX_DOCS_DIR}/Inbox/Searchable"
OCR_TMP_DIR="ocr_working_files"

exec 1> $LOG_FILE
exec 2>&1

full_filename=`realpath "$1"`
filename="$(basename "$full_filename")"
dirname=`dirname "${full_filename}"`
extension="${filename##*.}"
filename_no_ext="${filename%.*}"
date_time="`GetFileInfo -m "${full_filename}"`"
renamed_file="${filename_no_ext}.original_file.${extension}"

mkdir "${dirname}/${OCR_TMP_DIR}" # Make a temporary working dir to dump all the files to.

cd "${dirname}/${OCR_TMP_DIR}"
mv "${full_filename}" "${renamed_file}"

##  If we have a multipage PDF, then we should scan each page
#   export to an image, run ocr on the image, output as PDF and combine the pdf back into one
#
numpages=0
if [ "$extension" == "pdf" ] ; then

	## extract images from pdf for OCR'ing
    # this will output a series of files image-nnnn.ppm
    pdfimages "$renamed_file" tmp_pdf_images

    ## loop through each of the images OCR'ing them
    for i in `ls tmp_pdf_images-*` ; do
        let numpages=${numpages}+1
        convert "$i" "$i".jpg
        tesseract "$i".jpg tmp_tessout-${numpages} pdf
    done

    ## if we have multiple pages, then unite them into one PDF
    if [[ $numpages > 1 ]] ; then
        pdfunite tmp_tessout-*.pdf "${filename_no_ext}".searchable.pdf
    else
        mv tmp_tessout-*.pdf "${filename_no_ext}".searchable.pdf
    fi
else # else, this is just an image file which can be processed easily
    tesseract "${renamed_file}" "${filename_no_ext}".searchable pdf
    rm "${filename_no_ext}".searchable.txt 
fi

# transfer the date time from the original file
SetFile -d "${date_time}" -m "${date_time}" "${filename_no_ext}".searchable.pdf "${filename_no_ext}".txt

# transfer any tags that you might have had to the new files as well
tags=`tag --no-name -l "${renamed_file}"`
tag -a "${tags}" "${filename_no_ext}".searchable.pdf "${filename_no_ext}".txt

## move the original file  uncomment this later
#
mv "${renamed_file}" "/Users/johnsturgeon/Dropbox/ConvertedDocs"
mv "${filename_no_ext}".searchable.pdf "${DROPBOX_SEARCHABLE_DIR}/${filename_no_ext}.pdf"

## cleanup  uncomment this later
rm tmp_*

```

### Interesting links
 
>  [http://www.cyberciti.biz/faq/easily-extract-images-from-pdf-file/](http://www.cyberciti.biz/faq/easily-extract-images-from-pdf-file/)

