#!/usr/bin/awk -f

BEGIN {
    FS = "\t"
    OFS = "\t"
    
    # First, load the second file (english names) into memory
    while ((getline < "glaux-english.tsv") > 0) {
        if (FNR > 1) {  # Skip header
            id = $1
            english_authors[id] = $2
            english_titles[id] = $3
        }
    }
    close("glaux-english.tsv")
    
    # Print header for output file
    print "GLAUX_TEXT_ID", "TLG", "STARTDATA", "ENDDATE", "AUTHOR_STANDARD", "TITLE_STANDARD", "GENRE_STANDARD", "DIALECT", "SOURCE", "SOURCE_LICENSE", "SOURCE_FORMAT", "TOKENS", "TM_TEXT", "AUTHOR_ENGLISH", "TITLE_ENGLISH"
}

# Process the main file
FNR > 1 {
    id = $1
    # Print all original fields plus the English names
    print $0, english_authors[id], english_titles[id]
}
