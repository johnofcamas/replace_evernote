#!/bin/sh

## 
# This script will take a file process it, and move it up to the 'DEST_DIR'
#

# realpath gets the 'real' path of the file at $1
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

set -xv
export PATH=$PATH:/usr/local/bin # this will pull in tesseract, imagemagick, etc...

##
# Directory structure:
#

#TODO: You need to fix the variable below to point to your Dropbox root folder
DROPBOX_ROOT_DIR="<replace with your Dropbox dir" # your dropbox root folder
DEST_DIR="${DROPBOX_ROOT_DIR}/Documents/Inbox/Searchable"  # this is where you want the final 'searchable' pdf to go
LOG_DIR="${DROPBOX_ROOT_DIR}/Documents/Inbox/Log" 
ARCHIVE_DIR="${DROPBOX_ROOT_DIR}/ConvertedDocs" # where to move the original non-searchable files when complete
OCR_TMP_DIR="ocr_working_files" # this is a temporary working directory for intermediate files  it will be left around

LOG_FILE="ocr.log"

#exec 1> $LOG_FILE
#exec 2>&1

full_filename=`realpath "$1"`
filename="$(basename "$full_filename")"
dirname=`dirname "${full_filename}"`
extension="${filename##*.}"
filename_no_ext="${filename%.*}"
date_time="`GetFileInfo -m "${full_filename}"`"
original_file="${filename_no_ext}.original_file.${extension}"

mkdir "${dirname}/${OCR_TMP_DIR}" # Make a temporary working dir to dump all the files to.

cd "${dirname}/${OCR_TMP_DIR}"
mv "${full_filename}" "${original_file}"

##  If we have a multipage PDF, then we should scan each page
#   export to an image, run ocr on the image, output as PDF and combine the pdf back into one
#
numpages=0
if [ "$extension" == "pdf" ] ; then

    ## extract images from pdf for OCR'ing
    # this will output a series of files image-nnnn.ppm
    pdfimages "$original_file" tmp_pdf_images

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
    tesseract "${original_file}" "${filename_no_ext}".searchable pdf
    rm "${filename_no_ext}".searchable.txt 
fi

# transfer the date time from the original file
SetFile -d "${date_time}" -m "${date_time}" "${filename_no_ext}".searchable.pdf "${filename_no_ext}".txt

# transfer any tags that you might have had to the new files as well
tags=`tag --no-name -l "${original_file}"`
tag -a "${tags}" "${filename_no_ext}".searchable.pdf "${filename_no_ext}".txt

## move the original file  uncomment this later##
#
mv "${filename_no_ext}".searchable.pdf "${DEST_DIR}/${filename_no_ext}.pdf"

## TODO: When you're confident all is working well, uncomment the line below
#rm -rf "${OCR_TMP_DIR}"

## TODO: When you're confident all is working well, swap the commented/uncommented state of the two lines below
mv "${original_file}" "${ARCHIVE_DIR}"
#rm "${original_file}"
